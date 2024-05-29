import 'package:d_chart/bar_custom/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

class Week_bar_chart extends StatefulWidget {
  const Week_bar_chart({Key? key}) : super(key: key);

  @override
  State<Week_bar_chart> createState() => _Week_bar_chartState();
}

class _Week_bar_chartState extends State<Week_bar_chart> {
  double happyVal = 0;
  double sadVal = 0;
  double angryVal = 0;
  double neutralVal = 0;
  double maxValue = 0;


  Future<num> loadEmotionData() async {
    var userDataList = await dbConnector();
    List<double> values = [];

    print('↓userDataList');
    print(userDataList);
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
      values.addAll([happyVal, sadVal, angryVal, neutralVal]);
    }

    maxValue = values.reduce((value, element) => value > element ? value : element);
    print('↓ maxValue');
    print(maxValue);
    return maxValue;
    //   setState(() {}); // 데이터 처리 후 UI를 업데이트하기 위해 호출합니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
          future: loadEmotionData(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator());
            }else{
              return ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  AspectRatio(
                    aspectRatio: 10 / 11.5,
                    child: DChartBarCustom(
                      showMeasureLine: true,
                      showDomainLine: true,
                      showDomainLabel: true,
                      showMeasureLabel: true,
                      spaceBetweenItem:10,
                      spaceMeasureLinetoChart:5,
                      radiusBar: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      max: maxValue, //최대값
                      valueAlign: Alignment.topCenter, // 글씨 가운데 정렬


                      listData: [
                        DChartBarDataCustom(value: happyVal, label: '기쁨', color: Colors.yellow, showValue: true, valueStyle: TextStyle(color: Colors.black54, fontSize: 14)),
                        DChartBarDataCustom(value: sadVal, label: '슬픔', color: Colors.blue, showValue: true, valueStyle: TextStyle(color: Colors.white, fontSize: 14)),
                        DChartBarDataCustom(value: angryVal, label: '분노', color: Colors.red, showValue: true, valueStyle: TextStyle(color: Colors.white, fontSize: 14)),
                        DChartBarDataCustom(value: neutralVal, label: '안정',  color: Colors.green, showValue: true, valueStyle: TextStyle(color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              );
            }
          }
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
    DATE_SUB(CURDATE(), INTERVAL 1 DAY) AS end_date
FROM (
    SELECT 
        EMOTION_VAL, 
        ROUND((COUNT(*) / (SELECT COUNT(*) FROM TB_EMOTION 
                          WHERE EMOTION_AT >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) 
                          AND EMOTION_AT < DATE_SUB(CURDATE(), INTERVAL 1 DAY)) * 100), 1) AS percentage
    FROM TB_EMOTION
    WHERE EMOTION_AT >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) 
      AND EMOTION_AT < DATE_SUB(CURDATE(), INTERVAL 1 DAY)
    GROUP BY EMOTION_VAL
    ORDER BY COUNT(*) DESC
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
