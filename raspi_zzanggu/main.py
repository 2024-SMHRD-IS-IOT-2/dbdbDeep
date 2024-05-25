import subprocess, sys
## pip install
# subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", 'requirements.txt'])

def main():

    from handler.langchainHandler import TaskClassifier, ConvGenProcess, TASK
    from handler.outputHandler import GenerateOutputAudioProcess, PlayAudio, HomeCtrl
    from handler.inputHandler import InputHandler
    from model.emotionModel import EmotionModelProcess
    from common.process import PROCESS_STATUS
    from common.sql import MysqlConn
    from music.musicPlayer import MusicPlayer
    from music.recMusic import RecMusic
    from multiprocessing import Event, Queue

    from dotenv import load_dotenv
    import os
    import serial
    import time

    ## init
    load_dotenv('./config/keys.env')
    convGenEvent = Event()
    ttsEvent = Event()
    emoEvent = Event()
    emo2rec_q = Queue()

    user_id = os.environ['USER_ID']
    try :
        ser = serial.Serial(os.environ['ARDUINO_PORT'], 115200, timeout=1)
        ser.reset_input_buffer()
    except :
        print("serial not connected")

    homeCtrl = HomeCtrl(os.environ['raspHomeIP'])
    inputHandle = InputHandler(access_key=os.environ['PORCUPINE_ACCESS_KEY'],
                               keyword_file_path=os.environ['PORCUPINE_KEYWORD_FILE_PATH'],
                               model_file_path=os.environ['PORCUPINE_MODEL_FILE_PATH'],
                               sensitivity=1)
    ## 분류 llm 객체
    taskClassifier = TaskClassifier(api_key=os.environ['OPENAI_API_KEY_CLASS'], 
                                    temp=0.5, 
                                    max_tokens=100)  
    
    ## 대화생성 프로세스
    convGen = ConvGenProcess(api_key=os.environ['OPENAI_API_KEY_CONV'], 
                             temp=1.2, 
                             max_tokens=100,
                             )  
    ## tts 프로세스
    generateOutputAudio = GenerateOutputAudioProcess(actor_id=os.environ['TYPECAST_ACTOR_ID'], 
                                                    api_key=os.environ['TYPECAST_API_KEY'], 
                                                    )

    sqlconn = MysqlConn(host=os.environ["MYSQL_HOST"], port=int(os.environ["MYSQL_PORT"]),
                user=os.environ["MYSQL_USER"], pwd= os.environ["MYSQL_PASSWORD"], 
                db=os.environ["MYSQL_DATABASE"])

    musicPlayer = MusicPlayer(SPOTIFY_CLIENT_ID=os.environ['SPOTIFY_CLIENT_ID'],
                            SPOTIFY_CLIENT_SECRET=os.environ['SPOTIFY_CLIENT_SECRET'],
                            SPOTIFY_URI=os.environ['SPOTIFY_URI'])
    recMusic = RecMusic(
                    PINECONE_API_KEY=os.environ['PINECONE_API_KEY'],
                    sqlconn= sqlconn,
                    music_player=musicPlayer,
                    user_id=user_id,
                    minNumRec=5)
   
   
    ## 감정분석프로세스
    emotionModel = EmotionModelProcess()

    playConvAudio = PlayAudio(input_q=generateOutputAudio.output_queue, ser=ser)
    convGen.set_output_queue(generateOutputAudio.input_queue)

    emotionModel.start(emo2rec_q)
    convGen.start(convGenEvent)
    generateOutputAudio.start(ttsEvent)

    emoEvent.set()
    convGenEvent.set()
    ttsEvent.set()

    isRunning = True
    wavInd = 0
    
    print("main: init done")

    # ## 메인
    while isRunning:
        

        ## 기존 대화 리셋
        convGenEvent.set()
        convGen.push_input(PROCESS_STATUS.RESET, "")
        ## 대화파일 인덱스 리셋
        wavInd = 0

        ser.write(b"sleep")

        # ## 키워드 인식
        inputHandle.recognize_keyword()
        ## wakeup sound 
        playConvAudio.play_file('./wav/wakeupSound.wav')
        
    

        ############### 대화 사이클
        while True :


            ## 노말 감정 표현
            ser.write(b"normal-4")

            ## 감정 => recMusic
            if not emo2rec_q.empty() :
                print("emo2rec_q!!!!")
                emo = emo2rec_q.get_nowait()
                recMusic.emo_2_music(emo)

                query = """
                            INSERT INTO TB_EMOTION (USER_ID, EMOTION_VAL) VALUES (%s, %s);
                        """
                res = sqlconn.sqlquery(query, user_id, emo)
                print("emoModel: emo_to_DB result", res)
            

            ## 음악 추천
            if recMusic.isMusicReady() :
                print("main: music is ready")
                playConvAudio.play_file('./wav/musicRec.wav')
                recMusic.ctrlMusic({'ctrl':"play"})


            ## 유저 음성 받기
            userInputIn, user_input_text, user_input_audio = inputHandle.get_user_input(
                    filename=f'./wav/userSentence{wavInd}.wav',
                    inputWaitTime=20, 
                    silence_duration=1.2, 
                    silence_threshold=700)
            wavInd+=1
            
            getInputStartTIme = time.time()


            ## 노이즈 받았을시 무시
            if user_input_text == "noise" :
                continue

            # 종료를 받았을 때
            elif user_input_text == "종료":
                isRunning = False
                break
            
            ## 일정 시간동안 말 안했을떄. 아웃.
            elif not userInputIn:
                break
            ## 유저가 음성을 받았을 때
            else :
                                
                convGenEvent.set()
                ttsEvent.set()


                # 감정분석 인풋
                emotionModel.push_input(PROCESS_STATUS.RUNNING, user_input_text, user_input_audio)
                emotionModel.push_input(PROCESS_STATUS.DONE, "", "")
                print("main: emotionModel running") 
                # 대화생성 인풋
                convGen.push_input(PROCESS_STATUS.RUNNING, user_input_text)
                convGen.push_input(PROCESS_STATUS.DONE, "")
                print("main: convGen running")

                # 유저 인풋 문자열 작업 분류
                task, arg = taskClassifier.classify(user_input_text) 
                print("main: classifier done")

                getInputEndTIme = time.time()
                print(f"TIME classifier : {(getInputEndTIme-getInputStartTIme):.2f} second")

                ## 대화로 분류됐을 시 준비돼있는 오디오 출력
                if task == TASK.CONVERSATION:
                    ## || 완료 ||
                    print("main: task=conversation", arg)
                    playConvAudio.play_all_conv_file()
                    print("main: conv done")

                elif task == TASK.MUSIC_CTRL:
                    print("main: task=music control", arg)
                    # convGenEvent.set()
                    # convGen.push_input(PROCESS_STATUS.RESET, "")
                    playConvAudio.clear_input()
                    
                    recMusic.ctrlMusic(arg)
                    


                elif task == TASK.IOT_CTRL:
                    print("main: task=IoT Control", arg)
                    # convGenEvent.set()
                    # convGen.push_input(PROCESS_STATUS.RESET, "")
                    playConvAudio.clear_input()
                    ## TODO : 명령 인식 확인 오디오 출력.
                    res = homeCtrl.requestCtrl(arg)
                    if res == 200 :
                        print("main: iot조작 성공")
                    else : 
                        print("main: iot조작 실패")

                    
    #         print("exit conversation cycle")
    #         break # TEST. 대화 사이클 while 종료
    
    #     print("exit main loop")
    #     break  # TEST. 메인 프로그램 loop 종료
    # # 대기중인 쓰레드 종료

    convGenEvent.set()
    ttsEvent.set()

    convGen.push_input(PROCESS_STATUS.FINISH, "")
    convGen.finish()
    generateOutputAudio.finish()
    emotionModel.push_input(PROCESS_STATUS.FINISH, "", "")
    emotionModel.finish()
    sqlconn.connClose()


if __name__ == "__main__":
    
    main()


