import 'package:final_project/screen/login_page.dart';
import 'package:final_project/screen/mypage/mypage.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({Key? key, required this.userId})
      : super(key: key); // 수정된 부분: super(key: key) 추가
  final String userId;

  @override
  Widget build(BuildContext context) {
    TextEditingController input_id = TextEditingController(text: userId);
    TextEditingController input_pw = TextEditingController();
    TextEditingController input_name = TextEditingController();
    TextEditingController input_addr = TextEditingController();
    TextEditingController input_tel = TextEditingController();
    TextEditingController input_birth = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('회원수정 페이지'),
      ),
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  label: Row(
                    children: [
                      Icon(Icons.account_circle),
                      Text("아이디 입력 "),
                    ],
                  ),
                  hintText: "example@example.com",
                  hintStyle: TextStyle(color: Colors.grey[300]),
                ),
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                controller: input_id,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  label: Row(
                    children: [
                      Icon(Icons.key),
                      Text("비밀번호 입력 "),
                    ],
                  ),
                ),
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: input_pw,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  label: Text("이름 입력 "),
                  hintText: "플러터",
                  hintStyle: TextStyle(color: Colors.grey[300]),
                ),
                keyboardType: TextInputType.text,
                controller: input_name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  label: Text("주소 입력 "),
                  hintText: "플러터",
                  hintStyle: TextStyle(color: Colors.grey[300]),
                ),
                keyboardType: TextInputType.text,
                controller: input_addr,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  label: Text("번호 입력 "),
                  hintText: "플러터",
                  hintStyle: TextStyle(color: Colors.grey[300]),
                ),
                keyboardType: TextInputType.text,
                controller: input_tel,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  label: Text("생일입력 "),
                  hintText: "플러터",
                  hintStyle: TextStyle(color: Colors.grey[300]),
                ),
                keyboardType: TextInputType.text,
                controller: input_birth,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Update(
                  userId,
                  input_pw.text,
                  input_name.text,
                  input_addr.text,
                  input_tel.text,
                  input_birth.text,
                  context,
                );
              },
              child: Text('회원 수정'),
            )
          ],
        ),
      ),
    );
  }

  void Update(id, pw, name, addr, tel, birth, context,) async {
    final conn = await MySQLConnection.createConnection(
      host: '211.48.228.19',
      port: 3306,
      userName: 'xx',
      password: '1234',
      databaseName: 'mymy',
    );

    // 데이터베이스 연결
    await conn.connect();


    var result = await conn.execute(
        "UPDATE TB_USERS SET USER_PW = SHA2(:pw,256), USER_NAME = :name, USER_ADDR = :addr, USER_TEL = :tel, USER_BIRTH = :birth WHERE USER_ID = :input_id",
        {
          "pw": pw,
          "name": name,
          "addr": addr,
          "tel": tel,
          "birth": birth,
          "input_id": id // 여기서 `id`는 사용자 ID 변수입니다.
        }
    );

    print("↓result");
    print(result);

    // 데이터베이스 연결 종료
    await conn.close();

    Navigator.pop(context); //이전페이지로 이동
  }
}