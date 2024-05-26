import 'package:final_project/screen/week/week_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:intl/intl.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DateRangeProvider(),
      child: MaterialApp(
        home: Week(),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class DateRangeProvider extends ChangeNotifier {
  DateTime? startDate;
  DateTime? endDate;

  void setDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    notifyListeners();
  }
}

class Week extends StatelessWidget {
  const Week({super.key});

  @override
  Widget build(BuildContext context) {
    final dateRangeProvider = Provider.of<DateRangeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Week Emotion Chart'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DateRangePicker(),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbConnector(
                dateRangeProvider.startDate,
                dateRangeProvider.endDate,
              ),
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
                          String message1 = '';
                          String image = '';

                          String emotionKor = '';
                          switch (userData['EMOTION_VAL']) {
                            case 'Happy':
                              emotionKor = '기쁨';
                              message1 = '일주일 동안 기쁨의 감정이 높다면 그것은 행복한 시간을 보내고 있는 것입니다. 이 기쁨을 더 향상시키기 위해 주변 사람들과 함께 시간을 보내고 좋은 추억을 만들어보세요. 새로운 취미나 활동을 찾아보거나, 자연 속에 나가서 산책을 즐기는 것도 좋은 방법입니다.';
                              image = 'image/happy_img.png';
                              break;
                            case 'Sad':
                              emotionKor = '슬픔';
                              message1 = '슬픔은 우리가 직면하는 감정 중 하나입니다. 그 원인을 이해하고 적절히 대처하는 것이 중요합니다. 친구나 가족과 이야기를 나누고, 스트레스 해소 방법을 찾아보세요. 만약 계속되고 일상생활에 지장을 준다면 전문가의 도움을 받는 것이 좋습니다.';
                              image = 'image/sad_img.png';
                              break;
                            case 'Angry':
                              emotionKor = '분노';
                              message1 = '일주일 동안 분노의 감정이 높다면 그것은 어려운 시기를 겪고 있는 것일 수 있습니다. 이럴 때는 자신의 감정을 이해하고 수용하는 것이 중요합니다. 분노를 조절하고 표현하는 방법을 찾아보고, 감정을 침착하게 통제할 수 있는 기술을 연습해보세요. 또한, 분노를 느낄 때는 순간적으로 행동하기보다는 잠시 멈추고 깊이 숨을 들이마셨다가 내쉬는 것이 도움이 될 수 있습니다. 분노의 원인을 파악하고 해결책을 찾아나가는 것도 중요합니다. 마음이 진정되고 안정된 상태에서 상황을 다시 평가하고 대응하는 것이 도움이 될 것입니다.';
                              image = 'image/angry_img.png';
                              break;
                            case 'Neutral':
                              emotionKor = '안정';
                              message1 = '일주일 동안 안정의 감정이 높다면, 그것은 확실히 기분 좋은 시간일 것입니다. 안정적인 감정은 일상 생활에서 안정감과 조화를 가져다줍니다. 이러한 시간을 최대한 활용하여 목표를 달성하고 행복한 경험을 만들어보세요. 안정된 감정을 유지하기 위해 균형 잡힌 생활을 유지하고 긍정적인 사고를 유지하는 것이 중요합니다. 또한, 주변 사람들과의 관계를 강화하고 새로운 것을 배우고 성장하는 기회를 찾는 것도 좋습니다. 이러한 안정된 감정을 유지하는 것은 일상 생활에서 행복과 만족을 느끼는 데 도움이 될 것입니다.';
                              image = 'image/angry_img.png';
                              //'image/nomal_img.png';
                              break;
                            default:
                              emotionKor = '알 수 없는 감정';
                              message1 = '알 수 없는 감정입니다';
                              image = 'image/angry_img.png';
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
                                      SizedBox(height: 4),
                                      Text(
                                        '$emotionKor ${userData['percentage']}%',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                        child: const Divider(height: 1),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        '일주일 평균 감정 퍼센트',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        height: 430,
                                        child: Week_bar_chart(
                                          startDate: dateRangeProvider.startDate,
                                          endDate: dateRangeProvider.endDate,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Onboarding(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              const Text(
                                                '지난 일주일 감정변화 그래프보기 ',
                                                style: TextStyle(
                                                  color: Colors.lightBlue,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(height: 20),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset(image),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 15),
                                      child: const Divider(height: 5),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(message1),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(height: 20),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DateRangePicker extends StatefulWidget {
  @override
  _DateRangePickerState createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTimeRange? dateRange;

  @override
  Widget build(BuildContext context) {
    final dateRangeProvider = Provider.of<DateRangeProvider>(context);

    return Column(
      children: [
        TextButton(
          onPressed: () async {
            final initialDateRange = dateRange ??
                DateTimeRange(
                  start: DateTime.now().subtract(Duration(days: 7)),
                  end: DateTime.now(),
                );
            final picked = await showDateRangePicker(
              context: context,
              initialDateRange: initialDateRange,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );

            if (picked != null && picked != dateRange) {
              setState(() {
                dateRange = picked;
                dateRangeProvider.setDateRange(picked.start, picked.end);
              });
            }
          },
          child: Text(
            dateRange == null
                ? 'Select Date Range'
                : '${DateFormat('MM/dd/yyyy').format(dateRange!.start)} - ${DateFormat('MM/dd/yyyy').format(dateRange!.end)}',
          ),
        ),
      ],
    );
  }
}

Future<List<Map<String, dynamic>>> dbConnector(DateTime? startDate, DateTime? endDate) async {
  final conn = await MySQLConnection.createConnection(
    host: 'project-db-campus.smhrd.com',
    port: 3307,
    userName: 'smhrd_dbdbDeep',
    password: 'dbdb1234!',
    databaseName: 'smhrd_dbdbDeep',
  );

  await conn.connect();

  String query = """
    SELECT 
      EMOTION_VAL, 
      ROUND((COUNT(*) / (SELECT COUNT(*) FROM TB_EMOTION 
                        WHERE EMOTION_AT >= :startDate 
                          AND EMOTION_AT < :endDate) * 100), 1) AS percentage
    FROM TB_EMOTION
    WHERE EMOTION_AT >= :startDate 
      AND EMOTION_AT < :endDate
    GROUP BY EMOTION_VAL
    ORDER BY COUNT(*) DESC;
  """;

  var result = await conn.execute(query, {
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
  });

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
