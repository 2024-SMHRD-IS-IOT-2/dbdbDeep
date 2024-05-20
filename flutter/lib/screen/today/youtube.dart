import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Youtube 위젯을 정의. 특정 유튜브 영상을 재생하기 위해 사용됨.
class Youtube extends StatefulWidget {
  final String youtubeId;

  const Youtube({Key? key, required this.youtubeId}) : super(key: key);

  @override
  State<Youtube> createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  late YoutubePlayerController _controller;

  // initState 메서드는 YoutubePlayerController를 초기화
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
  }

  // YoutubePlayer를 사용하여 유튜브 영상을 재생하는 화면을 구성
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

// MySQL 데이터베이스에 연결하여 감정 데이터를 가져오는 함수
Future<List<Map<String, dynamic>>> dbConnector() async {
  final conn = await MySQLConnection.createConnection(
    host: 'project-db-campus.smhrd.com',
    port: 3307,
    userName: 'smhrd_dbdbDeep',
    password: 'dbdb1234!',
    databaseName: 'smhrd_dbdbDeep',
  );

  await conn.connect();

  // SQL 쿼리: 오늘 날짜의 감정 데이터 중 가장 빈도가 높은 감정을 가져옴
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

  // 쿼리 결과를 리스트로 변환
  if (result != null && result.isNotEmpty) {
    for (final row in result.rows) {
      var userData = row.assoc();
      userDataList.add(userData);
    }
  }

  await conn.close();

  return userDataList;
}

// 감정 값에 따라 해당 감정에 맞는 유튜브 영상 ID를 반환하는 함수
String getYoutubeId(String emotion) {
  switch (emotion) {
    case 'Neutral':
      return 'AOPue13SZe8'; // 안정
    case 'Happiness':
      return '4drvuDQpLUk'; // 기쁨
    case 'Surprise':
      return 'VjFV2eoBtxo'; // 놀람
    case 'Fear':
      return 'tZ5xgpDb-w0'; // 불안
    case 'Sadness':
      return 'PzweJS3SOng'; // 슬픔
    case 'Angry':
      return 'PMJ4d7LY8Ao'; // 분노
    case 'Disgust':
      return 'Cf2axcUf0lY'; // 혐오
    default:
      return 'Fs0qitF-qWM'; // 기본값
  }
}

