#flask 서버 구축

#Blueprint 모듈: 파일관리를 위한 모듈
#request: 클라이언트가 전송한 데이터를 읽고, 요청의 특성을 확인하고, 필요한 처리를 수행할 수 있다
from flask import Flask, request, Blueprint 

import pymysql #MySQL 데이터베이스와 상호 작용하기 위한 라이브러리
                                                      

from db import member #from py파일명 import 변수명 으로 Blueprint 연결한다 


# lask 애플리케이션 객체에 블루프린트를 등록하는 부분
app = Flask(__name__) # Flask 애플리케이션 객체를 생성


##Flask 애플리케이션에서 블루프린트를 등록하는 역할 -> http://172.30.1.5:8000/member/
app.register_blueprint(member, url_prefix = "/member")  
                            
@app.route('/') 
def test():
    return "Hello dbdbDeep"


@app.route('/db_test')
def db_test():
    #pymysql.connect(host, port, user, password, db스키마, charset)
    db=pymysql.connect(host='project-db-campus.smhrd.com', port = 3307, user='smhrd_dbdbDeep', password='dbdb1234!', db='smhrd_dbdbDeep', charset='utf8')


    if(db): 
        return "success" #db객체에 값이 들어가 있으면 success
    else:
        return "fail"
 


if __name__ == '__main__':
    app.run('119.200.31.99', port=8000)
    



















