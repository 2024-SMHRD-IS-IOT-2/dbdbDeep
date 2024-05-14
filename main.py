from raspi_home.taskClassifier import TaskClassifier, ConvGenThread, TASK
from raspi_home.outputHandler import GenerateOutputAudioThread, PlayAudioThread
from raspi_home.inputHandler import InputHandler
from model.emotionModel import EmotionModelThread
from threading import Event
from common.thread import THREAD_STATUS


def main():
    event = Event()
    inputHandle = InputHandler()  ## micInput.py 했던것들
    taskClassifier = TaskClassifier()  ## 분류 모델 객체
    convGen = ConvGenThread(event)  ## 대화 모델 객체
    generateOutputAudio = GenerateOutputAudioThread(event) ## 오디오 생성 쓰레드 객체
    playAudio = PlayAudioThread(event)  ## 오디오 출력

    emotionModel = EmotionModelThread(event)

    convGen.set_output_queue(generateOutputAudio.input_queue)
    generateOutputAudio.set_output_queue(playAudio.input_queue)

    convGen.start()
    emotionModel.start()
    generateOutputAudio.start()
    playAudio.start()

    isRunning = True
    # isProcessUserInput = False
    event.clear()

    while isRunning:
        while True:
            if inputHandle.recognize_keyword(): # 안에서 while 로.
                isProcessUserInput = True
                break

        # while isProcessUserInput:

        user_input_text, user_input_audio = inputHandle.get_user_input()

        # 모델에 넣어서 쓰레드로 
        emotionModel.push_input(THREAD_STATUS.RUNNING, user_input_text, user_input_audio)
        convGen.push_input(THREAD_STATUS.RUNNING, user_input_text)


        # 분류
        task = taskClassifier.classify(user_input_text) 


        if task == TASK.CONVERATION:
            event.set()
            while playAudio.get_status() == THREAD_STATUS.RUNNING:
                pass
            event.clear()

        elif task == TASK.MUSIC_RECOMMEND:
            while emotionModel.get_status() == THREAD_STATUS.RUNNING:
                pass
            flag, music_file = emotionModel.output_queue.get_nowait()
            #! TODO music_file 재생

        ### elif 스마트홈 컨트롤
        ## elif 유저시나리오 음악 조작

        # isProcessUserInput = False
        # isRunning = False
        # break

    # convGen.push_input(THREAD_STATUS.FINISH, "")
    # convGen.finish()
    # generateOutputAudio.finish()
    # playAudio.finish()
    # emotionModel.finish()


if __name__ == "__main__":
    main()
