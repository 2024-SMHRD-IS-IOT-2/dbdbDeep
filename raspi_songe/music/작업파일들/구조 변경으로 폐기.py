import os
import time

from sqlalchemy import create_engine
import pymysql
import pandas as pd

from spotipy import Spotify
from spotipy.oauth2 import SpotifyOAuth
from pinecone import Pinecone
from common.sql import MysqlConn
from common.thread import Thread, THREAD_STATUS
from enum import Enum
import webbrowser

from musicPlayer import MusicPlayer


    
class MUSIC_CTRL(Enum):
    STOP = 0
    PAUSE = 1
    PLAY = 2
    SKIP = 3
    CUR_MUSIC_INFO = 4
    RECOMMEND_NOW = 5
    DONT_RECOMMEND = 6




class RecMusic(Thread):
    def __init__(self,target,event:Event,PINECONE_API_KEY,sqlconn:MysqlConn,music_player:MusicPlayer,user_id):

        super().__init__(target,event)
        self.pc = Pinecone(api_key=PINECONE_API_KEY)
        self.conn = sqlconn
        self.response_list = []
        self.music_player = music_player
        self.user_id = user_id

        self.dontRecommend = False
        

    def musicVectorCals(self):
        while True:
            self.event.wait()
            if not self.input_queue.get_nowait():
                flag, emo = self.input_queue.get_nowait()
                
                if flag == THREAD_STATUS.FINISH:
                    self.push_output(flag, "","")
                    print("musicThread break")
                    break
                elif flag == THREAD_STATUS.DONE:
                    self.push_output(flag, "","")

                elif flag == THREAD_STATUS.RUNNING: 
                    
                    query = f"SELECT * FROM TB_MUSIC_FEATURES WHERE USER_ID = 
                            '{self.user_id}' AND EMOTION_VAL = '{emo}'"
                    result = self.conn(query, self.user_id, emo)
                    
                    result = list(result)
                    input_vectorDB = list(map(float, result[0][2:]))
                    
                    index = self.pc.Index('test')
                    results = index.query(vector=input_vectorDB, top_k =5, include_metadata=True,include_values=True)
                    # 감정에 따른 노래 추천(제목, 특성) == response
                    res = [
                        {"title": res['metadata']['text'], "features": res['values']} for res in results['matches']
                    ]
                    response = {'music': res, 'origin' : result}
                    self.response_list.append(response)

    def getList(self):
        return self.response_list
    
    def isMusicReady(self):
        if len(self.response_list) > 10:
            return True
        else:
            return False
    def ctrlMusic(self, ctrl):
        if ctrl == MUSIC_CTRL.PAUSE :
            self.music_player.pause()
        elif ctrl == MUSIC_CTRL.PLAY :
            self.music_player.play(self.response_list[0]['music'][0]['text'])
        elif ctrl == MUSIC_CTRL.STOP :
            self.music_player.stop()
        elif ctrl == MUSIC_CTRL.SKIP :

            self.weight()
            self.music_player.skip()
        elif ctrl == MUSIC_CTRL.CUR_MUSIC_INFO :
            self.music_player.get_info()    
            
            
    
    def updateWeight(self,emo):

        if self.music_player != None:
            if type(self.music_player) == float:
                standard_vector = normalize(pd.DataFrame([self.response_list['music'][0]['features']]))
                recommend_vector = normalize(pd.DataFrame([self.response_list['origin'][0][2:]]))
                if self.music_player < 60:
                    result = standard_vector + (recommend_vector * -10)
                else:
                    pass
            update_value = result[0]

            up_columns = self.conn(f'DESCRIBE {table_name}','TB_MUSIC_FEATURES')
            update_query = f"UPDATE TB_MUSIC_FEATURES SET "
            update_query += ", ".join([f"{up_columns[i]} = {update_value[i]}" for i in range(len(up_columns))])
            update_query += f" WHERE USER_ID = '{self.user_id}' AND EMOTION_VAL = '{emotion}'"
    

    
class MusicPlayer() :
    def __init__(self,SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_URI):

        self.sp = Spotify(SpotifyOAuth(
            client_id=SPOTIFY_CLIENT_ID,
            client_secret=SPOTIFY_CLIENT_SECRET,
            redirect_uri=SPOTIFY_URI,
            scope="user-modify-playback-state user-read-playback-state"
        ))

        up_columns = self.conn(f'DESCRIBE TB_MUSIC_FEATURES')
        update_query = f"UPDATE TB_MUSIC_FEATURES SET "
        update_query += ", ".join([f"{up_columns[i]} = {update_value[i]}" for i in range(len(up_columns))])
        update_query += f" WHERE USER_ID = '{self.user_id}' AND EMOTION_VAL = '{emo}'"

        self.conn(update_query)

class MUSIC_CTRL(Enum):
    STOP = 0
    PAUSE = 1
    PLAY = 2
    SKIP = 3
    CUR_MUSIC_INFO = 4
    RECOMMEND_NOW = 5
    DONT_RECOMMEND = 6
    
# class MusicPlayer() :
#     def __init__(self,event,SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_URI):
#         super().__init__(target=self.traget, event = event)
#         self.sp = Spotify(SpotifyOAuth(
#             client_id=SPOTIFY_CLIENT_ID,
#             client_secret=SPOTIFY_CLIENT_SECRET,
#             redirect_uri=SPOTIFY_URI,
#             scope="user-modify-playback-state user-read-playback-state"
#         ))


    def skip(self):
        self.sp.next_track()
        timer = self.sp.current_user_playing_track()
        time = timer['progress_ms'] / 1000
        return time
    def play(self,title):
        result = self.sp.search(title,limit=1,type='track')
        play_track = result['track']['items'][0]['uri']
        webbrowser.open_new('https://open.spotify.com/?pwa=1')
        devices = self.sp.devices()
        device_id = None
        if devices['devices']:
            device_id = devices['devices'][0]['id']
        self.sp.start_playback(device_id=device_id,uris = play_track)
    def pause(self):
        self.sp.pause_playback()
    def stop(self):
        self.sp.pause_playback()
    def get_info(self):
        info = self.sp.current_user_playing_track()
        artist = info['item']['artists'][0]['name']
        title = info['item']['name']
        return artist, title

#     def skip(self):
#         self.sp.next_track()
#         timer = self.sp.current_user_playing_track()
#         time = timer['progress_ms'] / 1000
#         return time
#     def play(self,title):
#         result = self.sp.search(title,limit=1,type='track')
#         play_track = result['track']['items'][0]['uri']
#         webbrowser.open_new('https://open.spotify.com/?pwa=1')
#         devices = self.sp.devices()
#         device_id = None
#         if devices['devices']:
#             device_id = devices['devices'][0]['id']
#         self.sp.start_playback(device_id=device_id,uris = play_track)
#     def pause(self):
#         self.sp.pause_playback()
#     def stop(self):
#         self.sp.pause_playback()
#     def get_info(self):
#         info = self.sp.current_user_playing_track()
#         artist = info['item']['artists'][0]['name']
#         title = info['item']['name']
#         return artist, title

