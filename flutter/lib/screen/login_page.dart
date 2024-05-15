import 'package:dio/dio.dart';
import 'package:final_project/bottom.dart';
import 'package:final_project/model/member_model.dart';
import 'package:final_project/screen/join_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final dio = Dio();  //Dio전역변수화
final storage = FlutterSecureStorage();  //사용자가 앱을 종료하거나 재부팅하더라도 데이터를 안전하게 보관할 수 있도록 해줌

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController idCon = TextEditingController();
  //TextEditingController emailCon = TextEditingController();
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
                        hintStyle: TextStyle(color: Colors.grey[300])),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      controller: pwCon,
                      decoration: InputDecoration(
                        label: Row(
                          children: [
                            Icon(Icons.key),
                            Text(" 비밀번호 입력"),
                          ],
                        ),
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent),
                        onPressed: () {
                          login(idCon.text, pwCon.text, context); //로그인버튼 클릭시 값 보냄
                        },
                        child: Text('로그인하기')),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>JoinPage()));
                        },
                        child: Text('회원가입하기'))
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  color: Colors.grey[200],
                  width: double.infinity,
                  height: 2,
                ),
                SizedBox(
                  height: 40,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

//로그인 메소드
void login(id, pw, context) async {
  String url = "http://119.200.31.99:8000/member/login";


  Response res = await dio.get(url, queryParameters: {'id': id, 'pw': pw});


  //쿼리문까지 적용된 url print문으로 띄우기
  print("↓res.realUri"); print(res.realUri);
  print("↓res == null"); print(res == null);


  var user = memberModelFromJson(res.data); //JSON 형식 MemberModel 객체의 리스트인 user로 변환
  print('↓user'); print(user); //[Instance of 'MemberModel']

  print(user[0].userId);
  print(user[0].userPw);
  print(user[0].userName);
  print(user[0].userAddr);
  print(user[0].userTel);
  print(user[0].userNick);
  print(user[0].userBirth);
  print(user[0].joinedAt);


  print('↓user.isEmpty'); print(user.isEmpty);


//if(res.statusCode == 200 && res.data != null)
  if(res.statusCode == 200 && !user.isEmpty) { //통신이 200이거나 res.data가 null이 아닐때
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute
      (builder: (context)=>Bottom(member: user[0],)), (route) => false); //로그인성공시 Bottom() 페이지이동
  }else{ //로그인실패시
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아이디 또는 패스워드가 잘못 되었습니다 "),)
    );
  }

}