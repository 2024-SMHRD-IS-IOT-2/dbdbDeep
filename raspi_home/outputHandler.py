from common.thread import Thread, THREAD_STATUS


class GenerateOutputAudioThread(Thread):
    def __init__(self, event):
        super().__init__(target=self.target, event=event)

    def target(self):
        while True:
            self.event.wait()
            if not self.input_queue.empty():
                flag, data = self.input_queue.get_nowait()
                self.set_status(flag)
                if flag == THREAD_STATUS.FINISH:
                    break
                #!TODO
                self.push_output(flag, data)


class PlayAudioThread(Thread):
    def __init__(self, event):
        super().__init__(target=self.target, event=event)

    def target(self):
        while True:
            self.event.wait()
            if not self.input_queue.empty():
                flag, data = self.input_queue.get_nowait()
                self.set_status(flag)
                if flag == THREAD_STATUS.FINISH:
                    break
                #!TODO
