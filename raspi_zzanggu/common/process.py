from queue import Queue
from enum import Enum
from multiprocessing import Queue, Process, Event


class PROCESS_STATUS(Enum):
    NONE = 0
    RUNNING = 1
    PAUSED = 2
    DONE = 3
    RESET = 4
    FINISH = 5


class MyProcess:
    def __init__(self, target):
        self.target = target
        self.input_queue = Queue()
        self.output_queue = Queue()
        self.status = PROCESS_STATUS.NONE

    def start(self, *args):
        self.p = Process(target=self.target, args=args)
        self.p.start()
        self.set_status(PROCESS_STATUS.RUNNING)

    def set_status(self, status: PROCESS_STATUS):
        self.status = status

    def get_status(self):
        return self.status

    def set_input_queue(self, input_queue):
        self.input_queue = input_queue

    def set_output_queue(self, output_queue):
        self.output_queue = output_queue

    def push_input(self, *args):
        self.input_queue.put(args)

    def push_output(self, *args):
        self.output_queue.put(args)

    def finish(self):
        self.p.join()
