import 'package:final_project/screen/today/today_pie_chart.dart';
import 'package:final_project/screen/today/youtube.dart'; // 유튜브 관련 위젯을 가져옴
import 'package:final_project/screen/week/week_bar_chart.dart';
import 'package:flutter/material.dart'; // 플러터의 기본 위젯을 가져옴
import 'package:intl/intl.dart'; // 날짜 형식 관련 라이브러리를 가져옴
import 'package:mysql_client/mysql_client.dart'; // MySQL 클라이언트를 가져옴

class Today extends StatelessWidget {
  const Today({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbConnector(), // 데이터베이스에서 데이터를 가져오는 Future 함수 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 데이터 로딩 중일 때 로딩 인디케이터 표시
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // 에러 발생 시 에러 메시지 표시
          } else {
            List<Map<String, dynamic>> userDataList = snapshot.data ?? []; // 데이터가 없을 경우 빈 리스트로 초기화
            if (userDataList.isEmpty) {
              // 데이터가 비어 있을 경우 기본값 설정
              userDataList = [
                {
                  'EMOTION_VAL': '기본값1',
                  'count': 0,
                  'percentage': 0,
                  'ranking': 0,
                  'creation_date': '데이터없음',
                },
              ];
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0), // 전체 패딩 설정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: userDataList.map((userData) {
                    // 각 사용자 데이터에 대한 위젯 생성
                    String emotionKor = '';
                    String message1 = '';
                    String message2 = '';
                    // EMOTION_VAL 값을 한국어 감정 값으로 변환
                    switch (userData['EMOTION_VAL']) {
                      case 'Happy':
                        emotionKor = '기쁨';
                        message1 = '기쁨을 유지하고 즐거움을 경험하기 위해 취미생활을 추천합니다.';
                        message2= '취미나 관심사를 추구하세요. 자신이 즐기는 활동을 통해 기쁨을 느낄 수 있으며, 창의성을 발휘하고 성취감을 느낄 수 있습니다.';
                        break;
                      case 'Sad':
                        emotionKor = '슬픔';
                        message1 = '슬픔을 느낄떄 일기쓰기를 추천합니다';
                        message2 = '마음의 감정을 글로 표현하는 것은 마음의 짐을 가볍게 해주고 감정을 정리하는 데 도움이 됩니다. 오늘 느낀 슬픔을 일기에 담아보세요.';
                        break;
                      case 'Angry':
                        emotionKor = '분노';
                        message1 = '분노의 감정이 느껴진다면 자신에게 질문을 해보세요';
                        message2 = '화가 난 이유를 깊이 생각해보고 자신에게 질문해보세요. 이를 통해 감정을 이해하고 어떻게 대응할지를 고민할 수 있습니다.';
                        break;
                      case 'Neutral':
                        emotionKor = '안정';
                        message1 = '안정적인 생활을 위해 규칙적인 생활을 추천합니다.';
                        message2 = '일정한 수면 패턴과 식사 시간을 가지고, 하루 일정을 계획해보세요. 이렇게 하면 예상 가능하고 안정감 있는 일상을 유지할 수 있습니다.';
                        break;
                      default:
                        emotionKor = '데이터없음';
                        message1 = '오늘 탐지된 감정이 없습니다';
                        message2 = '반려봇 짱구와 여러가지 이야기를 나눠보세요';
                        break;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            DateFormat('yyyy년MM월dd일').format(DateTime.parse(userData['creation_date'])),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 1번째 카드 위젯
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // 모서리 둥근 카드
                          clipBehavior: Clip.antiAliasWithSaveLayer, // 클립 동작 설정
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(15), // 패딩 설정
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('오늘의 감정', style: TextStyle(fontSize: 10),), // 오늘의 감정 텍스트
                                    SizedBox(height: 8),
                                    Text(
                                      '$emotionKor ${userData['percentage']}%', // 변환된 감정 값과 퍼센트 표시
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 0),
                                  ],
                                ),
                              ),
                              Container(  //구분선 컨테이너
                                margin: const EdgeInsets.symmetric(horizontal: 10), // 수평 여백 설정
                                child: const Divider(height: 1), // 구분선
                              ),
                              Container(
                                padding: const EdgeInsets.all(15), // 패딩 설정
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('오늘의 감정 퍼센트',style: TextStyle(color: Colors.grey[600]), ), // 감정에 따른 메시지 출력
                                  ],
                                ),
                              ),


                              Container(
                                height: 290,
                                child: Today_piechart(), // Week_bar_chart를 불러오는 부분
                              ),


                            ],
                          ),
                        ),
                        Container(height: 20), // 여백 설정



                        Card( //카드
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              // 추천합니다
                              Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(message1),
                                  ],
                                ),
                              ),

                              // Divider를 추가하여 섹션을 구분, 선
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 15),
                                child: const Divider(height: 5),  // 선 사이 간격
                              ),

                              Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(message2),
                                  ],
                                ),
                              ),



                            ],
                          ),
                        ),

                        // 세 번째 카드 위젯
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 모서리 둥근 카드
                          ),
                          elevation: 4, // 그림자 설정
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), // 패딩 설정
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  '추천 동영상', // 추천 동영상 텍스트
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 7),
                                Container(
                                  height: 190, // 유튜브 위젯 높이 설정
                                  child: Youtube(youtubeId: getYoutubeId(userData['EMOTION_VAL'])), // 유튜브 위젯
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),

                        Container(height: 35), // 여백 설정
                      ],
                    );
                  }).toList(), // 리스트를 위젯 리스트로 변환
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> dbConnector() async {
  // MySQL 연결 설정
  final conn = await MySQLConnection.createConnection(
    host: 'project-db-campus.smhrd.com',
    port: 3307,
    userName: 'smhrd_dbdbDeep',
    password: 'dbdb1234!',
    databaseName: 'smhrd_dbdbDeep',
  );

  await conn.connect(); // 데이터베이스에 연결

  // SQL 쿼리 실행
  var result = await conn.execute("""
        SELECT 
    EMOTION_VAL, 
    percentage, 
    creation_date
FROM (
    SELECT 
        EMOTION_VAL,
        percentage,
        creation_date,
        @ranking := @ranking + 1 AS ranking
    FROM (
        SELECT 
            EMOTION_VAL,
            ROUND((COUNT(*) / (SELECT COUNT(*) FROM TB_EMOTION WHERE DATE(EMOTION_AT) = CURDATE()) * 100), 1) AS percentage,
            CURDATE() AS creation_date
        FROM TB_EMOTION
        CROSS JOIN (SELECT @ranking := 0) AS vars
        WHERE DATE(EMOTION_AT) = CURDATE()
        GROUP BY EMOTION_VAL
        ORDER BY percentage DESC
        LIMIT 1
    ) AS ranked_data
) AS top_emotion;
  """);

  List<Map<String, dynamic>> userDataList = [];

  // 쿼리 결과를 리스트에 추가
  if (result != null && result.isNotEmpty) {
    for (final row in result.rows) {
      var userData = row.assoc();
      userDataList.add(userData);
    }
  }

  await conn.close(); // 연결 종료

  return userDataList; // 결과 반환
}
