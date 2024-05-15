import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

final dio = Dio();

class JoinPage extends StatelessWidget {
  const JoinPage({Key? key});

  @override
  Widget build(BuildContext context) {
    TextEditingController input_id = TextEditingController();
    TextEditingController input_pw = TextEditingController();
    TextEditingController input_name = TextEditingController();
    TextEditingController input_addr = TextEditingController();
    TextEditingController input_tel = TextEditingController();
    TextEditingController input_nick = TextEditingController();
    TextEditingController input_birth = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 페이지'),
      ),
      body: SingleChildScrollView(
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
                    hintStyle: TextStyle(color: Colors.grey[300])),
                keyboardType: TextInputType.emailAddress,
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
                    hintStyle: TextStyle(color: Colors.grey[300])),
                keyboardType: TextInputType.text,
                controller: input_name,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    label: Text("주소입력 "),
                    hintText: "주소입력",
                    hintStyle: TextStyle(color: Colors.grey[300])),
                keyboardType: TextInputType.text,
                controller: input_addr,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    label: Text("전화번호입력 "),
                    hintText: "전화번호입력",
                    hintStyle: TextStyle(color: Colors.grey[300])),
                keyboardType: TextInputType.text,
                controller: input_tel,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    label: Text("닉네임 입력"),
                    hintText: "닉네임",
                    hintStyle: TextStyle(color: Colors.grey[300])),
                keyboardType: TextInputType.text,
                controller: input_nick,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    label: Text("생일입력"),
                    hintText: "YYYY-DD-MM",
                    hintStyle: TextStyle(color: Colors.grey[300])),
                keyboardType: TextInputType.text,
                controller: input_birth,
              ),
            ),

            ElevatedButton(onPressed: (){
              joinMember(input_id.text, input_pw.text, input_name.text, input_addr.text, input_tel.text, input_nick.text, input_birth.text);
            }, child: Text('회원 가입'))
          ],
        ),
      ),
    );
  }
}

//회원가입 메소드
void joinMember(String id, String pw, String name, String addr, String tel, String nick, String birth) async {
  String url = "http://119.200.31.99:8000/member/join";

  // dio 패키지를 사용하여 get 요청을 보낸다
  Response res = await dio.get(
    url,
    queryParameters: {'id':id, 'pw': pw, 'name':name, 'addr':addr, 'tel':tel, 'nick':nick, 'birth':birth},
  );

  print('↓res.data');
  print(res.data);
  print('↓res.statusCode');
  print(res.statusCode);
}
