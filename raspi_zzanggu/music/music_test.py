import os
import time
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
import pymysql
from tqdm import tqdm
from sklearn.preprocessing import normalize
from spotipy import Spotify
from spotipy.oauth2 import SpotifyOAuth
from pinecone import Pinecone
import re

class MusicPlayer:
    def __init__(self, SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_URI):
        self.SPOTIFY_CLIENT_ID = SPOTIFY_CLIENT_ID
        self.SPOTIFY_CLIENT_SECRET = SPOTIFY_CLIENT_SECRET
        self.SPOTIFY_URI = SPOTIFY_URI
        self.MYSQL
        self.startTime = 0
        self.pauseTime = 0
        self.endTime = 0
        self.sp = self.authenticate_spotify()
    
    def authenticate_spotify(self):
        auth_manager = SpotifyOAuth(
            client_id=self.SPOTIFY_CLIENT_ID,
            client_secret=self.SPOTIFY_CLIENT_SECRET,
            redirect_uri=self.SPOTIFY_URI,
            scope="user-modify-playback-state user-read-playback-state"
        )
        return Spotify(auth_manager=auth_manager)
    
    def musicVectorCalc(self, emotion,user_id):
        MYSQL_HOST = os.environ["MYSQL_HOST"]
        MYSQL_PORT = int(os.environ["MYSQL_PORT"])
        MYSQL_USER = os.environ["MYSQL_USER"]
        MYSQL_PASSWORD = os.environ["MYSQL_PASSWORD"]
        MYSQL_DATABASE = os.environ["MYSQL_DATABASE"]

        conn = pymysql.connect(
            host=MYSQL_HOST,
            port=MYSQL_PORT,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            db=MYSQL_DATABASE,
            charset="utf8",
        )
        curs = conn.cursor()
        sql = f"SELECT * FROM TB_MUSIC_FEATURES WHERE USER_ID = '{user_id}' AND EMOTION_VAL = '{emotion}'"
        curs.execute(sql)
        result = curs.fetchall()
        conn.commit()
        curs.close()
        conn.close()

        result = list(result)
        query = list(map(float, result[0][2:]))

        PINECONE_API_KEY = os.environ["PINECONE_API_KEY"]
        pc = Pinecone(api_key=PINECONE_API_KEY)
        index = pc.Index("test3")
        results = index.query(vector=query, top_k=10, include_metadata=True, include_values=True)
        
        response = [
            {"score": match["score"], "text": match["metadata"]["text"], "features": match['values']} 
            for match in results["matches"]
        ]
        
        important = {'music': response, 'emotion': emotion, 'query': query, 'origin': result}
        return important
    
    def ctrlMusic(self, ctrl):
        if ctrl == '멈춰':
            self.pause()
        elif ctrl == '실행해줘':
            self.play()
        elif ctrl == '스탑':
            self.stop()
        elif ctrl == '다음':
            self.skip()
            
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
    
    def skip(self, emotion, user_id):
        important = self.musicVectorCalc(emotion,user_id)
        timer = self.sp.current_user_playing_track()
        update_value = self.decideWeight(important['music'][0]['features'], important['origin'][0][2:], timer['progress_ms'] / 1000)

        MYSQL_HOST = os.environ["MYSQL_HOST"]
        MYSQL_PORT = int(os.environ["MYSQL_PORT"])
        MYSQL_USER = os.environ["MYSQL_USER"]
        MYSQL_PASSWORD = os.environ["MYSQL_PASSWORD"]
        MYSQL_DATABASE = os.environ["MYSQL_DATABASE"]

        conn = pymysql.connect(
            host=MYSQL_HOST,
            port=MYSQL_PORT,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            database=MYSQL_DATABASE
        )

        curs = conn.cursor()
        table_name = 'TB_MUSIC_FEATURES'
        curs.execute(f"DESCRIBE {table_name}")
        columns = [row[0] for row in curs.fetchall()]
        up_columns = columns[2:]

        update_query = f"UPDATE {table_name} SET "
        update_query += ", ".join([f"{up_columns[i]} = {update_value[i]}" for i in range(len(up_columns))])
        update_query += f" WHERE USER_ID = '{user_id}' AND EMOTION_VAL = '{emotion}'"

        curs.execute(update_query)
        conn.commit()
        curs.close()
        conn.close()
        
        self.sp.next_track()
        self.play(emotion,user_id)
    
    def pause(self):
        self.sp.pause_playback()
        
    def stop(self):
        self.sp.pause_playback()
        
    def play(self, emotion,user_id):
        important = self.musicVectorCalc(emotion,user_id)
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

    player = MusicPlayer(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_URI)
    player.skip('happy', 'test')
