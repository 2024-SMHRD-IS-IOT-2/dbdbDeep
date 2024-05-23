from common.thread import Thread, THREAD_STATUS
from tensorflow import keras
import numpy as np
from common.sql import MysqlConn
from music.recMusic import RecMusic
from model import getFeature as gf
from pathlib import Path
import joblib
import os

class EmotionModelThread(Thread):
    def __init__(self, event, user_id, conn:MysqlConn, recMusic:RecMusic):
        super().__init__(target=self.target, event=event)
        self.conn = conn
        self.user_id = user_id
        self.recMusic = recMusic
        self.model=""
        self.scaler=""
        self.txt_embedder=""
        self.load_model()
        


    def load_model(self):
        model_path = Path('./model/model_05-0.8016.keras' ).absolute()
        scaler_path = Path('./model/sscaler_9.pkl').absolute()
        pre_trained_embed_model = 'jhgan/ko-sroberta-multitask'

        self.model = keras.models.load_model(model_path)
        self.scaler = joblib.load(scaler_path)
        self.txt_embedder = gf.text_embedding(model_name = pre_trained_embed_model)


    
    # 인풋 큐 : 텍스트, wav
    # 아웃풋 큐 : 감정
    def target(self):
        while True:
            self.event.wait()
            if not self.input_queue.empty() :
                flag, txt, wav = self.input_queue.get_nowait()
                print("emoModel: checkpoint1")
                self.set_status(flag)

                if flag == THREAD_STATUS.FINISH:
                    # self.push_output(flag, "")
                    print("emoModel: emotionThread break")
                    break
    
                elif flag == THREAD_STATUS.DONE :
                    # self.push_output(flag, "")
                    self.event.clear()

                elif flag == THREAD_STATUS.RUNNING : 
                    emo = self.modelEnsemble(wav, txt)
                    os.remove(wav)
                    self.emo_to_DB(emo)
                    print("emoModel: emotion emo push output")
                    self.recMusic.emo_2_music(emo)



    # 모델로 감정 추정
    def modelEnsemble(self, user_input_audio, user_input_text):
        audio_features = gf.extract_feature(user_input_audio)
        audio_features_realized = np.real(audio_features)   
        txt_embed = self.txt_embedder.transform(audio_features_realized,user_input_text)
        scaled_features = self.scaler.transform(txt_embed)
        result = np.expand_dims(scaled_features,axis=1)
        pred = self.model.predict(result)
        pred_index = np.argmax(pred) #배열로 나온 각 모델의 4개 클래스 확률 값을 평균화
        emotions_list = ['Angry','Happy','Neutral','Sad']
        print("emotion : ", emotions_list[pred_index])
        return emotions_list[pred_index] #평균화된 값 중 최대인 값에 해당하는 감정을 return


    ## db 에 감정 저장
    def emo_to_DB(self, emotion):
        query = """
                    INSERT INTO TB_EMOTION (USER_ID, EMOTION_VAL) VALUES (%s, %s);
                """
        res = self.conn.sqlquery(query, self.user_id, emotion)
        print("emoModel: emo_to_DB result", res)
