import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:pie_chart/pie_chart.dart';

class Today_piechart extends StatefulWidget {
  const Today_piechart({Key? key}) : super(key: key);

  @override
  State<Today_piechart> createState() => _Today_piechartState();
}

class _Today_piechartState extends State<Today_piechart> {
  double happyVal = 0;
  double sadVal = 0;
  double angryVal = 0;
  double neutralVal = 0;

  Future<void> loadEmotionData() async {
    var userDataList = await dbConnector();
    // // 각 감정에 해당하는 값을 초기화합니다.
    // happinessVal = 0;
    // sadnessVal = 0;
    // angryVal = 0;
    // neutralVal = 0;

    for (var userData in userDataList) {
      switch (userData['EMOTION_VAL']) {
        case 'Happy':
          happyVal = double.parse(userData['percentage']);
          break;
        case 'Sad':
          sadVal = double.parse(userData['percentage']);
          break;
        case 'Angry':
          angryVal = double.parse(userData['percentage']);
          break;
        case 'Neutral':
          neutralVal = double.parse(userData['percentage']);
          break;
        default:
          break;
      }
    }
    setState(() {}); // 상태 업데이트
  }

  @override
  void initState() {
    super.initState();
    loadEmotionData(); // 초기화 시 데이터 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PieChart(
          dataMap: {
            '기쁨': happyVal,
            '슬픔': sadVal,
            '분노': angryVal,
            '안정': neutralVal,
          }, // 차트에 표시할 데이터
          animationDuration: Duration(milliseconds: 800), // 애니메이션 지속 시간
          chartLegendSpacing: 45, // 차트와 범례 사이의 간격
          chartRadius: MediaQuery.of(context).size.width / 2.4, // 차트 반지름
          colorList: [
            Colors.yellow, //Color(0xFF81C784),
            Colors.blue,
            Colors.red,
            Colors.green,
          ], // 차트 조각들의 색상 목록
          initialAngleInDegree: 0, // 차트의 시작 각도
          chartType: ChartType.ring, // 차트 타입 (링)
          ringStrokeWidth: 50, // 링의 두께
          centerText: "오늘감정", // 차트 중앙의 텍스트
          legendOptions: LegendOptions(
            showLegendsInRow: false, // 범례를 행으로 표시할지 여부
            legendPosition: LegendPosition.right, // 범례 위치
            showLegends: true, // 범례를 표시할지 여부
            legendShape: BoxShape.circle, // 범례 모양 (원)
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold, // 범례 텍스트 스타일 (볼드체)
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true, // 값 배경 표시 여부
            showChartValues: true, // 차트에 값 표시 여부
            showChartValuesInPercentage: false, // 값을 퍼센트로 표시할지 여부
            showChartValuesOutside: false, // 값을 차트 밖에 표시할지 여부
            decimalPlaces: 1, // 소수점 자리수
          ),
        ),
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
    CURDATE() AS creation_date
FROM (
    SELECT 
        EMOTION_VAL,
        ROUND((COUNT(*) / (SELECT COUNT(*) FROM TB_EMOTION WHERE DATE(EMOTION_AT) = CURDATE()) * 100), 1) AS percentage,
        @ranking := @ranking + 1 AS ranking
    FROM TB_EMOTION
    CROSS JOIN (SELECT @ranking := 0) AS vars
    WHERE DATE(EMOTION_AT) = CURDATE()
    GROUP BY EMOTION_VAL
    ORDER BY COUNT(*) DESC
) AS ranked_data;
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
