import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Youtube extends StatefulWidget {
  final String youtubeId;

  const Youtube({Key? key, required this.youtubeId}) : super(key: key);

  @override
  State<Youtube> createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          progressColors: ProgressBarColors(
            playedColor: Colors.blue,
            handleColor: Colors.blueAccent,
          ),
          onReady: () {
            _controller.play();
          },
        ),
      ),
    );
  }
}

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
                  'EMOTION_VAL': '평온',
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
                                    Text(getEmotionMessage(userData['EMOTION_VAL'])),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 20),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

String getEmotionMessage(String emotion) {
  switch (emotion) {
    case '평온':
      return '평온입니다';
    case '기쁨':
      return '기쁨입니다';
    case '놀라움':
      return '놀라움입니다';
    case '공포':
      return '공포입니다';
    case '슬픔':
      return '슬픔입니다';
    case '화남':
      return '화남입니다';
    default:
      return '알 수 없는 감정입니다';
  }
}

String getYoutubeId(String emotion) {
  switch (emotion) {
    case '평온':
      return '0ZHqB7Fplu0';
    case '기쁨':
      return '8isciJiPPcM';
    case '놀라움':
      return 'UfXHhFdY_YU';
    case '공포':
      return 'Mphf00NH2Bs';
    case '슬픔':
      return 'm6BHmR4UME0';
    case '화남':
      return 'QYEB40mIZcY';
    default:
      return '6VEnTQ2rx_4'; // 기본값
  }
}

void main() {
  runApp(MaterialApp(
    home: Today(),
  ));
}
