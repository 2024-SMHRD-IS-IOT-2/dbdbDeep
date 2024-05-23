import subprocess, sys
## pip install
# subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", 'requirements.txt'])

def main():

    from handler.langchainHandler import TaskClassifier, ConvGenThread, TASK
    from handler.outputHandler import GenerateOutputAudioThread, PlayAudio, HomeCtrl
    from handler.inputHandler import InputHandler
    from model.emotionModel import EmotionModelThread
    from common.thread import THREAD_STATUS
    from common.sql import MysqlConn
    from music.recMusic import RecMusic
    from music.musicPlayer import MusicPlayer

    from threading import Event
    from dotenv import load_dotenv
    import os
    import serial

    ## init
    load_dotenv('./config/keys.env')
    ttsEvent = Event()
    convGenEvent = Event()
    emoEvent = Event()
    
    user_id = os.environ['USER_ID']
    ser = serial.Serial(os.environ['ARDUINO_PORT'], 115200, timeout=1)
    ser.reset_input_buffer()

    sqlconn = MysqlConn(host=os.environ["MYSQL_HOST"], port=int(os.environ["MYSQL_PORT"]),
                        user=os.environ["MYSQL_USER"], pwd= os.environ["MYSQL_PASSWORD"], 
                        db=os.environ["MYSQL_DATABASE"])
    homeCtrl = HomeCtrl(os.environ['raspHomeIP'])
    inputHandle = InputHandler(access_key=os.environ['PORCUPINE_ACCESS_KEY'],
                               keyword_file_path=os.environ['PORCUPINE_KEYWORD_FILE_PATH'],
                               model_file_path=os.environ['PORCUPINE_MODEL_FILE_PATH'],
                               sensitivity=1)
    taskClassifier = TaskClassifier(api_key=os.environ['OPENAI_API_KEY_CLASS'], temp=0.5, max_tokens=100)  ## 분류 llm 객체
    convGen = ConvGenThread(convGenEvent, api_key=os.environ['OPENAI_API_KEY_CONV'], temp=1.2, max_tokens=100 )  ## 대화생성 llm 객체
    generateOutputAudio = GenerateOutputAudioThread(event=ttsEvent,
                                                    actor_id=os.environ['TYPECAST_ACTOR_ID'], 
                                                    api_key=os.environ['TYPECAST_API_KEY']) ## 출력오디오 생성 객체
    musicPlayer = MusicPlayer(SPOTIFY_CLIENT_ID=os.environ['SPOTIFY_CLIENT_ID'],
                              SPOTIFY_CLIENT_SECRET=os.environ['SPOTIFY_CLIENT_SECRET'],
                              SPOTIFY_URI=os.environ['SPOTIFY_URI'])
    recMusic = RecMusic(PINECONE_API_KEY=os.environ['PINECONE_API_KEY'],
                        sqlconn= sqlconn,
                        music_player=musicPlayer,
                        user_id=user_id)
    emotionModel = EmotionModelThread(event=emoEvent, user_id=user_id, conn=sqlconn, recMusic=recMusic)

    playConvAudio = PlayAudio(input_q=generateOutputAudio.output_queue, ser=ser)
    convGen.set_output_queue(generateOutputAudio.input_queue)

    convGen.start()
    generateOutputAudio.start()
    emotionModel.start()

    ttsEvent.clear()
    convGenEvent.clear()
    emoEvent.set()
    wavInd = 0
    
    print("main: init done")

    # ## 메인
    while True:
        

        ## 기존 대화 리셋
        convGen.reset_conversation()
        ## 대화파일 인덱스 리셋
        wavInd = 0

        ser.write(b"clean")

        ## 키워드 인식
        inputHandle.recognize_keyword()
        ## wakeup sound 
        playConvAudio.play_file('./wav/wakeupSound.wav')
        
    

        ############### 대화 사이클
        while True :


            ## 노말 감정 표현
            ser.write(b"normal-4")
            
            ## 음악 추천
            if recMusic.isMusicReady() :
                print("main: music is ready")
                playConvAudio.play_file('./wav/musicRec.wav')
                ## TODO 아두이노로 신호 전송 (노래 재생 신호)
                recMusic.ctrlMusic({'ctrl':"play"})

            

            ## 유저 음성 받기 !! 완료 !!
            userInputIn, user_input_text, user_input_audio = inputHandle.get_user_input(filename=f'./wav/userSentence{wavInd}.wav',
                                                                                          inputWaitTime=20, 
                                                                                          silence_duration=2, 
                                                                                          silence_threshold=700)
            wavInd+=1
            
            # TEST 유저음성
            # userInputIn, user_input_text, user_input_audio = True, "짱구야 다음 노래 틀어줘" , "./wav/userSentence.wav"
            # print("userInput in")            

            ## 노이즈 받았을시 무시
            if user_input_text == "noise" :
                continue
            ## 일정 시간동안 말 안했을떄. 아웃.
            elif not userInputIn:
                break
            ## 유저가 음성을 받았을 때
            else :
                # 쓰레드 시작
                ttsEvent.set()
                convGenEvent.set()
                emoEvent.set()

                # 감정분석 인풋
                emotionModel.push_input(THREAD_STATUS.RUNNING, user_input_text, user_input_audio)
                emotionModel.push_input(THREAD_STATUS.DONE, "", "")
                # 대화생성 인풋
                convGen.push_input(THREAD_STATUS.RUNNING, user_input_text)
                convGen.push_input(THREAD_STATUS.DONE, "")
                print("main: convGen started")

                # 유저 인풋 문자열 작업 분류
                task, arg = taskClassifier.classify(user_input_text) 
                print("main: classifier done")


                ## 대화로 분류됐을 시 준비돼있는 오디오 출력
                if task == TASK.CONVERSATION:
                    ## || 완료 ||
                    print("main: task=conversation", arg)
                    playConvAudio.play_all_conv_file()
                    print("main: conv done")

                elif task == TASK.MUSIC_CTRL:
                    ## || 완료 ||
                    ## 기능은 해당 클래스에서
                    print("main: task=music control", arg)
                    convGen.reset_conversation()
                    playConvAudio.clear_input()
                    
                    ## TODO : 대답 음성 출력 
                    recMusic.ctrlMusic(arg)
                    
                    pass

                elif task == TASK.IOT_CTRL:
                    ## || 완료 ||                    
                    print("main: task=IoT Control", arg)
                    convGen.reset_conversation()
                    playConvAudio.clear_input()
                    ## TODO : 명령 인식 확인 오디오 출력.
                    res = homeCtrl.requestCtrl(arg)
                    if res == 200 :
                        print("main: iot조작 성공")
                    else : 
                        print("main: iot조작 실패")
                    playConvAudio.clear_input()
                    
    #         print("exit conversation cycle")
    #         break # TEST. 대화 사이클 while 종료
    
    #     print("exit main loop")
    #     break  # TEST. 메인 프로그램 loop 종료
    # # 대기중인 쓰레드 종료

    # [ev.set() for ev in [ttsEvent,convGenEvent,emoEvent,musicEvent]]
    convGen.push_input(THREAD_STATUS.FINISH, "")
    convGen.finish()
    generateOutputAudio.finish()
    emotionModel.push_input(THREAD_STATUS.FINISH, "", "")
    emotionModel.finish()
    print("thread all clear")
    sqlconn.connClose()


if __name__ == "__main__":
    
    main()


