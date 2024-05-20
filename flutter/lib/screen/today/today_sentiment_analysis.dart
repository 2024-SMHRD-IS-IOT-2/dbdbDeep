import 'package:final_project/screen/today/youtube.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';

class Today extends StatelessWidget {
  const Today({Key? key});

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
                            userData['creation_date'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),



                        Card(//카드1
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
                                    Text('오늘의 감정', style: TextStyle(fontSize: 10)),
                                    SizedBox(height: 8),
                                    Text(
                                      '${userData['EMOTION_VAL']} ${userData['percentage']}%',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 0),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                child: const Divider(height: 1),
                              ),
                              Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(message), // 감정에 따른 메시지 출력
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 20),



                        Card( //카드2
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  '추천 동영상',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 7),
                                Container(
                                  height: 190,
                                  child: Youtube(youtubeId: getYoutubeId(userData['EMOTION_VAL'])),
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
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
        count, 
        percentage, 
        ranking,
        CURDATE() AS creation_date
    FROM (
        SELECT 
            EMOTION_VAL,
            count,
            percentage,
            ranking
        FROM (
            SELECT 
                EMOTION_VAL, 
                COUNT(*) AS count, 
                ROUND((COUNT(*) / (SELECT COUNT(*) FROM TB_EMOTION WHERE DATE(EMOTION_AT) = CURDATE()) * 100), 1) AS percentage,
                @rank := @rank + 1 AS ranking
            FROM TB_EMOTION
            CROSS JOIN (SELECT @rank := 0) AS vars
            WHERE DATE(EMOTION_AT) = CURDATE()
            GROUP BY EMOTION_VAL
            ORDER BY count DESC
        ) AS ranked_data
        WHERE ranking = 1
    ) AS top_emotion;
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
