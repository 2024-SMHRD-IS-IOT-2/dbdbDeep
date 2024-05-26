import 'package:final_project/bottom.dart';
import 'package:final_project/model/member_model.dart';
import 'package:final_project/screen/join_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mysql_client/mysql_client.dart';

final storage = FlutterSecureStorage(); // 사용자가 앱을 종료하거나 재부팅하더라도 데이터를 안전하게 보관할 수 있도록 해줌

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController idCon = TextEditingController();
  TextEditingController pwCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 1),
                  // 이미지 추가
                  Image.asset(
                    'image/main.png',
                    height: 200, // 원하는 높이로 설정
                  ),

                  SizedBox(height: 15),
                  Container(
                    width: 280, // 원하는 너비로 설정
                    padding: EdgeInsets.symmetric(vertical: 5), // 위아래 간격 조절
                    child: TextField(
                      controller: idCon,
                      decoration: InputDecoration(
                        labelText: '아이디를 입력해 주세요',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  Container(
                    width: 280, // 원하는 너비로 설정
                    padding: EdgeInsets.symmetric(vertical: 5), // 위아래 간격 조절
                    child: TextField(
                      controller: pwCon,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호를 입력해 주세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // 수정: 간격 축소
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          login(idCon.text, pwCon.text, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(horizontal: 120, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text('로그인', style: TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                      SizedBox(height: 7), // 로그인 버튼과 회원가입 버튼 사이의 간격
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => JoinPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 113, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text('회원가입', style: TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 로그인 메소드
void login(id, pw, context) async {
  final conn = await MySQLConnection.createConnection(
    host: 'project-db-campus.smhrd.com',
    port: 3307,
    userName: 'smhrd_dbdbDeep',
    password: 'dbdb1234!',
    databaseName: 'smhrd_dbdbDeep', // optional
  );

  // 데이터베이스 연결
  await conn.connect();

  var result = await conn.execute("SELECT * FROM TB_USERS WHERE USER_ID = :id AND USER_PW = sha2(:pw,256)", {
    "id": id,
    "pw": pw,
  });

  // 데이터베이스 연결 종료
  await conn.close();

  if (result.isNotEmpty) {
    var userRow = result.rows.first.assoc();
    MemberModel user = MemberModel.fromJson(userRow);

    // 로그인 성공 시 Bottom 페이지로 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Bottom(member: user)),
          (route) => false,
    );
  } else {
    // 로그인 실패 시
    print('로그인 실패: 아이디 또는 비밀번호가 일치하지 않습니다.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("아이디 또는 패스워드가 잘못 되었습니다")),
    );
  }
}
