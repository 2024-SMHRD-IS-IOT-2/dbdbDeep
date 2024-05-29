import 'package:final_project/model/member_model.dart';
import 'package:final_project/screen/mypage/user_update_page.dart'; // 회원 정보 수정 페이지를 불러옴
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../login_page.dart';

class Mypage extends StatelessWidget {
  const Mypage({
    Key? key,
    required this.member,
  }) : super(key: key);

  final MemberModel member; // 회원 정보를 담는 모델 객체

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 자식 위젯들을 수평 중앙에 정렬
            children: [
              SizedBox(height: 15), // 위쪽 여백
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Image.asset(
                      'image/mypage_privacy.png', // 이미지 경로
                      width: 24, // 이미지 너비
                      height: 24, // 이미지 높이
                    ),
                    SizedBox(width: 7), // 간격 추가
                    Text(
                      '회원 개인 정보', // 화면 상단에 표시될 제목
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30), // 제목과 아래 정보 필드 사이의 여백
              // 개인 정보 항목을 표시하는 UserInfoField 위젯들
              Divider(),
              UserInfoField(
                label: ' 아이디',
                value: member.userId,
                labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                valueStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                icon: Icon(Icons.account_circle), // 아이디 아이콘
              ),
              Divider(),
              UserInfoField(
                label: ' 이름',
                value: member.userName,
                labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                valueStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                icon: Icon(Icons.person), // 이름 아이콘
              ),
              Divider(),
              UserInfoField(
                label: ' 주소',
                value: member.userAddr,
                labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                valueStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                icon: Icon(Icons.location_on), // 주소 아이콘
              ),
              Divider(),
              UserInfoField(
                label: ' 전화번호',
                value: member.userTel,
                labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                valueStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                icon: Icon(Icons.phone_android), // 전화번호 아이콘
              ),
              Divider(),
              UserInfoField(
                label: ' 생년월일',
                value: member.userBirth,
                labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                valueStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                icon: Icon(Icons.cake), // 생년월일 아이콘
              ),
              Divider(),
              UserInfoField(
                label: ' 가입일시',
                value: member.joinedAt,
                labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                valueStyle: TextStyle(fontSize: 16, color: Colors.grey[700]), // 여기에서 글씨 크기를 설정
                icon: Icon(Icons.calendar_month_rounded), // 가입일시 아이콘
              ),
              Divider(),

              SizedBox(height: 25), // 버튼과 아래 내용 사이의 여백

              // 회원 정보 수정 버튼을 가운데 정렬
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdatePage(userId: member.userId), // 회원 정보 수정 페이지로 이동
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 110, vertical: 13), // 버튼 내부 여백
                    backgroundColor: Colors.amber, // 배경색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 버튼 모서리를 둥글게 설정
                    ),
                  ),
                  child: Text('회원 정보 수정', style: TextStyle(fontSize: 15, color: Colors.white)), // 버튼 텍스트
                ),
              ),

              SizedBox(height: 20), // 회원 정보 수정 버튼과 아래 버튼들 사이의 간격

              // 로그아웃 및 회원탈퇴 버튼을 가로로 나열하는 행
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                children: [
                  // 로그아웃 버튼
                  ElevatedButton(
                    onPressed: () {
                      logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 52, vertical: 12), // 버튼 내부 여백 horizontal:가로
                      backgroundColor: Colors.grey, // 배경색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 버튼 모서리를 둥글게 설정
                      ),
                    ),
                    child: Text('로그아웃', style: TextStyle(fontSize: 13, color: Colors.white)), // 버튼 텍스트
                  ),

                  SizedBox(width: 10), // 버튼 사이의 간격

                  // 회원탈퇴 버튼
                  ElevatedButton(
                    onPressed: () {
                      // Implement withdrawal logic
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 52, vertical: 12), // 버튼 내부 여백
                      backgroundColor: Colors.grey, // 배경색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 버튼 모서리를 둥글게 설정
                      ),
                    ),
                    child: Text('회원탈퇴', style: TextStyle(fontSize: 13, color: Colors.white)), // 버튼 텍스트
                  ),
                ],
              ),

              SizedBox(height: 20), // 아래쪽 여백
            ],
          ),
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
    this.labelStyle,
    this.valueStyle,
    this.icon,
  }) : super(key: key);

  final String label; // 항목 레이블
  final dynamic value; // 항목 값
  final TextStyle? labelStyle; // 레이블 텍스트 스타일
  final TextStyle? valueStyle; // 값 텍스트 스타일
  final Icon? icon; // 항목 아이콘

  @override
  Widget build(BuildContext context) {
    String formattedValue = '';

    if (value is DateTime) {
      formattedValue = DateFormat('yyyy-MM-dd').format(value); // 값이 DateTime 형식인 경우 포맷 변경
    } else {
      formattedValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 13.0), // 상하 여백과 좌우 패딩 설정
      child: Row(
        children: [


          if (icon != null) // 만약 icon이 제공되었다면
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: icon,
            ),
          Expanded(
            flex: 1,
            child: Text(
              label, // 항목 레이블 출력
              style: labelStyle ?? TextStyle(
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
              style: valueStyle ?? TextStyle(
                fontSize: 19,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center, // 값 텍스트를 가운데 정렬
            ),
          ),
        ],
      ),
    );
  }
}

//로그아웃 메서드
void logout(context) async{
  await storage.delete(key: "login");
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LoginPage()) , (route) => false);

}
