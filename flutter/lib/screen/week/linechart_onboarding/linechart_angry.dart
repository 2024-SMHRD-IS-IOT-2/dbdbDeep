import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// SalesData 클래스 정의: 각 데이터 포인트를 나타냄
class SalesData {
  SalesData(this.day, this.percentage);
  final String day; // X축 값이 문자열 (날짜)
  final double percentage; // Y축 값이 퍼센트
}

// LineChart 위젯 정의
class Angry_linechart extends StatefulWidget {
  const Angry_linechart({Key? key}) : super(key: key);

  @override
  State<Angry_linechart> createState() => _Angry_linechartState();
}

class _Angry_linechartState extends State<Angry_linechart> {
  List<SalesData> chartData = [];
  String startDate = '';
  String endDate = '';
  String emotion = '';
  double maxYValue = 0.0;

  @override
  void initState() {
    super.initState();
    loadEmotionData();
  }

  Future<void> loadEmotionData() async {
    var userDataList = await dbConnector();

    if (userDataList.isNotEmpty) {
      setState(() {
        startDate = userDataList.first['start_date'];
        endDate = userDataList.first['end_date'];
        emotion = '분노'; // 'Angry' 대신 '화남'으로 변경
        chartData = userDataList.map((data) {
          return SalesData(data['date'], double.parse(data['percentage']));
        }).toList();

        maxYValue = chartData.map((data) => data.percentage).reduce((value, element) => value > element ? value : element);
        if (maxYValue == 0.0) {
          maxYValue = 10.0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$emotion ( $startDate ~ $endDate )',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 18,),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0),

            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(15),
                child: chartData.isNotEmpty
                    ? SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    labelFormat: '{value}%',
                    minimum: 0,
                    maximum: maxYValue+5,
                  ),
                  series: <CartesianSeries>[
                    LineSeries<SalesData, String>(
                      dataSource: chartData,
                      xValueMapper: (SalesData sales, _) => sales.day,
                      yValueMapper: (SalesData sales, _) => sales.percentage,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                      markerSettings: MarkerSettings(isVisible: true),
                        color: Color(0xFFB71C1C),
                        width: 4
                    )
                  ],
                )
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// 데이터베이스 연결 함수 정의
Future<List<Map<String, dynamic>>> dbConnector() async {
  // 데이터베이스 연결 설정
  final conn = await MySQLConnection.createConnection(
    host: 'project-db-campus.smhrd.com',
    port: 3307,
    userName: 'smhrd_dbdbDeep',
    password: 'dbdb1234!',
    databaseName: 'smhrd_dbdbDeep',
  );

  await conn.connect(); // 데이터베이스에 연결

  // 쿼리 실행
  var result = await conn.execute("""
    SELECT
    DATE_FORMAT(EMOTION_AT, '%m-%d') AS date,  -- 날짜를 '월-일' 형식으로 출력
    (SELECT DATE(MIN(EMOTION_AT)) 
     FROM TB_EMOTION 
     WHERE EMOTION_AT >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) 
       AND EMOTION_AT < CURDATE()) AS start_date,  -- 시작 날짜를 그대로 출력
    (SELECT DATE(MAX(EMOTION_AT)) 
     FROM TB_EMOTION 
     WHERE EMOTION_AT >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) 
       AND EMOTION_AT < CURDATE()) AS end_date,  -- 종료 날짜를 그대로 출력
    'Angry' AS emotion,
    ROUND((SUM(CASE WHEN EMOTION_VAL = 'Angry' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 1) AS percentage
FROM TB_EMOTION
WHERE EMOTION_AT >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
  AND EMOTION_AT < CURDATE()
GROUP BY DATE_FORMAT(EMOTION_AT, '%m-%d')
ORDER BY DATE_FORMAT(EMOTION_AT, '%m-%d');
  """);

  List<Map<String, dynamic>> userDataList = []; // 결과를 저장할 리스트

  if (result != null && result.isNotEmpty) {
    for (final row in result.rows) {
      var userData = row.assoc(); // 각 행을 맵으로 변환
      userDataList.add(userData); // 리스트에 추가
    }
  }

  await conn.close(); // 데이터베이스 연결 종료

  return userDataList; // 결과 리스트 반환
}
