import 'package:flutter/material.dart';

//회원정보수정페이지
class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    TextEditingController input_id =
    TextEditingController(text:userId); // id값은 controller이용해서 값 고정

    TextEditingController input_pw = TextEditingController();
    TextEditingController input_name = TextEditingController();
    TextEditingController input_addr = TextEditingController();
    TextEditingController input_tel = TextEditingController();
    TextEditingController input_nick = TextEditingController();
    TextEditingController input_birth = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('회원수정 페이지'),
      ),
      body: Column(
        children: [

          Padding( //1아이디
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
              readOnly: true, //읽기전용
              controller: input_id,
            ),
          ),

          Padding( //2비밀번호
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


          Padding( //3이름
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

          Padding( //4주소번호
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  label: Text("주소 입력 "),
                  hintText: "플러터",
                  hintStyle: TextStyle(color: Colors.grey[300])),
              keyboardType: TextInputType.text,
              controller: input_addr,
            ),
          ),


          Padding( //5번호입력
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  label: Text("이름 입력 "),
                  hintText: "플러터",
                  hintStyle: TextStyle(color: Colors.grey[300])),
              keyboardType: TextInputType.text,
              controller: input_tel,
            ),
          ),


          Padding( //6닉네임
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  label: Text("닉네임 이름 "),
                  hintText: "플러터",
                  hintStyle: TextStyle(color: Colors.grey[300])),
              keyboardType: TextInputType.text,
              controller: input_nick,
            ),
          ),


          Padding( //7생일입력
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  label: Text("생일입력 "),
                  hintText: "플러터",
                  hintStyle: TextStyle(color: Colors.grey[300])),
              keyboardType: TextInputType.text,
              controller: input_birth,
            ),
          ),


          ElevatedButton(onPressed: () {}, child: Text('회원 수정'))
        ],
      ),
    );
  }
}