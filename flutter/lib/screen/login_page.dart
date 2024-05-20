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
      appBar: AppBar(
        title: Text(' '),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(
                  'dbdbDeep',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: idCon,
                  decoration: InputDecoration(
                    labelText: '아이디를 입력해 주세요',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10), // 수정: 간격 축소
                TextField(
                  controller: pwCon,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호를 입력해 주세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20), // 수정: 간격 축소
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        login(idCon.text, pwCon.text, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(horizontal: 55, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text('로그인', style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => JoinPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(horizontal: 55, vertical: 15),
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

  var result = await conn.execute("SELECT * FROM TB_USERS WHERE USER_ID = :id AND USER_PW = :pw", {
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