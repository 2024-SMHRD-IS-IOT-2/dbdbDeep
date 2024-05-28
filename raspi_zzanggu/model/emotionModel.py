from common.process import MyProcess, PROCESS_STATUS
from tensorflow import keras
import numpy as np
from model import getFeature as gf
from pathlib import Path
from multiprocessing import Queue

import joblib
import os
import logging
import time



class EmotionModelProcess(MyProcess):
    def __init__(self):
        super().__init__(target=self.target)


    
    # 인풋 큐 : 텍스트, wav
    def target(self, emo2rec_q:Queue):
        model_path = Path('./model/model_05-0.8016.keras' ).absolute()
        scaler_path = Path('./model/sscaler_9.pkl').absolute()
        pre_trained_embed_model = 'jhgan/ko-sroberta-multitask'

        model = keras.models.load_model(model_path)
        scaler = joblib.load(scaler_path)
        txt_embedder = gf.text_embedding(model_name = pre_trained_embed_model)

        while True:
            if not self.input_queue.empty() :
                data = self.input_queue.get_nowait()
                if len(data) == 4 :
                    startTime, flag, txt, wav = data
                else :
                    flag, txt, wav = data

                self.set_status(flag)
                if flag == PROCESS_STATUS.FINISH:
                    print("emoModel: EmotionProcess break")
                    break
    
                elif flag == PROCESS_STATUS.DONE :
                    pass

                elif flag == PROCESS_STATUS.RUNNING : 
                    emo = self.modelEnsemble(model, scaler, txt_embedder, wav, txt)
                    endTime = time.time()
                    logging.error(f"TIME emo : {(endTime-startTime):.2f} second")
                    os.remove(wav)
                    print("emoModel: file removed", wav)
                    emo2rec_q.put(emo)



    # 모델로 감정 추정
    def modelEnsemble(self, model, scaler, txt_embedder, user_input_audio, user_input_text):
        audio_features = gf.extract_feature(user_input_audio)
        audio_features_realized = np.real(audio_features)   
        txt_embed = txt_embedder.transform(audio_features_realized,user_input_text)
        scaled_features = scaler.transform(txt_embed)
        result = np.expand_dims(scaled_features,axis=1)
        pred = model.predict(result)
        pred_index = np.argmax(pred) #배열로 나온 각 모델의 4개 클래스 확률 값을 평균화
        emotions_list = ['Angry','Happy','Neutral','Sad']

        print("emoModel: emotion predicted", emotions_list[pred_index])
        return emotions_list[pred_index] #평균화된 값 중 최대인 값에 해당하는 감정을 return
