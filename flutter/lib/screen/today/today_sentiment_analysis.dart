import 'package:final_project/screen/today/youtube.dart';
import 'package:flutter/material.dart';

//오늘의 감정페이지

class Today extends StatelessWidget {
  const Today({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '05월08일',  //대상날짜
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),


              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[300],

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        '슬픔 32%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 7),


                      Text(
                        '슬플때는 목표를 설정하고 이를 달성하는 데 집중하는 것은 슬픔을 극복하는 데 도움이 됩니다. 작은 성취감을 느끼면서 긍정적인 에너지를 얻을 수 있습니다. 이러한 활동들을 통해 슬픔을 이겨내고 긍정적인 마음을 유지하세요.',

                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 11),


                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          // Week_bar_chart를 불러와서 보여주는 부분
                          child: Youtube(), // Week_bar_chart를 불러오는 부분
                        ),
                      ),




                      Text(
                        '일주일 평균 감정 퍼센트',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),

                      Text(
                        '일주일 평균 감정 퍼센트',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '일주일 평균 감정 퍼센트',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
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
    );
  }
}
