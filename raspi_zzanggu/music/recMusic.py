import pandas as pd
from sklearn.preprocessing import normalize
from pinecone import Pinecone
from common.sql import MysqlConn
from common.thread import Thread, THREAD_STATUS
from enum import Enum
from music.musicPlayer import MusicPlayer

class MUSIC_CTRL(Enum):
    STOP = 0
    PAUSE = 1
    PLAY = 2
    SKIP = 3
    CUR_MUSIC_INFO = 4
    RECOMMEND_NOW = 5
    DONT_RECOMMEND = 6

class RecMusic:
    def __init__(self, PINECONE_API_KEY,sqlconn:MysqlConn,music_player:MusicPlayer,user_id):
        self.pc = Pinecone(api_key=PINECONE_API_KEY)
        self.conn = sqlconn
        self.response_list = []
        self.emo2play = []
        self.music_player = music_player
        self.user_id = user_id
        self.dontRecommend = False
        self.idx = 0

    def emo_2_music(self,emo):
        query = "SELECT * FROM TB_MUSIC_FEATURES WHERE USER_ID = %s AND EMOTION_VAL = %s"
        result = self.conn.sqlquery(query,self.user_id,emo)
        result = list(result)
        
        input_vectorDB = list(map(float, result[0][2:]))
                    
        index = self.pc.Index('test')
        results = index.query(vector=input_vectorDB, top_k =10, include_metadata=True,include_values=True)
                    # 감정에 따른 노래 추천(제목, 특성) == response
        res = [
                        {"title": res['metadata']['text'], "features": res['values']} for res in results['matches']
                    ]
        response = {'music': res, 'origin' : result, 'emotion': emo}
        self.response_list.append(response)
        
#         print("리스폰스 리스트 길이: ", len(self.response_list))
                     
    def isMusicReady(self):
        print("isMusicReady???")
        print("test:", self.dontRecommend, len(self.response_list))
        temp = self.music_player.sp.current_user_playing_track()
        if not self.dontRecommend and len(self.response_list) > 1 and temp != None and not temp['is_playing']:
            return True
        else:
            return False
        

    def ctrlMusic(self, arg):
        
        ctrl = arg['ctrl']

        if ctrl == "replay" :
            self.music_player.replay()
        elif ctrl == "play" :
            self.dontRecommend = False
            emo = "Neutral" if len(self.response_list) == 0 else self.response_list[0]['emotion']
            self.emo_2_music(emo)
            emotions = [self.response_list[i]['emotion'] for i in range(len(self.response_list))]
            max_emo = max(emotions,key=emotions.count)
            self.emo2play.append(list(filter(lambda x : x['emotion']==max_emo,self.response_list)))
            self.music_player.play(self.emo2play[0])
            self.response_list = []
        elif ctrl == "stop" :
            self.music_player.stop()
        elif ctrl == "skip" :
            self.updateWeight(self.emo2play[0])
            self.music_player.skip()  
        elif ctrl =="dontRecommend":
            self.dontRecommend = True
            self.music_player.stop()
        elif ctrl == "userWant":
            try:
                self.updateWeight(self.emo2play[0])
                searching = f"{arg['artist']},{arg['song']}"
                self.music_player.user_want(searching)
            except:
                print("님이 원하는 노래는 없으셈")
        elif ctrl == "previous":
            self.music_player.previous()
        elif ctrl == "volumn_up" or "volumn_down":
            if ctrl == "volumn_up":
                self.music_player.volume('up')
            elif ctrl == "volumn_down":
                self.music_player.volume('down')
    def updateWeight(self,response_list):
        if self.music_player != None:
            if len(response_list) != 0:
                standard_vector = normalize(pd.DataFrame(tuple(response_list[0]['music'][self.idx]['features'])).T)
                recommend_vector = normalize(pd.DataFrame(response_list[0]['origin'][0][2:]).T)
                if self.music_player.current_timer() < 60:
                    result = standard_vector + (recommend_vector * -1.5)
                    self.update_query(result)
                elif self.music_player.current_timer() > 130:
                    result = standard_vector + (recommend_vector * 1.5)
                    self.update_query(result)
                if len(response_list) <= self.idx:
                    self.idx += 1
                    self.idx = 0
    def update_query(self,result):
        update_value = result
        columns = [row[0] for row in self.conn.sqlquery(f'DESCRIBE TB_MUSIC_FEATURES')]
        up_columns = columns[2:]
        update_query = f"UPDATE TB_MUSIC_FEATURES SET "
        update_query += ", ".join([f"{up_columns[i]} = {update_value[0][i]}" for i in range(len(up_columns))])
        update_query += f" WHERE USER_ID = '{self.user_id}' AND EMOTION_VAL = '{self.emo2play[0][0]['emotion']}'"
        self.conn.sqlquery(update_query)
        
