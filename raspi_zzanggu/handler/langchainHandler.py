from common.process import MyProcess, PROCESS_STATUS
from enum import Enum
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI
from langchain.chains import ConversationChain
from langchain_core.callbacks.base import BaseCallbackHandler
from langchain.memory import ConversationBufferMemory
import time

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
class ConvGenProcess(MyProcess, BaseCallbackHandler):
    def __init__(self, api_key, temp = 1.2, max_tokens=100):
        super().__init__(target=self.target)
        self.api_key = api_key
        self.temp = temp
        self.max_tokens = max_tokens
        self.sentenceToken = ""
        ## happy-123, angry-1234, sad-1234, normal-1234
        self.emoList = {'##':'normal-4', 
           '^^':'happy-3',
          '@@':'angry-4',
          '**':'sad-4'}
        self.emo = 'normal-4'
        
    def target(self, ev):
        conversation = ConversationChain(
            llm= ChatOpenAI(
                    api_key=self.api_key,
                    temperature= self.temp, 
                    max_tokens = self.max_tokens,
                    model_name='gpt-4',
                    # model_name='gpt-3.5-turbo',
                    streaming=True,
                    callbacks=[self]
                ),
            verbose=True,
            memory=ConversationBufferMemory(),
        )

        self.reset_conversation(conversation)


        while True:
            ev.wait()
            # conversation generation 처리
            if not self.input_queue.empty():
                flag, sentence = self.input_queue.get_nowait()
                self.set_status(flag)
                if flag == PROCESS_STATUS.FINISH:
                    print("convGen : convGenProcess break")
                    self.push_output(flag, "", "")
                    break
                elif flag == PROCESS_STATUS.DONE :
                    self.push_output(flag, "", "")
                    print("convGen : convGen done")
                    ev.clear()
                elif flag == PROCESS_STATUS.RESET :
                    self.reset_conversation(conversation)
                    print("convGen : conversation reset")
                    ev.clear()

                elif flag == PROCESS_STATUS.RUNNING:
                    startTime = time.time()
                    conversation.predict(input=sentence)
                    endTime = time.time()
                    print(f"TIME convGen : {(endTime-startTime):.2f} second")

        
    ## 토큰 스트리밍 콜백
    def on_llm_new_token(self, token: str, **kwargs) -> None:

        if token in self.emoList :
            self.emo = self.emoList[token]
        elif token in ['.','?','!'] :
            self.sentenceToken+=token
            self.push_output(PROCESS_STATUS.RUNNING, self.emo, self.sentenceToken)
            print("convGen: emotion=", self.emo, "sentence token=", self.sentenceToken)
            self.sentenceToken = ""
        else :
            self.sentenceToken += token
            
    def reset_conversation(self, conversation) :
        conversation.memory.clear()
        conversation.memory.save_context(
            {"input": """
            your name is 송이. and you will speak in korean. 
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
         """}, {"output": "##알았어. 나는 너의 친한 친구 송이야."})
        
        
class TaskClassifier:
    def __init__(self, api_key, temp=0.5, max_tokens=500):
        self.classify_llm = ChatOpenAI(
        api_key=api_key,
        temperature=temp, 
        max_tokens = max_tokens,
        model_name='gpt-4',
        ).bind_tools(llm_ctrl_list)
        

    def classify(self, user_input_text):
        task = TASK.NONE
        ans = self.classify_llm.invoke(user_input_text).tool_calls
        
        arg = []
        if len(ans)  == 0 or ans[0]['name'] == 'normal_conversation':
            task = TASK.CONVERSATION
        else :
            arg = ans[0]['args']
            if ans[0]['name'] == 'control_iot' :
                task = TASK.IOT_CTRL
            elif ans[0]['name'] == 'control_music' :
                task = TASK.MUSIC_CTRL
            
        return task, arg



####### langchain tool calling ########
@tool
def normal_conversation(isConv:bool)->int:
    """
        this function is only when if the user input is normal conversation.
        not about controlling light or fan, not about music playing, stopping, skipping, or getting info.

    """
    return TASK.CONVERSATION


@tool
def control_music(ctrl:str, artist:str, song:str)->int:
    """
        check what user wants to do with the music.
        if your input contains music, song, "음악", "노래" do one of the following. 
        also check if user don't want the music recommendation.
        if user ask you to play music with artist and music title, play.
        below is the list of user order
            STOP current music = "stop"
            REPLAY current music = 'replay'
            back or previous current music = "previous"
            SKIP current music = "skip"
            PLAY current music = "play"
            Play the next music = "skip"
            play music of given artist and title = "userWant"
            UP volumn or sound about current music = "volumn_up"
            DOWN volumn or sound about current music = "volumn_down"
            dont recommend music = "dontRecommend"
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
        air-conditioner = 0
        living-room = 1
        bed-room = 2
        bathroom = 3
    """    
    return "controlIOT"



llm_ctrl_list = [control_music, control_iot]