#!/usr/bin/env python
# coding: utf-8

# In[4]:


import librosa
import numpy as np
import pandas as pd
import nlpaug.augmenter.audio as naa 
from tensorflow import keras
import joblib
# from audiomentations import Compose, AddGaussianNoise, TimeStretch, PitchShift, Shift # 음성 데이터 증강용


def perceptual_sharpness(audio_path, sr=16000, n_fft=400, hop_length=160):
    # 음원 파일 로드
    y= audio_path
    sr = sr

    # STFT 수행
    D = np.abs(librosa.stft(y, n_fft=n_fft, hop_length=hop_length))

    # 주파수 대역별로 에너지 계산
    energy = np.sum(D, axis=0)

    # 고주파수 대역 성분 추출
    high_freq_energy = energy[3000:8000]  # 예시로 3000Hz에서 6000Hz 사이의 주파수 대역을 고주파수 대역으로 설정

    # Perceptual Sharpness 계산
    sharpness = np.sum(np.log1p(high_freq_energy))

    return sharpness

def extract_feature(user_input_audio):
    feature_list = []


    audio, sr = librosa.load(user_input_audio, sr=16000)
     ##Mel-spectrogram 구현
    spectrogram = librosa.stft(audio, n_fft=400, hop_length= 160) 
    power_spectrogram = spectrogram**2
    mel = librosa.feature.melspectrogram(S=power_spectrogram, sr=sr)
    mel = librosa.power_to_db(np.abs(mel)**2)
    #mfcc 구현
    mfccs = librosa.feature.mfcc(S = mel, n_mfcc=100)
    stft = np.abs(spectrogram)
    chroma_stft = librosa.feature.chroma_stft(S=stft,hop_length=160)
    rms = librosa.feature.rms(y=audio)
    spectral_centroids = librosa.feature.spectral_centroid(y=audio, sr=sr)
    spectral_bandwidths = librosa.feature.spectral_bandwidth(y=audio, sr=sr)
    spectral_rolloff = librosa.feature.spectral_rolloff(y=audio, sr=sr)
    zero_crossing_rates = librosa.feature.zero_crossing_rate(y=audio)
    chroma_cens = librosa.feature.chroma_cens(C=spectrogram, sr=sr)
    tempo, _ = librosa.beat.beat_track(y=audio, sr=sr)
    ps = perceptual_sharpness(audio)

    try:
        mfccs_mean = mfccs.mean(axis=1)
        mfccs_var = mfccs.mean(axis=1)

        for k in range(len(mfccs_mean)):
            locals()[f'mfccs_mean_{k}'] = mfccs_mean[k]
            locals()[f'mfccs_var_{k}'] = mfccs_var[k]
            chroma_stft_mean = chroma_stft.mean()
            chroma_stft_var = chroma_stft.var()
            rms_mean = rms.mean()
            rms_var = rms.var()
            spectral_centroids_mean = spectral_centroids.mean()
            spectral_centroids_var = spectral_centroids.var()
            spectral_bandwidths_mean = spectral_bandwidths.mean()
            spectral_bandwidths_var = spectral_bandwidths.var()
            spectral_rolloff_mean = spectral_rolloff.mean()
            spectral_rolloff_var = spectral_rolloff.var()
            zero_crossing_rates_mean = zero_crossing_rates.mean()
            zero_crossing_rates_var = zero_crossing_rates.var()
            harmony_mean = chroma_cens.mean()
            harmony_var = chroma_cens.var()
            tempo_mean = tempo.mean()
            tempo_var = tempo.var()
            perceptual_sharpness_mean = ps.mean()
            perceptual_sharpness_var = ps.var()
    except Exception as e:
        print(f'{i}번째 파일에서 문제 발생',e)

        #합치기
    features = np.array([])
    for j in range(len(mfccs_mean)):
        features = np.hstack((features,locals()[f'mfccs_mean_{j}'],locals()[f'mfccs_var_{j}']))

    features = np.hstack((features,chroma_stft_mean,chroma_stft_var,rms_mean,rms_var,spectral_centroids_mean
                         ,spectral_centroids_var, spectral_bandwidths_mean, spectral_bandwidths_var,spectral_rolloff_mean
                         , spectral_rolloff_var,zero_crossing_rates_mean, zero_crossing_rates_var, harmony_mean, harmony_var
                         , tempo_mean,tempo_var,perceptual_sharpness_mean,perceptual_sharpness_var))
    augmenter = naa.NoiseAug() #데이터 증강을 위해 노이즈된 특성 추가
    augmented_features = np.squeeze(augmenter.augment(features))
    features =np.hstack((features,augmented_features))

    feature_list.append(features)
    feature_array  = np.array(feature_list).reshape(-1,len(feature_list[0]))
    
    return feature_array    

def getAudioOutputs(user_input_audio):
    model_path = './model/model_11-0.4734.keras'
    scaler = joblib.load('./scaler/rscaler.pkl')
    model = keras.models.load_model(model_path)
    audio_features = extract_feature(user_input_audio)
    audio_features_realized = np.real(audio_features)
    scaled_audio_features_realized = scaler.transform(audio_features_realized)
    result = np.expand_dims(scaled_audio_features_realized,axis=1)
    result = model.predict(result)[0]
    return result
