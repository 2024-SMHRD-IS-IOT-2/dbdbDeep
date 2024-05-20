from common.thread import Thread, THREAD_STATUS
from tensorflow import keras
import numpy as np
from common.sql import MysqlConn


class EmotionModelThread(Thread):
    def __init__(self, event, user_id, emo_text_model, emo_wav_model, conn:MysqlConn):
        super().__init__(target=self.target, event=event)
        # self.emo_text_model = keras.models.load_model(emo_text_model)
        # self.emo_wav_model = keras.models.load_model(emo_wav_model)
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
                    self.event.clear()

                elif flag == THREAD_STATUS.RUNNING : 
                    emo = self.modelEnsemble(txt, wav)
                    self.emo_to_DB(emo)
                    self.push_output(flag, emo)
                    

    # 모델로 감정 추정
    def modelEnsemble(self, user_input_text, user_input_audio):

        # pred1 = self.emo_text_model.predict_proba(user_input_text)
        # pred2 = self.emo_wav_model.predict_proba(user_input_audio)
        
        # pred_index = np.argmax((pred1 + pred2) / 2) #배열로 나온 각 모델의 7개 클래스 확률 값을 평균화
        # emotions_list = ['Angry','Disgust','Fear','Happiness','Neutral','Sadness','Surprise']
        
        # return emotions_list[pred_index] #평균화된 값 중 최대인 값에 해당하는 감정을 return
        print("감정 분석 모델")
        return "Angry"

    ## db 에 감정 저장
    def emo_to_DB(self, emotion):
        query = """
                    INSERT INTO TB_EMOTION (USER_ID, EMOTION_VAL) VALUES (%s, %s);
                """
        print("emotion to DB")

        # self.conn.sqlquery(query, self.user_id, emotion)
