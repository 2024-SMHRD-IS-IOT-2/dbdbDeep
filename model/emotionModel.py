from common.thread import Thread, THREAD_STATUS


class EmotionModelThread(Thread):
    def __init__(self, event):
        super().__init__(target=self.target, event=event)

    def target(self):
        flag, data = self.input_queue.get_nowait()
        self.set_status(flag)
        #! TODO model에서 data 처리

        music_file = ""
        self.set_status(THREAD_STATUS.DONE)
        self.push_output(THREAD_STATUS.DONE, music_file)
