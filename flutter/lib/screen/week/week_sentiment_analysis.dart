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
                    String message1 = '';

                    String emotionKor = '';
                    switch (userData['EMOTION_VAL']) {
                      case 'Happiness':
                        emotionKor = '기쁨';
                        message1 = '일주일 동안 기쁨의 감정이 높다면 그것은 행복한 시간을 보내고 있는 것입니다. 이 기쁨을 더 향상시키기 위해 주변 사람들과 함께 시간을 보내고 좋은 추억을 만들어보세요. 새로운 취미나 활동을 찾아보거나, 자연 속에 나가서 산책을 즐기는 것도 좋은 방법입니다. 그리고 이 행복한 감정을 다른 이들과 공유하여 함께 나누는 것도 잊지 말아주세요.';
                        break;
                      case 'Sadness':
                        emotionKor = '슬픔';
                        message1 = '슬픔은 우리가 직면하는 감정 중 하나입니다. 그 원인을 이해하고 적절히 대처하는 것이 중요합니다. 친구나 가족과 이야기를 나누고, 스트레스 해소 방법을 찾아보세요. 만약 계속되고 일상생활에 지장을 준다면 전문가의 도움을 받는 것이 좋습니다.';
                        break;
                      case 'Angry':
                        emotionKor = '분노';
                        message1 = '일주일 동안 분노의 감정이 높다면 그것은 어려운 시기를 겪고 있는 것일 수 있습니다. 이럴 때는 자신의 감정을 이해하고 수용하는 것이 중요합니다. 분노를 조절하고 표현하는 방법을 찾아보고, 감정을 침착하게 통제할 수 있는 기술을 연습해보세요. 또한, 분노를 느낄 때는 순간적으로 행동하기보다는 잠시 멈추고 깊이 숨을 들이마셨다가 내쉬는 것이 도움이 될 수 있습니다. 분노의 원인을 파악하고 해결책을 찾아나가는 것도 중요합니다. 마음이 진정되고 안정된 상태에서 상황을 다시 평가하고 대응하는 것이 도움이 될 것입니다.';
                        break;
                      case 'Surprise':
                        emotionKor = '놀람';
                        message1 = '일주일 동안 놀람의 감정이 높다면 새로운 경험을 많이 한 것일 수 있습니다. 놀라운 일들은 삶에 새로운 시각을 제공하고 우리를 성장시킬 수 있습니다. 이러한 경험을 통해 자신의 경계를 넓히고 새로운 가능성을 탐색할 수 있습니다. 그러나 때로는 놀람의 감정이 과도하거나 혼란스러울 수도 있습니다. 이럴 때는 머리를 식히고 조용한 시간을 가지며 자신의 감정을 이해하려는 노력이 필요합니다. 새로운 상황에 대한 자신의 반응을 살펴보고, 이를 통해 자신의 성장과 발전에 기여할 수 있는 방법을 고민해보세요.';
                        break;
                      case 'Fear':
                        emotionKor = '불안';
                        message1 = '일주일 동안 불안의 감정이 높다면 그것은 정말 힘든 경험이 될 수 있습니다. 불안은 때때로 우리가 마주하는 어려운 상황에 대한 자연스러운 반응이지만, 그것이 지속되면 우리의 삶에 부정적인 영향을 미칠 수 있습니다. 불안의 감정이 높은 경우, 자신에게 친절하게 대해야 합니다. 불안을 느낄 때 깊게 숨을 들이마시고, 자신에게 "지금 이 순간에는 안전하다"고 말해보세요. 불안의 감정을 인지하고 이해하는 것이 중요합니다. 그리고 필요하다면 주변 사람들과 이야기를 나누고 도움을 요청하는 것이 좋습니다. 불안의 감정을 가진 채로 혼자서 해결하려고 하지 말고, 도움을 받을 수 있는 자원을 찾아보세요.';
                        break;
                      case 'Disgust':
                        emotionKor = '혐오';
                        message1 = '일주일 동안 혐오의 감정이 높다면 그것은 정말로 어려운 시간일 것입니다. 혐오의 감정은 종종 우리를 괴롭히고 고통스럽게 만들 수 있습니다. 먼저, 이러한 감정을 왜 느끼는지에 대해 이해하려고 노력해야 합니다. 그 다음으로는 이러한 감정을 다루는 방법을 찾아보세요. 자신의 감정을 인정하고 받아들이는 것이 중요합니다. 또한, 혐오의 감정이 느껴질 때는 주변 사람들과의 건강한 대화가 필요할 수 있습니다. 그리고 혐오의 감정이 계속되고 심각한 영향을 미친다면 전문가의 도움을 받는 것이 도움이 될 수 있습니다. 마지막으로, 자신을 위로하고 지원하는 환경을 찾는 것이 중요합니다. 함께 어려움을 극복할 수 있는 친구나 가족과의 연락을 유지하고, 긍정적인 활동에 참여하여 마음을 치유하는 것이 도움이 될 수 있습니다.';
                        break;
                      case 'Neutral':
                        emotionKor = '안정';
                        message1 = '일주일 동안 안정의 감정이 높다면, 그것은 확실히 기분 좋은 시간일 것입니다. 안정적인 감정은 일상 생활에서 안정감과 조화를 가져다줍니다. 이러한 시간을 최대한 활용하여 목표를 달성하고 행복한 경험을 만들어보세요. 안정된 감정을 유지하기 위해 균형 잡힌 생활을 유지하고 긍정적인 사고를 유지하는 것이 중요합니다. 또한, 주변 사람들과의 관계를 강화하고 새로운 것을 배우고 성장하는 기회를 찾는 것도 좋습니다. 이러한 안정된 감정을 유지하는 것은 일상 생활에서 행복과 만족을 느끼는 데 도움이 될 것입니다.';

                        break;
                      default:
                        emotionKor = '알 수 없는 감정';
                        message1 = '알 수 없는 감정입니다';
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
                                  '$emotionKor ${userData['percentage']}%',
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
