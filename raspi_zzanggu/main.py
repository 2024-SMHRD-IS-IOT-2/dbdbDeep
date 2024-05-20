import subprocess, sys
## pip install
#subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", 'requirements.txt'])

def main():

    from handler.langchainHandler import TaskClassifier, ConvGenThread, TASK, TaskClassifierThread
    from handler.outputHandler import GenerateOutputAudioThread, PlayAudio, HomeCtrl
    from handler.inputHandler import InputHandler
    from model.emotionModel import EmotionModelThread
    from common.thread import THREAD_STATUS
    from common.sql import MysqlConn
    from music.recMusic import RecMusic
    from music.musicPlayer import MusicPlayer
    from music.recMusic import MUSIC_CTRL
    
    from threading import Event, Thread
    from queue import Queue
    from dotenv import load_dotenv
    import os

    ## init
    load_dotenv('./config/keys.env')
    ttsEvent = Event()
    convGenEvent = Event()
    emoEvent = Event()
    musicEvent = Event()

    user_id = os.environ['USER_ID']
    sqlconn = MysqlConn(host=os.environ["MYSQL_HOST"], port=int(os.environ["MYSQL_PORT"]),
                        user=os.environ["MYSQL_USER"], pwd= os.environ["MYSQL_PASSWORD"], 
                        db=os.environ["MYSQL_DATABASE"])
    
    homeCtrl = HomeCtrl(os.environ['raspHomeIP'])
    inputHandle = InputHandler(access_key=os.environ['PORCUPINE_ACCESS_KEY'],
                               keyword_file_path=os.environ['PORCUPINE_KEYWORD_FILE_PATH'],
                               model_file_path=os.environ['PORCUPINE_MODEL_FILE_PATH'],
                               sensitivity=float(os.environ['PORCUPINE_SENSITIVITY']))  
    taskClassifier = TaskClassifier(api_key=os.environ['OPENAI_API_KEY_CLASS'], temp=0.5, max_tokens=100)  ## 분류 llm 객체
    # taskClassifier2 = TaskClassifierThread(api_key=os.environ['OPENAI_API_KEY_CLASS'],event=Event(), temp=0.5, max_tokens=100)
    convGen = ConvGenThread(convGenEvent, api_key=os.environ['OPENAI_API_KEY_CONV'], temp=1.2, max_tokens=100 )  ## 대화생성 llm 객체
    generateOutputAudio = GenerateOutputAudioThread(event=ttsEvent,
                                                    actor_id=os.environ['TYPECAST_ACTOR_ID'], 
                                                    api_key=os.environ['TYPECAST_API_KEY']) ## 출력오디오 생성 객체
    emotionModel = EmotionModelThread(event=emoEvent, user_id=user_id, emo_text_model=None, emo_wav_model=None, conn=sqlconn)
    musicPlayer = MusicPlayer(SPOTIFY_CLIENT_ID=os.environ['SPOTIFY_CLIENT_ID'],
                              SPOTIFY_CLIENT_SECRET=os.environ['SPOTIFY_CLIENT_SECRET'],
                              SPOTIFY_URI=os.environ['SPOTIFY_URI'])
    recMusic = RecMusic(event=musicEvent, PINECONE_API_KEY=os.environ['PINECONE_API_KEY'],
                        sqlconn= sqlconn,
                        music_player=musicPlayer,
                        user_id=user_id)

    playConvAudio = PlayAudio(generateOutputAudio.output_queue)
    convGen.set_output_queue(generateOutputAudio.input_queue)

    convGen.start()
    generateOutputAudio.start()
    emotionModel.start()

    [ev.clear() for ev in [ttsEvent,convGenEvent,emoEvent,musicEvent]]
    
    
    print("init done")

    # ## 메인
    while True:
        

        ## 기존 대화 리셋
        convGen.reset_conversation()

        ## 키워드 인식 !! 완료 !!
        # inputHandle.recognize_keyword()

        ## wakeup sound 
        ## TODO : 비프음 대신 대답파일로 교체. 
        ## TODO : arduino serial 신호 전송 (normal)
    

        ############### 대화 사이클
        while True :
            
            
            
            ## 음악 추천해줄지 물어봄
            if recMusic.isMusicReady() :
                ## TODO 음악 틀어줄게 사전 녹음 음성. (감정별로) 
                ## TODO 아두이노로 신호 전송 (노래 재생 신호)
                recMusic.ctrlMusic(MUSIC_CTRL.PLAY)
                
                
                pass
            
            

            ## 유저 음성 받기 !! 완료 !!
            # userInputIn, user_input_text, user_input_audio = inputHandle.get_user_input(filename='./wav/userSentence.wav',
            #                                                                               inputWaitTIme=10, 
            #                                                                               silence_duration=2, 
            #                                                                               silence_threshold=40)
            
            ## TEST 유저음성
            userInputIn, user_input_text, user_input_audio = True, "음악좀 틀어줘" , "./wav/userSentence.wav"
            print("userInput in")            
            ## 일정 시간동안 말 안했을떄. 아웃.
            if not userInputIn :
                ## TODO : arduino serial 신호 전송 (off / sleep)
                break
            
            ## 유저가 음성을 받았을 때
            else :
                # 쓰레드 시작
                [ev.set() for ev in [ttsEvent,convGenEvent,emoEvent,musicEvent]]

                                
                ## 분류 쓰레드
                # taskClassifier2.push_input(user_input_text)
                # taskClassifier2.start()
                # print("classifier2 start")

                # 감정분석 인풋
                emotionModel.push_input(THREAD_STATUS.RUNNING, user_input_text, user_input_audio)
                emotionModel.push_input(THREAD_STATUS.DONE, "", "")
                # 대화생성 인풋
                convGen.push_input(THREAD_STATUS.RUNNING, user_input_text)
                convGen.push_input(THREAD_STATUS.DONE, "")
                print("convGen started")

                # 유저 인풋 문자열 작업 분류
                task, arg = taskClassifier.classify(user_input_text) 
                ## 분류 쓰레드버젼
                # taskClassifier2.finish()
                # task, arg = taskClassifier2.output_queue.get()
                print("classifier done")

                # TEST input
                # task = TASK.MUSIC_RECOMMEND
                # arg = {'ctrl':MUSIC_CTRL.PLAY}

                ## 대화로 분류됐을 시 준비돼있는 오디오 출력
                ## || 완료 ||
                ## TODO : 성능향상
                if task == TASK.CONVERSATION:
                    print("task : conversation", arg)
                    playConvAudio.play_all_conv_file()
                    print("main: conv done")

                elif task == TASK.MUSIC_RECOMMEND:
                    print("task : music recommendation", arg)
                    # convGen.reset_conversation()
                    # playConvAudio.clear_input()
                    recMusic.ctrlMusic(arg['ctrl'])

                    # 노래 추천 금지
                    if arg["ctrl"] == MUSIC_CTRL.DONT_RECOMMEND :
                        recMusic.dontRecommend = True
                        musicEvent.clear()
                        ## 음악추천 쓰레드 대기모드

                    ## 지금 당장 노래 틀어주기
                    elif arg["ctrl"] == MUSIC_CTRL.RECOMMEND_NOW :
                        recMusic.dontRecommend = False
                        recMusic.ctrlMusic(MUSIC_CTRL.PLAY)
                        
                    

                ## || 완료 ||
                ## 기능은 해당 클래스에서
                elif task == TASK.MUSIC_CTRL:
                    print("task : music control", arg)
                    # convGen.reset_conversation()
                    # playConvAudio.clear_input()
                    
                    recMusic.ctrlMusic(arg["ctrl"])
                    ## delay? wait? 이야기해주기?
                    ## TODO : 
                    pass

                ## || 완료 ||                    
                elif task == TASK.IOT_CTRL:
                    print("task : IoT Control", arg)
                    convGen.reset_conversation()
                    # playConvAudio.clear_input()
                    ## TODO : 명령 인식 확인 오디오 출력.

                    res = homeCtrl.requestCtrl(arg)
                    if res == 200 :
                        print("iot조작 성공")
                    else : 
                        print("iot조작 실패")
                    # playConvAudio.clear_input()
                    
                            
            print("exit conversation cycle")
            break # TEST. 대화 사이클 while 종료
    

        print("exit main loop")
        break  # TEST. 메인 프로그램 loop 종료
    ## 대기중인 쓰레드 종료
    [ev.set() for ev in [ttsEvent,convGenEvent,emoEvent,musicEvent]]
    convGen.push_input(THREAD_STATUS.FINISH, "")
    convGen.finish()
    generateOutputAudio.finish()
    emotionModel.push_input(THREAD_STATUS.FINISH, "", "")
    emotionModel.finish()
    print("thread all clear")


if __name__ == "__main__":

    
    main()




