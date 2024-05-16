import 'package:final_project/model/member_model.dart';
import 'package:final_project/screen/mypage/user_update_page.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:intl/intl.dart';

class Mypage extends StatelessWidget {
  const Mypage({
    Key? key,
    required this.member,
  }) : super(key: key);

  final MemberModel member;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(50),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  UserInfoField(label: '아이디', value: member.userId),
                  UserInfoField(label: '이름', value: member.userName),
                  UserInfoField(label: '주소', value: member.userAddr),
                  UserInfoField(label: '전화번호', value: member.userTel),
                  UserInfoField(label: '닉네임', value: member.userNick),
                  UserInfoField(label: '생년월일', value: member.userBirth),
                  UserInfoField(label: '가입일시', value: member.joinedAt),
                  SizedBox(height: 30),
                  Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    height: 2,
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UpdatePage(userId: member.userId),
                            ),
                          );
                        },
                        child: Text('회원 수정하기', style: TextStyle(fontSize: 16)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          // Implement withdrawal logic
                        },
                        child: Text('회원 탈퇴하기', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    height: 2,
                  ),
                  SizedBox(height: 40),
                  TextButton(
                    onPressed: () {
                      // Handle logout
                    },
                    child: Text('로그아웃하기', style: TextStyle(fontSize: 16)),
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

class UserInfoField extends StatelessWidget {
  const UserInfoField({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    String formattedValue = '';

    if (value is DateTime) {
      formattedValue = DateFormat('yyyy-MM-dd').format(value);
    } else {
      formattedValue = value.toString();
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              formattedValue,
              style: TextStyle(
                fontSize: 21,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
