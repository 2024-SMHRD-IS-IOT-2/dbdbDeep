
import 'package:final_project/model/member_model.dart';
import 'package:final_project/screen/mypage/user_update_page.dart';
import 'package:flutter/material.dart';

class Mypage extends StatelessWidget {
  const Mypage({super.key, required this.member});

  final MemberModel member;

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(' ${member.userName}님 환영합니다.'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(12),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          onPressed: () {

                            // 수정안하고 이전페이지로 넘어갈수도 있으므로 push를 사용한다
                            Navigator.push(context, MaterialPageRoute(builder: (_) => UpdatePage(userId: member.userId,))); //이동할 페이지는 UpdatePage id: member.id를 가지고 이동한다
                          },
                          child: Text('회원 수정하기')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          onPressed: () {

                          },
                          child: Text('회원 탈퇴하기'))
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
                  TextButton(onPressed: (){

                  }, child: Text('로그아웃하기'))

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



