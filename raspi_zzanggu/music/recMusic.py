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

class RecMusic(Thread):
    def __init__(self, event,PINECONE_API_KEY,sqlconn:MysqlConn,music_player:MusicPlayer,user_id):
        super().__init__(target=self.musicVectorCals,event=event)
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
                    self.event.clear()

                elif flag == THREAD_STATUS.RUNNING: 
                    
                    query = f'SELECT * FROM TB_MUSIC_FEATURES WHERE USER_ID = "{self.user_id}" AND EMOTION_VAL = "{emo}"'
                    result = self.conn(query, self.user_id, emo)
                    
                    result = list(result)
                    input_vectorDB = list(map(float, result[0][2:]))
                    
                    index = self.pc.Index('test')
                    results = index.query(vector=input_vectorDB, top_k =5, include_metadata=True,include_values=True)
                    # 감정에 따른 노래 추천(제목, 특성) == response
                    res = [
                        {"title": res['metadata']['text'], "features": res['values']} for res in results['matches']
                    ]
                    response = {'music': res, 'origin' : result, 'emotion': emo}
                    self.response_list.append(response)
    def just_music(self,emo):
        query = "SELECT * FROM TB_MUSIC_FEATURES WHERE USER_ID = %s AND EMOTION_VAL = %s"
        result = self.conn.sqlquery(query,self.user_id,emo)
        result = list(result)
        print(result)
        input_vectorDB = list(map(float, result[0][2:]))
                    
        index = self.pc.Index('test')
        results = index.query(vector=input_vectorDB, top_k =5, include_metadata=True,include_values=True)
                    # 감정에 따른 노래 추천(제목, 특성) == response
        res = [
                        {"title": res['metadata']['text'], "features": res['values']} for res in results['matches']
                    ]
        response = {'music': res, 'origin' : result, 'emotion': emo}
        self.response_list.append(response)
                     
         
    def getList(self):
        return self.response_list
    
    def isMusicReady(self):
        if not self.dontRecommend and len(self.response_list) > 10:
            return True
        else:
            return False
    def ctrlMusic(self, ctrl):
        print("ctrlMusic : In",ctrl)

        if ctrl == MUSIC_CTRL.PAUSE :
            print("ctrlMusic:Pause", ctrl)
            self.music_player.pause()
            print("ctrlMusic:Pause", ctrl)
        elif ctrl == 2 :
            print("ctrlMusic:Play", ctrl)
            self.just_music('Neutral')
            self.music_player.play(self.response_list[0]['music'][0]['title'])
        elif ctrl == MUSIC_CTRL.STOP :
            print("ctrlMusic:Stop", ctrl)
            self.music_player.stop()
        elif ctrl == MUSIC_CTRL.SKIP :
            print("ctrlMusic:Skip", ctrl)
            self.music_player.skip()
            self.updateWeight()
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
            up_columns = self.conn(f'DESCRIBE TB_MUSIC_FEATURES')
            update_query = f"UPDATE TB_MUSIC_FEATURES SET "
            update_query += ", ".join([f"{up_columns[i]} = {update_value[i]}" for i in range(len(up_columns))])
            update_query += f" WHERE USER_ID = '{self.user_id}' AND EMOTION_VAL = '{emo}'"

            self.conn(update_query)
