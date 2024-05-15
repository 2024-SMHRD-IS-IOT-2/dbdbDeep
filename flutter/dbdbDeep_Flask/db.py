import pymysql
from flask import Blueprint, request
import json


# 해당데이터를 접근하기 위해서 Blueprint를 사용, Blueprint를 통해서 해당 파일의 이름을 지정해준다 
member = Blueprint("member", __name__, template_folder="templates") 


#첫번째 라우트를 member로 지정
@member.route('/')
def test():
    return "Hello dbdbDeep member"


#-------------------------------------------------------------------------------------------------------------------

#회원가입기능 
@member.route('/join') 
def join():
    #1. db연결하기
    db=pymysql.connect(host='project-db-campus.smhrd.com', port = 3307, user='smhrd_dbdbDeep', password='dbdb1234!', db='smhrd_dbdbDeep', charset='utf8')

    if(db):
        print("success")
    else:
        print("fail") 


    #id, pw, age, name 데이터를 받는다 
    # 받는쪽에서 데이터탑입을 수정한다  -- age타입을 flutter쪽에서 int로 보냈어도 String으로 받게 된다 
    id = request.args.get('id')
    pw = request.args.get('pw')
    name = request.args.get('name')
    addr = request.args.get('addr')
    tel = request.args.get('tel')
    nick = request.args.get('nick')
    birth = request.args.get('birth')


    #2.데이터 접근하기 위해서 cursor 객체 사용
    cursor = db.cursor()


    #3. sql문 작성하기 
    # pymysql 포매팅 방식을 사용 -> %(변수명)s
    sql = 'insert into TB_USERS values(%(id)s, %(pw)s, %(name)s, %(addr)s, %(tel)s, %(nick)s, %(birth)s, NOW())'


    #4. sql문 실행하는 코드 
    # execute(sql문장, dic구조)
    cursor.execute(sql,{'id':id, 'pw':pw, 'name':name, 'addr':addr, 'tel':tel, 'nick':nick, 'birth':birth})


    #4.5 정상으로 실행되었는지 확인하기 
    #성공한 줄의 개수가 리턴된다
    row = cursor.rowcount

    #5. commit 하기: 변경 사항을 commit()을 통해 영구적으로 저장
    db.commit()

    #6. db 닫아주기
    db.close()
    
    if row > 0 : # 0보다 큰양수이면 성공적으로 들어간것이 된다 
        return "success"
    else :
        return "fail"
    
#-------------------------------------------------------------------------------------------------------------------    

#회원정보수정 
@member.route('/update')
def update():
    # 값 받기 
    id = request.args.get('id')
    pw = request.args.get('pw')
    # ↓ age는 db상 int, 받아주는 쪽에서 int로 형변환을 한다 
    age = int(request.args.get('age')) 
    name = request.args.get('name')

    #1.db연결
    db=pymysql.connect(host='project-db-campus.smhrd.com', port = 3307, user='smhrd_dbdbDeep', password='dbdb1234!', db='smhrd_dbdbDeep', charset='utf8')

    #2. 데이터 접근 할 수 있는  cusor객체생성하기 
    # cusor객체는 pymysql에 connect가 완료된 db변수 안에 있다 
    cursor = db.cursor()

    #3. sql문 작성하기 
    sql = "update member set pw = %(pw)s, age = %(age)s, name = %(name)s where id = %(id)s"

    #4. sql문 실행하기 
    cursor.execute(sql, {'id':id, 'pw':pw, 'age':age, 'name':name}) 

    #4.5. rowcount 받기 
    # rowcount는 실행된 SQL 문에 의해 영향을 받은 행의 수를 반환한다 -> 이를통해 sql문의 실행결과를 확인 할 수 있다 
    row = cursor.rowcount

    #5. commit하기 close하기
    db.commit()
    db.close()


    if row > 0 : # row가 양수이면 success 아니면 fail  
        return "success db"
    else :
        return "fail"


#-------------------------------------------------------------------------------------------------------------------

#로그인기능 
@member.route("/login") 
def login():
    #1.db 접속
    db=pymysql.connect(host='project-db-campus.smhrd.com', port = 3307, user='smhrd_dbdbDeep', password='dbdb1234!', db='smhrd_dbdbDeep', charset='utf8')

    #2.데이터 접근
    cursor = db.cursor()

    #받은 데이터들을 변수로 초기화하기 
    id = request.args.get('id')
    pw = request.args.get('pw')
    
    # 3.sql문 작성하기 
    sql = "select * from TB_USERS where USER_ID = %(id)s and USER_PW = %(pw)s"


    # 4. sql문 실행-- sql문 실행하는 코드는 cursor객체
    cursor.execute(sql, {'id':id, 'pw':pw})

    #5. 값 받아주기 - fetchall(), fetchone(), fetchmany()
    # fetchall() - 모든 행 데이터 가지고 오기 
    # fetchone() - 하나의 행만 가져오기 
    # fetchmany(정수n) - n개의 데이터 가져오기 

    # fetchall사용하기
    

    result = cursor.fetchall()
    # ↓
    # fetchall사용하면 가지고 오는 형식은 튜플로 가지고 오게된다
    # 튜플로 가지고온 데이터는 return을 할 수 없다 -> 튜플로 가지고온 데이터를 -> Json으로 변환한다 
    # --> json으로 변환해서 return 한 후 플러터 쪽에서 파싱한다 
   
    # json으로 파싱하기 위해서 json import한다 예) import json 
    # json은 기본적으로 key와 value로 구성되어 있다 
    # key값 컬럼명
    # value값 select를 기반으로 가지고온 데이터 

    # cursor.description : cursor객체안에 description이라는 필드가 존재한다
    # description이라는 필드에는 DB정보의 정보가 있다 
    # description하게 되면 cursor객체가 해당 DB정보를 가지고 온다
    # description은 name, type_code, display_size, null_ok ... 존재하게된다
    # description자체는 list형식이다
    # 데이터의 컬럼명은 name이다  
    print('↓ result')
    print(result)  # (('123', '123', '457', '3445', '2344', '667', datetime.date(1988, 8, 23), datetime.datetime(2024, 5, 10, 14, 55, 53)),)

    row_headers=[x[0] for x in cursor.description]

    print('↓ row_headers')
    print(row_headers) # ['USER_ID', 'USER_PW', 'USER_NAME', 'USER_ADDR', 'USER_TEL', 'USER_NICK', 'USER_BIRTH', 'JOINED_AT']
    # key값은 row_headers이고 value값은 result로 담아둔다  

    #새로운 list생성하기 
    json_data = [] #json으로 변환 될 데이터 
    # ↓
    #json_data에 들어갈 데이터 타입은 dic구조이다 
    #리스트인 이유: 데이터가 여러개일 수 있으니까 

    # 내장함수 zip()메소드가 존재한다, zip은 압축을한다
    # zip(k가 될 변수, v가 될 변수) -> 알아서 dic구조로 변환한다

    # for문으로 result안에 들어가 요소들 하나씩 뽑아보기 
    for rv in result:
        # datetime.date 객체를 문자열로 변환하여 JSON 직렬화 가능하게 함
        rv = list(rv)
        rv[row_headers.index('USER_BIRTH')] = str(rv[row_headers.index('USER_BIRTH')])
        rv[row_headers.index('JOINED_AT')] = str(rv[row_headers.index('JOINED_AT')])
        json_data.append(dict(zip(row_headers, rv)))





    #json.dumps() : list(안의 dict구조를) -> json타입으로 변환한다 
    data = json.dumps(json_data)


    # 6. db commit하기(select문에는 commit 안해줘도된다)
    db.commit() 

    # 7. db close하기 
    db.close()

    #return 타입은 String이거나 Json형식으로 리턴이 되어야 한다 
    return data #jsson으로 리턴한다 
#-------------------------------------------------------------------------------------------------------------------





