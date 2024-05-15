from handler.langchainHandler import TaskClassifier, ConvGenThread, TASK
from handler.outputHandler import GenerateOutputAudioThread, PlayAudioThread
from handler.inputHandler import InputHandler
from model.emotionModel import EmotionModelThread
from threading import Event
from common.thread import THREAD_STATUS
import setup
from dotenv import load_dotenv
import os
import winsound as ws

def main():
    
    ## init
    event = Event()
    inputHandle = InputHandler(access_key=os.environ['PORCUPINE_ACCESS_KEY'],
                               keyword_file_path=os.environ['PORCUPINE_KEYWORD_FILE_PATH'],
                               model_file_path=os.environ['PORCUPINE_MODEL_FILE_PATH'],
                               sensitivity=float(os.environ['PORCUPINE_SENSITIVITY']))  
    # taskClassifier = TaskClassifier()  ## 분류 llm 객체
    # convGen = ConvGenThread(event)  ## 대화생성 llm 객체
    # generateOutputAudio = GenerateOutputAudioThread(event) ## 출력오디오 생성 객체
    # playAudio = PlayAudioThread(event)  ## 오디오 출력 객체

    # emotionModel = EmotionModelThread(event)

    # convGen.set_output_queue(generateOutputAudio.input_queue)
    # generateOutputAudio.set_output_queue(playAudio.input_queue)

    # convGen.start()
    # emotionModel.start()
    # generateOutputAudio.start()
    # playAudio.start()

    print("init done")

    isRunning = True
    # event.clear()

    # ## 메인.while
    if isRunning:
        

        ## 키워드 인식 !! 완료 !!
        inputHandle.recognize_keyword()

        ## wakeup sound 
        ws.Beep(500, 200)
        ## TODO : 비프음 대신 대답파일로 교체. 
        ## TODO : arduino serial 신호 전송 (normal)
    

    
        ## 유저 음성 받기 !! 완료 !!
        userInput, user_input_text, user_input_audio = inputHandle.get_user_input(filename='./wav/userSentence.wav',
                                                                                      inputWaitTIme=10, 
                                                                                      silence_duration=2, 
                                                                                      silence_threshold=40)

        ## 오디오 테스트용 
        task = TASK.CONVERATION
        userInput = True
        user_input_text = "테스트용 인풋"
        user_input_audio = './wav/ttsTest.wav'
        
        ## 유저가 음성을 받았을 때
        if userInput :
            print("userInput: ", user_input_text, "userInputAudio:", user_input_audio)

            # 백그라운드 쓰레드에서 감정분석, 대화생성
            # emotionModel.push_input(THREAD_STATUS.RUNNING, user_input_text, user_input_audio)
            # convGen.push_input(THREAD_STATUS.RUNNING, user_input_text)


            # 랭체인으로 음성 문자열 작업 분류
            # task = taskClassifier.classify(user_input_text) 

            ## 대화로 분류됐을 시 오디오 출력
            ## convGen-> tts, 
            # if task == TASK.CONVERATION:
            #     event.set()
            #     while playAudio.get_status() == THREAD_STATUS.RUNNING:
            #         pass
            #     event.clear()

            # elif task == TASK.MUSIC_RECOMMEND:
            #     playAudio.clear_input()
            #     while emotionModel.get_status() == THREAD_STATUS.RUNNING:
            #         pass
            #     flag, music_file = emotionModel.output_queue.get_nowait()
                # ! TODO music_file 재생

            ## elif 스마트홈 컨트롤
            
            # elif 유저시나리오 음악 조작

            isRunning = False
            # break

    # convGen.push_input(THREAD_STATUS.FINISH, "")
    # convGen.finish()
    # generateOutputAudio.finish()
    # playAudio.finish()
    # emotionModel.finish()


if __name__ == "__main__":
    ## install all requirements
    # setup.inst_all_from_requirements("requirements.txt")
    
    load_dotenv('./config/keys.env')
    
    
    main()

