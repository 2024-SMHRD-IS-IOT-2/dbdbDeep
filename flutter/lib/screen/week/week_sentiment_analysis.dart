import 'package:final_project/screen/week/linechart_onboarding/onboarding.dart';
import 'package:final_project/screen/week/week_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';


// 주차별 그래프 페이지
class Week extends StatelessWidget {
  const Week({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbConnector(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> userDataList = snapshot.data ?? [];
            if (userDataList.isEmpty) {
              userDataList = [
                {
                  'EMOTION_VAL': '기본값1',
                  'count': 0,
                  'percentage': 0,
                  'ranking': 0,
                  'creation_date': '기본값2',
                },
              ];
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: userDataList.map((userData) {
                    String message = '';
                    switch (userData['EMOTION_VAL']) {
                      case '안정':
                        message = '안정입니다';
                        break;
                      case '기쁨':
                        message = '기쁨입니다';
                        break;
                      case '놀람':
                        message = '놀람입니다';
                        break;
                      case '불안':
                        message = '불안입니다';
                        break;
                      case '슬픔':
                        message = '슬픔입니다';
                        break;
                      case '분노':
                        message = '분노입니다';
                        break;
                      case '혐오':
                        message = '혐오입니다';
                        break;
                      default:
                        message = '알 수 없는 감정입니다';
                        break;
                    }


                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            '${userData['start_date']} ~ ${userData['end_date']} ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 1번째 카드
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                SizedBox(height: 4), // 간격

                                Text(  //
                                  '${userData['EMOTION_VAL']} ${userData['percentage']}%',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),

                                Text( //
                                  '일주일 평균 감정 퍼센트',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5),

                                Container(
                                  height: 430, // Week_bar_chart 높이 조정
                                  child: Week_bar_chart(), // Week_bar_chart를 불러오는 부분
                                ),
                                SizedBox(height: 15),


                                GestureDetector( //
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Onboarding()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text('지난 일주일 감정변화 그래프보기 ', style: TextStyle(color: Colors.lightBlue, fontSize:15,)),
                                      ],
                                    ),
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),

                        Container(height: 20), // 위아래 컨테이너 간격



                        // 2번째 카드
                        // Horizontal Divider - Default
                        // 수평 Divider 위젯을 포함한 기본적인 카드
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              // Card 내부의 상단 이미지와 텍스트들
                              Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(message),
                                  ],
                                ),
                              ),

                              // Divider를 추가하여 섹션을 구분, 선
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 15),
                                child: const Divider(height: 5),  // 선 사이 간격
                              ),



                            ],
                          ),
                        ),

                        // Horizontal Divider - Custom
                        // 색상과 굵기가 다른 Divider를 사용한 카드
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Card Title", style: Theme.of(context).textTheme.headlineMedium),
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      child: Text("Sub title", style: Theme.of(context).textTheme.titleMedium),
                                    ),
                                    const Text('A divider is a thin line that groups content in lists and containers.'),
                                  ],
                                ),
                              ),
                              // 커스텀 Divider
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 15),
                                child: const Divider(
                                  color: Colors.blue,
                                  height: 20,
                                  thickness: 2,
                                  indent: 20,
                                  endIndent: 0,
                                ),
                              ),
                              // 시간 버튼들
                              Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text("Tonight's availability",style : TextStyle(fontWeight: FontWeight.bold),),
                                    Container(height: 5),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300], elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                                          ),
                                          child: const Text("5:30PM"),
                                          onPressed: (){},
                                        ),
                                        Container(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300], elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                                          ),
                                          child: const Text("7:30PM"),
                                          onPressed: (){},
                                        ),
                                        Container(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300], elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                                          ),
                                          child: const Text("8:00PM"),
                                          onPressed: (){},
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(height: 35),
                      ],
                    );
                  }).toList(),
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
  final conn = await MySQLConnection.createConnection(
    host: 'project-db-campus.smhrd.com',
    port: 3307,
    userName: 'smhrd_dbdbDeep',
    password: 'dbdb1234!',
    databaseName: 'smhrd_dbdbDeep',
  );

  await conn.connect();

  var result = await conn.execute("""
    SELECT 
    EMOTION_VAL, 
    percentage,
    DATE_SUB(CURDATE(), INTERVAL 7 DAY) AS start_date,
    CURDATE() AS end_date
FROM (
    SELECT 
        EMOTION_VAL, 
        ROUND((COUNT(*) / (SELECT COUNT(*) FROM TB_EMOTION 
                          WHERE EMOTION_AT >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) 
                          AND EMOTION_AT < CURDATE()) * 100), 1) AS percentage
    FROM TB_EMOTION
    WHERE EMOTION_AT >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) 
      AND EMOTION_AT < CURDATE()
    GROUP BY EMOTION_VAL
    ORDER BY COUNT(*) DESC
    LIMIT 1
) AS ranked_data
ORDER BY percentage DESC;
  """);

  List<Map<String, dynamic>> userDataList = [];

  if (result != null && result.isNotEmpty) {
    for (final row in result.rows) {
      var userData = row.assoc();
      userDataList.add(userData);
    }
  }

  await conn.close();

  return userDataList;
}
