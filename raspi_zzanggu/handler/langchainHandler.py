from common.thread import Thread, THREAD_STATUS
from enum import Enum
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI
from langchain.chains import ConversationChain
from langchain_core.callbacks.base import BaseCallbackHandler
from langchain.memory import ConversationBufferMemory

class TASK(Enum):
    NONE = 0
    CONVERSATION = 1
    IOT_CTRL = 2
    MUSIC_RECOMMEND = 3
    MUSIC_CTRL = 3


class IOT_CTRL(Enum):
    FAN = 0
    LIVINGROOM_LED = 1
    BEDROOM_LED = 2


## gpt 대답생성 쓰레드
## 계속 돌아감.
## 인풋 큐 : flag, userSentence
## 아웃풋 큐 : flag, emotion, gptSentence
class ConvGenThread(Thread, BaseCallbackHandler):
    def __init__(self, event, api_key, temp = 1.2, max_tokens=500):
        super().__init__(target=self.target, event=event)
        
        self.conversation = ConversationChain(
            llm= ChatOpenAI(
                    api_key=api_key,
                    temperature= temp, 
                    max_tokens = max_tokens,
                    model_name='gpt-4',
                    # model_name='gpt-3.5-turbo',
                    streaming=True,
                    callbacks=[self]
                ),
            verbose=True,
            memory=ConversationBufferMemory(),
        )
        self.reset_conversation()
        self.sentenceToken = ""
        ## happy-123, angry-1234, sad-1234, normal-1234
        self.emoList = {'##':'normal-4', 
           '^^':'happy-3',
          '@@':'angry-4',
          '**':'sad-4'}
        self.emo = 'normal-4'
        
    def target(self):
        while True:
            #!TODO conversation generation 처리
            self.event.wait()
            if not self.input_queue.empty():
                flag, sentence = self.input_queue.get_nowait()
                self.set_status(flag)
                if flag == THREAD_STATUS.FINISH:
                    self.push_output(flag, "", "")
                    break
                elif flag == THREAD_STATUS.DONE :
                    self.push_output(flag, "", "")
                    print("convGen thread clear")
                    self.event.clear()
                    
                elif flag == THREAD_STATUS.RUNNING:
                    self.conversation.predict(input=sentence)
                
        
    ## 토큰 스트리밍 콜백
    def on_llm_new_token(self, token: str, **kwargs) -> None:

        if token in self.emoList :
            self.emo = self.emoList[token]
        elif token in ['.','?','!'] :
            self.sentenceToken+=token
            self.push_output(THREAD_STATUS.RUNNING, self.emo, self.sentenceToken)
            print("emotion : ", self.emo, "sentence token : ", self.sentenceToken)
            self.sentenceToken = ""
        else :
            self.sentenceToken += token
            # print(f"{token}", flush=True)
            
    def reset_conversation(self) :
        self.conversation.memory.clear()
        self.conversation.memory.save_context(
            {"input": """
            your name is 짱구. and you will speak in korean. 
            you will speak friendly like best friend vibe. 
            before you start talking, you will select your emotion from 
            this list [happy, sad, normal, angry]
            you will put emotion code in front of your answer.
            don't create your answer too long.
            always end sentence with [. , ? !] nothing else
            
            ## -> normal
            ^^ -> happy
            @@ -> angry
            ** -> sad
         """}, {"output": "##알았어. 내 이름은 짱구야. 넌 뭐하니"})
        
        
## no thread
class TaskClassifier:
    def __init__(self, api_key, temp=0.5, max_tokens=300):
        self.classify_llm = ChatOpenAI(
        api_key=api_key,
        temperature=temp, 
        max_tokens = max_tokens,
        model_name='gpt-3.5-turbo',
        ).bind_tools(llm_ctrl_list)
        

    def classify(self, user_input_text):
        task = TASK.NONE
        ans = self.classify_llm.invoke(user_input_text).tool_calls
        
        arg = []
        if len(ans)  == 0  :
            task = TASK.CONVERSATION
        else :
            arg = ans[0]['args']
            if ans[0]['name'] == 'control_iot' :
                task = TASK.IOT_CTRL
            elif ans[0]['name'] == 'control_music' :
                task = TASK.MUSIC_CTRL
            elif ans[0]['name'] == 'recommend_music' :
                task = TASK.MUSIC_RECOMMEND
            
        return task, arg



## thread version
class TaskClassifierThread(Thread):
    def __init__(self, api_key, event, temp=0.5, max_tokens=300):
        super().__init__(target=self.target,event=event)
        
        self.classify_llm = ChatOpenAI(
        api_key=api_key,
        temperature=temp, 
        max_tokens = max_tokens,
        model_name='gpt-4',
        ).bind_tools(llm_ctrl_list)
        

    def target(self):

        user_input_text = self.input_queue.get()

        print(user_input_text)
        task = TASK.NONE
        ans = self.classify_llm.invoke(user_input_text).tool_calls
        
        arg = []
        if len(ans)  == 0 :
            task = TASK.CONVERSATION
        else :
            arg = ans[0]['args']
            if ans[0]['name'] == 'control_iot' :
                task = TASK.IOT_CTRL
            elif ans[0]['name'] == 'control_music' :
                task = TASK.MUSIC_CTRL
            elif ans[0]['name'] == 'recommend_music' :
                task = TASK.MUSIC_RECOMMEND
            
        self.output_queue.put((task,arg))
        return task, arg




####### langchain tool calling ########
@tool
def recommend_music(emotion:str, ctrl:int)->int:
    """
        check if user ask for the music recommendation, or ask not to recommend.
        based on the user input, determine user's emotion from [happy, angry, normal, sad]
        emotion value is normal by default
        RECOMMEND_NOW = 5
        DONT_RECOMMEND = 6

    """
    return TASK.MUSIC_RECOMMEND

@tool
def control_music(ctrl:int)->int:
    """
        check what user wants to do with the current music.
            STOP current music = 0
            PAUSE current music = 1
            PLAY or resume current music = 2
            SKIP current music = 3
            get current music information = 4
    """
    return TASK.MUSIC_CTRL

@tool
def control_iot(device:int, power:int, sec:int)-> str:
    """
        smart home control.
        select device index, power, and second
        control the light brightness with power 0(off) to 100
        sleep light is at 50 default
        if second is not given, default second is 0
        for device index,
        fan = 0
        living-room = 1
        bed-room = 2
    """    
    return "controlIOT"



llm_ctrl_list = [recommend_music, control_music, control_iot]