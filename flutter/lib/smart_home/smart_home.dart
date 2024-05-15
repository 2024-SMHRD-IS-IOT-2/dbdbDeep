import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// Dio 인스턴스 생성
final dio = Dio();
// 서버 URL
final serverUrl = 'http://210.183.87.121:5000';

class Smart_home extends StatefulWidget {
  const Smart_home({super.key});

  @override
  State<Smart_home> createState() => _Smart_homeState();
}

class _Smart_homeState extends State<Smart_home> {
  bool living_room = false; // 거실 스위치 초기값
  bool room1 = false;       // 방1 스위치 초기값

  // ***LED를 제어하는 함수
  void _ledControl(int loc, int power, int sec) async {
    try {
      // LED 제어 요청을 보내고 응답을 받음
      Response res = await dio.get('$serverUrl/homectrl', queryParameters: {
        'loc': loc,      // 위치 (거실 또는 방1)
        'power': power,  // 전원 (0 또는 100)
        'sec': sec,      // 지속 시간 (0으로 설정하면 계속 켜진 상태 유지한다)
      });
      print('↓res.data'); print(res.data); // 응답 데이터를 출력
    } catch (e) {
      print('Error메세지: $e'); // 오류가 발생한 경우 오류 메시지를 출력
    }
  }

  // LED 상태를 확인하는 함수
  void _ledStatus() async {
    try {
      // LED 상태 확인 요청을 보내고 응답을 받음
      Response res = await dio.get('$serverUrl/ledstat');
      print('↓res.data'); print(res.data); // 응답 데이터를 출력
    } catch (e) {
      print('Error: $e'); // 오류가 발생한 경우 오류 메시지를 출력
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column( // Column으로 위아래 정렬
          children: [
            // 거실 스위치
            SwitchListTile(
              title: Text('거실'),
              // 현재 스위치 상태
              value: living_room,
              onChanged: (newValue) {
                setState(() {
                  living_room = newValue!; // 스위치 상태를 변경합니다.
                  _ledControl(1, living_room ? 100 : 1, 0); // LED 제어 함수를 호출하여 거실 LED를 제어함. 거실은 1번, sec 매개변수를 0으로 설정하여 계속 켜진 상태를 유지합니다.
                });
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 0.0), // 내용의 패딩을 설정
            ),

            // 방1 스위치
            SwitchListTile(
              title: Text('방1'),
              value: room1, // 현재 스위치 상태
              onChanged: (newValue) {
                setState(() {
                  room1 = newValue!; // 스위치 상태를 변경
                  _ledControl(2, room1 ? 100 : 1, 0); // LED 제어 함수를 호출하여 방1 LED를 제어함. 방은 2번, sec 매개변수를 0으로 설정하여 계속 켜진 상태를 유지
                });
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 0.0), // 내용의 패딩을 설정
            ),
            ElevatedButton(
              onPressed: _ledStatus, // LED 상태 확인 함수를 호출함
              child: Text('LED 상태 확인'), // 버튼 텍스트
            ),
          ],
        ),
      ),
    );
  }
}
