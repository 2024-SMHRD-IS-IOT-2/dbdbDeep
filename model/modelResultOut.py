import numpy as np
import getFeature as gf
from tqdm.auto import tqdm
from tensorflow import keras
import joblib

def load_model():
    model_path = './model/model_05-0.8016.keras' 
    model = keras.models.load_model(model_path)
    scaler = joblib.load('./scaler/sscaler_9.pkl')
    pre_trained_embed_model = 'jhgan/ko-sroberta-multitask'
    txt_embedder = gf.text_embedding(model_name = pre_trained_embed_model)

def modelResult(user_input_audio,user_input_text):
    audio_features = gf.extract_feature(user_input_audio)
    audio_features_realized = np.real(audio_features)   
    txt_embed = txt_embedder.transform(audio_features_realized,user_input_text)
    scaled_features = scaler.transform(txt_embed)
    result = np.expand_dims(scaled_features,axis=1)
    pred = model.predict(result)
    pred_index = np.argmax(pred) #배열로 나온 각 모델의 4개 클래스 확률 값을 평균화
    emotions_list = ['Angry','Happiness','Neutral','Sadness']
    return emotions_list[pred_index] #평균화된 값 중 최대인 값에 해당하는 감정을 return




