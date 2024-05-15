import 'package:final_project/screen/week/week_bar_chart.dart';
import 'package:flutter/material.dart';


// 주차별 그래프 페이지
class Week extends StatelessWidget {
  const Week({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '05월01일 ~ 05월07일',  // 대상 날짜
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
                        '슬픔 32%',
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
                          const Text('슬플때는 목표를 설정하고 이를 달성하는 데 집중하는 것은 슬픔을 극복하는 데 도움이 됩니다. 작은 성취감을 느끼면서 긍정적인 에너지를 얻을 수 있습니다. 이러한 활동들을 통해 슬픔을 이겨내고 긍정적인 마음을 유지하세요'),
                        ],
                      ),
                    ),

                    // Divider를 추가하여 섹션을 구분, 선
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Divider(height: 5),  // 선 사이 간격
                    ),

                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('더보기'),
                        ],
                      ),
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
          ),
        ),
      ),
    );
  }
}
