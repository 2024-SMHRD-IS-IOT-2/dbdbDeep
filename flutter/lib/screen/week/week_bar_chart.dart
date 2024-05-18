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
  double surpriseVal = 0;
  double scareVal = 0;
  double hateVal = 0;
  double nomalVal = 0;
  double maxValue = 0;

  // @override
  //  void initState() {
  //    super.initState();
  //    loadEmotionData();
  //  }

  Future<num> loadEmotionData() async {
    var userDataList = await dbConnector();
    List<double> values = [];

    print('↓userDataList');
    print(userDataList);
    for (var userData in userDataList) {
      switch (userData['EMOTION_VAL']) {
        case '기쁨':
          happyVal = double.parse(userData['percentage']);
          break;
        case '슬픔':
          sadVal = double.parse(userData['percentage']);
          break;
        case '화남':
          angryVal = double.parse(userData['percentage']);
          break;
        case '놀람':
          surpriseVal = double.parse(userData['percentage']);
          break;
        case '공포':
          scareVal = double.parse(userData['percentage']);
          break;
        case '혐오':
          hateVal = double.parse(userData['percentage']);
          break;
        case '평온':
          nomalVal = double.parse(userData['percentage']);
          break;
        default:
          break;
      }
      values.addAll([happyVal, sadVal, angryVal, surpriseVal, scareVal, hateVal, nomalVal]);
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
                    aspectRatio: 10 / 9,
                    child: DChartBarCustom(
                      showMeasureLine: true,
                      showDomainLine: true,
                      showDomainLabel: true,
                      showMeasureLabel: true,
                      spaceBetweenItem: 3,
                      spaceMeasureLinetoChart: 5,
                      radiusBar: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      max: maxValue, //최대값

                      valueAlign: Alignment.topRight,
                      listData: [
                        DChartBarDataCustom(
                          value: 13,
                          label: '기쁨',
                          color: Colors.pinkAccent,
                          showValue: true,
                          valueStyle: TextStyle(color: Colors.white),
                        ),
                        DChartBarDataCustom(value: sadVal, label: '슬픔', color: Colors.blue, showValue: true, valueStyle: TextStyle(color: Colors.white)),
                        DChartBarDataCustom(value: angryVal, label: '화남', color: Colors.red, showValue: true, valueStyle: TextStyle(color: Colors.white)),
                        DChartBarDataCustom(value: surpriseVal, label: '놀람', color: Colors.yellow, showValue: true, valueStyle: TextStyle(color: Colors.black54)),
                        DChartBarDataCustom(value: scareVal, label: '불안', color: Colors.deepPurple, showValue: true, valueStyle: TextStyle(color: Colors.white)),
                        DChartBarDataCustom(value: hateVal, label: '혐오', color: Colors.black, showValue: true, valueStyle: TextStyle(color: Colors.white)),
                        DChartBarDataCustom(value: nomalVal, label: '평온', color: Colors.grey[300], showValue: true, valueStyle: TextStyle(color: Colors.black54)),
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
    percentage
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
