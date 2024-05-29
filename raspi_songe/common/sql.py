import os
import pymysql
import logging

class MysqlConn :
    def __init__(self, host, port, user, pwd, db) :
        self.conn = pymysql.connect(host=host,port=port, user=user, 
                            password=pwd, db=db, charset='utf8')


    ## args 튜플 형식으로
    def sqlquery(self, query, *arg) :
        result = ""
        try:
            with self.conn.cursor() as cursor:
                cursor.execute(query, arg)
                result = cursor.fetchall()
                self.conn.commit()
                cursor.close()
            logging.info("sql success")
        except:
            logging.error("sql error")
            
        return result
    

    def connClose(self):
        self.conn.close()
