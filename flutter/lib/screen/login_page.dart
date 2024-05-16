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
        title: Text('로그인 페이지'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: idCon,
                    decoration: InputDecoration(
                      label: Row(
                        children: [
                          Icon(Icons.account_circle),
                          Text(" 아이디 입력"),
                        ],
                      ),
                      hintText: "example@example.com",
                      hintStyle: TextStyle(color: Colors.grey[300]),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: pwCon,
                    obscureText: true,
                    decoration: InputDecoration(
                      label: Row(
                        children: [
                          Icon(Icons.key),
                          Text(" 비밀번호 입력"),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      onPressed: () {
                        login(idCon.text, pwCon.text, context); // 로그인 버튼 클릭 시 값 보냄
                      },
                      child: Text('로그인하기'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => JoinPage()));
                      },
                      child: Text('회원가입하기'),
                    )
                  ],
                ),
                SizedBox(height: 40),
                Container(
                  color: Colors.grey[200],
                  width: double.infinity,
                  height: 2,
                ),
                SizedBox(height: 40),
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