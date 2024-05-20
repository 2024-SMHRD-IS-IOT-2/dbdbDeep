from common.thread import Thread, THREAD_STATUS
from tensorflow import keras
import numpy as np
from common.sql import MysqlConn
from model import getAudioFeature, getTextFeature

class EmotionModelThread(Thread):
    def __init__(self, event, user_id, conn:MysqlConn):
        super().__init__(target=self.target, event=event)
        self.conn = conn
        self.user_id = user_id

    
    # 인풋 큐 : 텍스트, wav
    # 아웃풋 큐 : 감정
    def target(self):
        while True:
            self.event.wait()
            if not self.input_queue.empty() :
                flag, txt, wav = self.input_queue.get_nowait()

                self.set_status(flag)

                if flag == THREAD_STATUS.FINISH:
                    self.push_output(flag, "")
                    print("emotionThread break")
                    break
    
                elif flag == THREAD_STATUS.DONE :
                    self.push_output(flag, "")
                    # self.event.clear()

                elif flag == THREAD_STATUS.RUNNING : 
                    emo = self.modelEnsemble(wav, txt)
                    self.emo_to_DB(emo)
                    print("emotion emo push output")
                    self.push_output(flag, emo)
                    

    # 모델로 감정 추정
    def modelEnsemble(self, user_input_audio, user_input_text):
        pred1 = getAudioFeature.getAudioOutputs(user_input_audio)
        pred2 = getTextFeature.getTextOutputs(user_input_text)
        
        pred_index = np.argmax((pred1 + pred2) / 2) #배열로 나온 각 모델의 7개 클래스 확률 값을 평균화
        emotions_list = ['Angry','Disgust','Fear','Happiness','Neutral','Sadness','Surprise']
        

        print("감정분석 완료 : ", emotions_list[pred_index])
        return emotions_list[pred_index] #평균화된 값 중 최대인 값에 해당하는 감정을 return
        # return "Angry"

    ## db 에 감정 저장
    def emo_to_DB(self, emotion):
        query = """
                    INSERT INTO TB_EMOTION (USER_ID, EMOTION_VAL) VALUES (%s, %s);
                """
        print("emotion to DB")

        res = self.conn.sqlquery(query, self.user_id, emotion)
        print("emo_to_DB result", res)
