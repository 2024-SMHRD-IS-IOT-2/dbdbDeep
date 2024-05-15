from common.thread import Thread, THREAD_STATUS
from enum import Enum


class TASK(Enum):
    NONE = 0
    CONVERATION = 1
    IOT_CTRL = 2
    MUSIC_RECOMMEND = 3
    MUSIC_CTRL = 3


class ConvGenThread(Thread):
    def __init__(self, event):
        super().__init__(target=self.target, event=event)

    def target(self):
        while True:
            #!TODO conversation generation 처리
            if not self.input_queue.empty():
                flag, data = self.input_queue.get_nowait()
                self.set_status(flag)
                if flag == THREAD_STATUS.FINISH:
                    break
                # AI 처리
                emo = ""
                ans = ""
                
                self.push_output(flag, emo, ans)
                ##
                # self.event.wait()
                self.set_status(THREAD_STATUS.DONE)
                self.push_output(THREAD_STATUS.DONE, "", "")


class TaskClassifier:
    def __init__(self):
        pass

    def classify(self, user_input_text):
        task = TASK.NONE

        return task

    def recommend_music(self):
        return TASK.MUSIC_RECOMMEND

    def control_music(self):
        pass

    def control_iot(self):
        pass

    def conversation(self):
        return TASK.CONVERATION
