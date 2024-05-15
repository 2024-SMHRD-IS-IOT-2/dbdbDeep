#!/usr/bin/env python
# coding: utf-8

# ## 특성 추출 하고 저장하는 함수

# In[89]:


## 음악 특성 추출 함수
def feature_mining(path):
    y, sr = librosa.load(path)
    chroma = librosa.feature.chroma_stft(y=y, sr=sr)
    audio_features = dict()
    audio_features['name'] = os.path.splitext(os.path.basename(path))[0]
    audio_features['chroma_stft_mean'] = float(chroma.mean())
    audio_features['chroma_stft_var'] = float(chroma.var())
    rms = librosa.feature.rms(y=y)
    audio_features['rms_mean'] = float(rms.mean())
    audio_features['rms_var'] = float(rms.var())
    spec_cent = librosa.feature.spectral_centroid(y=y, sr=sr)
    audio_features['spectral_centroid_mean'] = float(spec_cent.mean())
    audio_features['spectral_centroid_var'] = float(spec_cent.var())

    # 오디오 파일의 주파수 대역폭 분석
    spec_bw = librosa.feature.spectral_bandwidth(y=y, sr=sr)
    audio_features['spectral_bandwidth_mean'] = float(spec_bw.mean())
    audio_features['spectral_bandwidth_var'] = float(spec_bw.var())

    # 오디오 파일의 최상/최하 주파수의 감쇠현상 분석
    spec_rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr)
    audio_features['rolloff_mean'] = float(spec_rolloff.mean())
    audio_features['rolloff_var'] = float(spec_rolloff.var())

    # 오디오 파일의 볼륨 영교차 분석
    zero_crossing_rate = librosa.feature.zero_crossing_rate(y)
    audio_features['zero_crossing_rate_mean'] = float(zero_crossing_rate.mean())
    audio_features['zero_crossing_rate_var'] = float(zero_crossing_rate.var())

    # 오디오 파일의 하모닉 및 고조파류(수평적 요소), 타악기류(수직적 요소) 사운드 분석
    harmony, perceptr = librosa.effects.hpss(y, margin=3.0)
    audio_features['harmony_mean'] = float(harmony.mean())
    audio_features['harmony_var'] = float(harmony.var())
    audio_features['perceptr_mean'] = float(perceptr.mean())
    audio_features['perceptr_var'] = float(perceptr.var())

    tempo, _ = librosa.beat.beat_track(y=y, sr=sr)
    audio_features['tempo'] = float(tempo)
    mfcc = librosa.feature.mfcc(y=y, sr=sr)

   

    for i in range(len(mfcc)):
        mfcc_mean = 'mfcc' + str(i + 1) + '_mean'
        mfcc_var = 'mfcc' + str(i + 1) + '_var'
        audio_features[mfcc_mean] = float(mfcc[i].mean())
        audio_features[mfcc_var] = float(mfcc[i].var())

    return audio_features


# In[111]:


### 백터 저장 하는 함수
def inserting(source):   
    juhyun = []
    for i in tqdm(range(len(source))):
        juhyun.append(feature_mining(source[i]))

    juhyun = pd.DataFrame(juhyun)
    
    name = juhyun['name']
    vec = juhyun.drop('name',axis=1)
    data = vec.values.tolist()

    ids = [str(x) for x in range(len(data))]
    meta_datas = [{'text':text} for text in name]
    records = zip(ids, data, meta_datas)
    index = pc.Index('test')
    index.upsert(vectors = records)
    


# In[125]:


import os
import librosa
import pandas as pd 
from sqlalchemy import create_engine
import pymysql
from glob import glob
from tqdm import tqdm
from pinecone import Pinecone, ServerlessSpec
import time
import pandas as pd
import pprint
import csv
import os
import re
import time
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import pandas as pd
import csv
import re
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import spotipy
import os
import time
from spotipy.oauth2 import SpotifyOAuth
from selenium import webdriver
# glob.glob('path')
# insertion(source)


# ## 가중치 테이블 저장

# In[114]:


# SQL에 가중치 저장 하는 코드
def weight_emotion(value):

    conn = pymysql.connect(host=host, port=port, user=user, password=password, db=database, charset='utf8')

    engine = create_engine(f'mysql+pymysql://{user}:{password}@{host}:{port}/{database}')

    #value = pd.DataFrame(value)
    value.to_sql('TB_HAPPY', con=engine, if_exists='append', index=False)

    # 연결 및 커서 닫기
    conn.commit()
    conn.close()
    


# ## 가중치 테이블에서 값 불러와서 노래 트는 함수

# In[144]:


def music_play(emotion,secret):
    
    conn = pymysql.connect(host=host,port = port, user=user, password=password, db=database, charset='utf8')
    curs = conn.cursor()
    sql = f'select * from TB_{emotion}'
    curs.execute(sql)
    result = curs.fetchall()
    conn.commit()
    curs.close()
    conn.close()
    time.sleep(1)
    
    result = list(result)
    data = result[1:]
    
    
    response = request_pine(query=list(data),index=index)
    
    return response,print(result)
#response

def request_pine(query,index):
    results = index.query(vector=query, top_k=5, include_metadata=True)


    return [{'score': match['score'], 'text': match['metadata']['text']} for match in results['matches']]

def music_find_play(search,redirectUri,CLIENT_ID,CLIENT_SECRET):
    
    client_credentials_manager = SpotifyClientCredentials(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
    
    result = sp.search(search, limit=1, type="track")
    iWant = result['tracks']['items'][0]['uri']
    os.system("C:/Users/smhrd/AppData/Local/Microsoft/WindowsApps/Spotify.exe")
    time.sleep(3)


    redirect_uri = redirectUri
    
    scope = 'user-modify-playback-state user-read-playback-state'
    sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id=CLIENT_ID, client_secret=CLIENT_SECRET, redirect_uri=redirect_uri, scope=scope))

    print(sp)
    
    devices = sp.devices()
    device_id = None
    print(devices)
    
    if devices['devices']:
        device_id = devices['devices'][0]['id']  
    top_recommendation_uri = iWant
    
    return sp.start_playback(device_id=device_id, uris=[top_recommendation_uri])

