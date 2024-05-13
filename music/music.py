#!/usr/bin/env python
# coding: utf-8

# # 노래 특성 뽑기

# In[47]:


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


# ### 플레이 리스트 찾기

# In[51]:


def searching_playList(input1,CLIENT_ID,CLIENT_SECRET):
    client_credentials_manager = SpotifyClientCredentials(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
    searching = input1
    playlist_link = []
    for i in range(1,10):
        playlist_results = sp.search(q=searching, type='playlist', market='KR', limit=5, offset=i)
        for i, t in enumerate(playlist_results['playlists']['items']):
            playlist_link.append(t['external_urls']['spotify'])
    return playlist_link


# In[53]:


a = searching_playList('우울',CLIENT_ID,CLIENT_SECRET)


# ### 노래 특성 뽑는 함수

# In[42]:


def get_features(song,CLIENT_ID,CLIENT_SECRET):
    client_credentials_manager = SpotifyClientCredentials(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)

    track_info = sp.search(q=song, type='track', market='KR',limit=10)
    track_id = track_info["tracks"]["items"][0]["id"]
    features = sp.audio_features(tracks=[track_id])
    
    acousticness = features[0]["acousticness"]
    danceability = features[0]["danceability"]
    energy = features[0]["energy"]
    liveness = features[0]["liveness"]
    loudness = features[0]["loudness"]
    tempo = features[0]['tempo']
    time_signature = features[0]['time_signature']
    valence = features[0]["valence"]
    mode = features[0]["mode"]

    result = {"acousticness" : acousticness,
              "danceability" : danceability,
              "energy" : energy,
              "loudness" : loudness,
              "tempo" : tempo,
              "valence" : valence
              }

    return result


# ## 메인 코드

# In[48]:


## 찐찐찐 최종
def music_main(output_path,PLAYLIST_LINK,CLIENT_ID,CLIENT_SECRET):

    # CSV 파일 저장 경로
    OUTPUT_FILE_NAME = output_path

    # Spotify 연결
    client_credentials_manager = SpotifyClientCredentials(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    session = spotipy.Spotify(client_credentials_manager=client_credentials_manager)

    # PlayList URL 
    #PLAYLIST_LINK = playlist_link[2]

    # PlayList를 match 해서 spotigy와 연결
    if match := re.match(r"https://open.spotify.com/playlist/(.*)?", PLAYLIST_LINK):
        playlist_uri = match.groups()[0]
    else:
        raise ValueError("Expected format: https://open.spotify.com/playlist/...")

    # 플레이 리스트 안에 노래들 가져오기
    tracks = session.playlist_tracks(playlist_uri)["items"]

    # # CSV 파일로 저장
    with open(OUTPUT_FILE_NAME, "w", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["track", "artist", "trackUri","acousticness", "danceability", "energy", "loudness", 
                         "tempo", "valence"])

        # 가수 , 곡명 , 노래 특성 데이터 프레임 생성
        for track in tracks:
            name = track["track"]["name"]
            artists = ", ".join([artist["name"] for artist in track["track"]["artists"]])
            trackUri = track['track']['uri']
            track_uri = track["track"]["uri"].split(":")[-1]

            # 노래의 특성 추출
            features = session.audio_features(tracks=[track_uri])
            acousticness = features[0]["acousticness"]
            danceability = features[0]["danceability"]
            energy = features[0]["energy"]
            loudness = features[0]["loudness"]
            tempo = features[0]["tempo"]
            valence = features[0]["valence"]

            # CSV 파일로 저장
            writer.writerow([name, artists,trackUri,acousticness, danceability, energy, loudness, tempo, valence])

    # 불러와서 확인
    track_playlist = pd.read_csv(OUTPUT_FILE_NAME, encoding='utf-8')
    return track_playlist


# In[ ]:


music_main(output_path,PLAYLIST_LINK,CLIENT_ID,CLIENT_SECRET)


# ## 예시 music_main('./a.csv',playlist_link[0],CLIENT_ID,CLIENT_SECRET) 

# In[1]:


## track_uri 뽑는 함수


# In[2]:


def find_track(search_artist,search_title,CLIENT_ID,CLIENT_SECRET): 

    client_credentials_manager = SpotifyClientCredentials(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
    result = sp.search(f"{search_artist} {search_title}", limit=1, type="track")
    return result['tracks']['items'][0]['uri']


# ### 원하는 노래로 재생하는 코드

# In[3]:


def music_playing(trackUri,redirectUri,CLIENT_ID,CLIENT_SECRET):

    os.system("open /Applications/Spotify.app")
    time.sleep(2)


    redirect_uri = redirectUrl
    
    scope = 'user-modify-playback-state user-read-playback-state'
    sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id=CLIENT_ID, client_secret=CLIENT_SECRET, redirect_uri=redirect_uri, scope=scope))

    print(sp)
    
    devices = sp.devices()
    device_id = None
    print(devices)
    
    if devices['devices']:
        device_id = devices['devices'][0]['id']  
    top_recommendation_uri = trackUri
    
    return sp.start_playback(device_id=device_id, uris=[top_recommendation_uri])


# In[4]:


### 찐찐찐 최종

def music_find_play(search_artist,search_title,redirectUri,CLIENT_ID,CLIENT_SECRET):
    
    client_credentials_manager = SpotifyClientCredentials(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
    sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
    
    result = sp.search(f"{search_artist} {search_title}", limit=1, type="track")
    iWant = result['tracks']['items'][0]['uri']
    os.system("open /Applications/Spotify.app")
    time.sleep(2)


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
    

