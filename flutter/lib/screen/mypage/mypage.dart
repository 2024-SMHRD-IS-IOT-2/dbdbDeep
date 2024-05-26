import 'package:final_project/model/member_model.dart';
import 'package:final_project/screen/mypage/user_update_page.dart'; // 회원 정보 수정 페이지를 불러옴
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Mypage extends StatelessWidget {
  const Mypage({
    Key? key,
    required this.member,
  }) : super(key: key);

  final MemberModel member; // 회원 정보를 담는 모델 객체

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20), // 위쪽 여백
            Text(
              '개인 정보', // 화면 상단에 표시될 제목
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 30), // 제목과 아래 정보 필드 사이의 여백
            // 개인 정보 항목을 표시하는 UserInfoField 위젯들
            UserInfoField(label: '아이디', value: member.userId),
            UserInfoField(label: '이름', value: member.userName),
            UserInfoField(label: '주소', value: member.userAddr),
            UserInfoField(label: '전화번호', value: member.userTel),
            UserInfoField(label: '생년월일', value: member.userBirth),
            UserInfoField(label: '가입일시', value: member.joinedAt),

            SizedBox(height: 45), // 버튼과 아래 내용 사이의 여백
            // 회원 정보 수정, 로그아웃, 회원탈퇴 버튼을 가로로 나열하는 행
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
              children: [
                // 회원 정보 수정 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdatePage(userId: member.userId), // 회원 정보 수정 페이지로 이동
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15), // 버튼 내부 여백
                    backgroundColor: Colors.amber, // 배경색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 버튼 모서리를 둥글게 설정
                    ),
                  ),
                  child: Text('회원 정보 수정', style: TextStyle(fontSize: 15, color: Colors.white)), // 버튼 텍스트
                ),
                SizedBox(width: 10), // 버튼 사이의 간격

                // 로그아웃 버튼
                ElevatedButton(
                  onPressed: () {
                    // Implement logout logic
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15), // 버튼 내부 여백
                    backgroundColor: Colors.grey, // 배경색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 버튼 모서리를 둥글게 설정
                    ),
                  ),
                  child: Text('로그아웃', style: TextStyle(fontSize: 16, color: Colors.white)), // 버튼 텍스트
                ),

                SizedBox(width: 10), // 버튼 사이의 간격

                // 회원탈퇴 버튼
                ElevatedButton(
                  onPressed: () {
                    // Implement withdrawal logic
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15), // 버튼 내부 여백
                    backgroundColor: Colors.grey, // 배경색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 버튼 모서리를 둥글게 설정
                    ),
                  ),
                  child: Text('회원탈퇴', style: TextStyle(fontSize: 16, color: Colors.white)), // 버튼 텍스트
                ),
              ],
            ),

            SizedBox(height: 20), // 아래쪽 여백
          ],
        ),
      ),
    );
  }
}

// 개인 정보 항목을 표시하는 위젯
class UserInfoField extends StatelessWidget {
  const UserInfoField({
    Key? key,
    required this.label, // 항목 레이블
    required this.value, // 항목 값
  }) : super(key: key);

  final String label; // 항목 레이블
  final dynamic value; // 항목 값

  @override
  Widget build(BuildContext context) {
    String formattedValue = '';

    if (value is DateTime) {
      formattedValue = DateFormat('yyyy-MM-dd').format(value); // 값이 DateTime 형식인 경우 포맷 변경
    } else {
      formattedValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 상하 여백 설정
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label, // 항목 레이블 출력
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 10), // 레이블과 값 사이의 간격
          Expanded(
            flex: 2,
            child: Text(
              formattedValue, // 포맷된 값 출력
              style: TextStyle(
                fontSize: 19,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
