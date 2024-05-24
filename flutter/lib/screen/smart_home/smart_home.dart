import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// Dio 인스턴스 생성
final dio = Dio();
// 서버 URL
final serverUrl = 'http://211.48.213.203:5000';

class SmartHome extends StatefulWidget {
  const SmartHome({Key? key}) : super(key: key);

  @override
  State<SmartHome> createState() => _SmartHomeState();
}

class _SmartHomeState extends State<SmartHome> {
  bool livingRoom = false; // 거실 스위치 초기값
  bool bed = false; // 침실 스위치 초기값
  bool bathroom = false; // 화장실 스위치 초기값
  bool fan = false; // 선풍기 스위치 초기값

  // ***LED를 제어하는 함수
  void _ledControl(int device, int power, int sec) async {
    try {
      // LED 제어 요청을 보내고 응답을 받음
      Response res = await dio.get('$serverUrl/homectrl', queryParameters: {
        'device': device, // 위치 (거실 또는 방1)
        'power': power, // 전원 (0 또는 100)
        'sec': sec, // 지속 시간 (0으로 설정하면 계속 켜진 상태 유지한다)
      });
      print('↓res.data');
      print(res.data); // 응답 데이터를 출력
    } catch (e) {
      print('Error메세지: $e'); // 오류가 발생한 경우 오류 메시지를 출력
    }
  }

  // LED 상태를 확인하는 함수
  void _ledStatus() async {
    try {
      // LED 상태 확인 요청을 보내고 응답을 받음
      Response res = await dio.get('$serverUrl/ledstat');
      print('↓res.data');
      print(res.data); // 응답 데이터를 출력
    } catch (e) {
      print('Error: $e'); // 오류가 발생한 경우 오류 메시지를 출력
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Smart Home')), // 앱바 설정
      body: Padding(
        padding: EdgeInsets.only(top: 20), // 상단 여백
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDeviceCard(
                  title: '선풍기',
                  imagePath: 'image/fan.png', // 이미지 파일 경로
                  value: fan,
                  onTap: () {
                    setState(() {
                      fan = !fan;
                      _ledControl(0, fan ? 100 : 0, 0);
                    });
                  },
                ),
                SizedBox(height: 10), // 간격 추가
                _buildDeviceCard(
                  title: '거실',
                  imagePath: 'image/living_room_led.png',
                  value: livingRoom,
                  onTap: () {
                    setState(() {
                      livingRoom = !livingRoom;
                      _ledControl(1, livingRoom ? 100 : 0, 0);
                    });
                  },
                ),
                SizedBox(height: 10), // 간격 추가
                _buildDeviceCard(
                  title: '침실',
                  imagePath: 'image/bed_led.png',
                  value: bed,
                  onTap: () {
                    setState(() {
                      bed = !bed;
                      _ledControl(2, bed ? 100 : 0, 0);
                    });
                  },
                ),
                SizedBox(height: 10), // 간격 추가
                _buildDeviceCard(
                  title: '화장실',
                  imagePath: 'image/bathroom_led.png',
                  value: bathroom,
                  onTap: () {
                    setState(() {
                      bathroom = !bathroom;
                      _ledControl(3, bathroom ? 100 : 0, 0);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required String title,
    IconData? icon,
    String? imagePath,
    required bool value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.grey[350], // 클릭 시 노란색 스플래시 효과 설정
      highlightColor: Colors.amber, // 클릭 시 버튼 색을 amber로 설정
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        // vertical:위아래 간격,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (imagePath != null)
                Image.asset(imagePath, width: 40, height: 40) // 이미지 설정
              else if (icon != null)
                Icon(icon, size: 40.0), // 아이콘 설정
              Text(title, style: TextStyle(fontSize: 20.0)),
              Switch(
                value: value,
                activeColor: Colors.amber, // 활성화 시 amber 색상 설정
                onChanged: (bool newValue) {
                  setState(() {
                    value = newValue;
                    onTap();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
