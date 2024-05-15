from common.thread import Thread, THREAD_STATUS
import os


## 오디오 생성 쓰레드
## typecast TTS
class GenerateOutputAudioThread(Thread):
    def __init__(self, event):
        super().__init__(target=self.target, event=event)

    def target(self):
        while True:
            # self.event.wait()
            if not self.input_queue.empty():
                flag, data = self.input_queue.get_nowait()
                self.set_status(flag)
                if flag == THREAD_STATUS.FINISH:
                    break
                #!TODO
                self.push_output(flag, data)

# 오디오 출력 쓰레드
## 받는 큐 : 오디오파일, 
class PlayAudioThread(Thread):
    def __init__(self, event):
        super().__init__(target=self.target, event=event)

    # 인풋 큐 비우기. 
    # 생성됐던 음성파일들 삭제
    def clear_input(self):
        while not self.input_queue.empty():
            _, data = self.input_queue.get_nowait()
            os.remove(data)

    # 쓰레드 타겟 함수
    def target(self):
        while True:
            
            self.event.wait() # 이벤트 신호를 받으면 넘어감
            if not self.input_queue.empty():
                flag, data = self.input_queue.get_nowait()
                self.set_status(flag)
                if flag == THREAD_STATUS.FINISH:
                    break
                #!TODO
