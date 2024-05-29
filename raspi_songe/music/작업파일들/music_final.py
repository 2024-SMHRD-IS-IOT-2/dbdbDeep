import os
import time
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
import pymysql
from sklearn.preprocessing import normalize
from spotipy import Spotify
from spotipy.oauth2 import SpotifyOAuth
from pinecone import Pinecone
from common.sql import MysqlConn
from common.thread import Thread, THREAD_STATUS
from enum import Enum


class MUSIC_CTRL(Enum):
    STOP = 0
    PAUSE = 1
    PLAY = 2
    SKIP = 3
    CUR_MUSIC_INFO = 4
    
    RECOMMEND_NOW = 5
    DONT_RECOMMEND = 6

class MusicPlayer(Thread):
    def __init__(self, event, sqlconn:MysqlConn, SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, 
                 SPOTIFY_URI, PINECONE_API_KEY, USER_ID):
        super().__init__(target=self.target, event=event)
        self.sp = SpotifyOAuth(
            client_id=SPOTIFY_CLIENT_ID,
            client_secret=SPOTIFY_CLIENT_SECRET,
            redirect_uri=SPOTIFY_URI,
            scope="user-modify-playback-state user-read-playback-state"
        )
        self.startTime = 0
        self.pauseTime = 0
        self.endTime = 0
        self.pc = Pinecone(api_key=PINECONE_API_KEY)
        self.conn = sqlconn
        self.user_id = USER_ID
        self.dontRecommend = False
        self.importantList = []
    

    # 음악 유사도 pinecone req
    ## TODO : 쓰레드 큐
    ## 인풋 큐 : flag, emotion 
    ## 아웃풋 큐 : flag, musicInfo, signal
    def target(self):
        while True :
            self.event.wait()
            if not self.input_queue.empty() :
                
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
                    query = list(map(float, result[0][2:]))

                    index = self.pc.Index("test")
                    results = index.query(vector=query, top_k=10, include_metadata=True, include_values=True)
                    
                    response = [
                        {"score": match["score"], "text": match["metadata"]["text"], "features": match['values']} 
                        for match in results["matches"]
                    ]
                    
                    important = {'music': response, 'emotion': emo, 'query': query, 'origin': result}

                    self.importantList.append(important)

                    ## TODO : important 값을 어떻게 할꺼임?

                    self.push_output(flag, "musicInfo", "signal")
                    
    
    ## 음악 컨트롤러
    def ctrlMusic(self, ctrl):
        if ctrl == MUSIC_CTRL.PAUSE :
            self.pause()
        elif ctrl == MUSIC_CTRL.PLAY :
            self.play()
        elif ctrl == MUSIC_CTRL.STOP :
            self.stop()
        elif ctrl == MUSIC_CTRL.SKIP :
            self.skip()
        elif ctrl == MUSIC_CTRL.CUR_MUSIC_INFO :
            self.get_info()


    def decideWeight(self, x, y, timer):
        standard_vector = normalize(pd.DataFrame([y]))
        recommend_vector = normalize(pd.DataFrame([x]))
        
        if timer > 120:
            result = standard_vector + (recommend_vector * 1.5)
        elif timer < 40:
            result = standard_vector + (recommend_vector * -1000)
        else:
            result = standard_vector + recommend_vector
            
        return result[0]
    
    def skip(self, emotion):
        important = self.musicVectorCalc(emotion,self.user_id)
        timer = self.sp.current_user_playing_track()
        update_value = self.decideWeight(important['music'][0]['features'], important['origin'][0][2:], timer['progress_ms'] / 1000)

        curs = self.conn.cursor()
        table_name = 'TB_MUSIC_FEATURES'
        curs.execute(f"DESCRIBE {table_name}")
        columns = [row[0] for row in curs.fetchall()]
        up_columns = columns[2:]

        update_query = f"UPDATE TB_MUSIC_FEATURES SET "
        update_query += ", ".join([f"{up_columns[i]} = {update_value[i]}" for i in range(len(up_columns))])
        update_query += f" WHERE USER_ID = '{self.user_id}' AND EMOTION_VAL = '{emotion}'"

        curs.execute(update_query)
        self.conn.commit()
        curs.close()
        self.conn.close()
        
        self.sp.next_track()
        self.play(emotion)
    
    def pause(self):
        self.sp.pause_playback()
        
    def stop(self):
        self.sp.pause_playback()

    def get_info(self):
        info = self.sp.current_user_playing_track()
        artist = info['item']['artists'][0]['name']
        title = info['item']['name']
        return artist, title
        
    def play(self, emotion):
        important = self.musicVectorCalc(emotion, self.user_id)
        result = self.sp.search(important['music'][0]['text'], limit=1, type="track")
        
        iWant = result["tracks"]["items"][0]["uri"]
        os.system("C:/Users/smhrd/AppData/Local/Microsoft/WindowsApps/Spotify.exe")
        devices = self.sp.devices()
        device_id = devices["devices"][0]["id"] if devices["devices"] else None

        self.sp.start_playback(device_id=device_id, uris=[iWant])
        
if __name__ == "__main__":
    load_dotenv("./keys.env")
    SPOTIFY_CLIENT_ID = os.environ["SPOTIFY_CLIENT_ID"]
    SPOTIFY_CLIENT_SECRET = os.environ["SPOTIFY_CLIENT_SECRET"]
    SPOTIFY_URI = os.environ["SPOTIFY_URI"]
    MYSQL_HOST = os.environ['MYSQL_HOST']
    MYSQL_PORT =os.environ['MYSQL_PORT']
    MYSQL_USER = os.environ['MYSQL_USER']
    MYSQL_PASSWORD = os.environ['MYSQL_PASSWORD']
    MYSQL_DATABASE = os.environ['MYSQL_DATABASE']
    PINECONE_API_KEY = os.environ['PINECONE_API_KEY']
    player = MusicPlayer(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_URI,MYSQL_HOST,MYSQL_PORT,
                         MYSQL_USER,MYSQL_PASSWORD,MYSQL_DATABASE,PINECONE_API_KEY)
    player.skip('happy', 'test')
