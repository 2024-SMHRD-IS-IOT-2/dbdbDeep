import threading
from threading import Event
from queue import Queue
from enum import Enum


class THREAD_STATUS(Enum):
    NONE = 0
    RUNNING = 1
    PAUSED = 2
    DONE = 3
    FINISH = 4


class Thread:
    def __init__(self, target, event: Event):
        self.target = target
        self.input_queue = Queue()
        self.output_queue = Queue()
        self.event = event
        self.status = THREAD_STATUS.NONE

    def start(self, args=()):
        self.thread = threading.Thread(target=self.target, args=args)
        self.thread.start()
        self.set_status(THREAD_STATUS.RUNNING)

    def set_status(self, status: THREAD_STATUS):
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
        self.thread.join()
