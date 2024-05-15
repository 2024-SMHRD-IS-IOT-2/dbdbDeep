import 'package:d_chart/bar_custom/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Week_bar_chart extends StatelessWidget {
  const Week_bar_chart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          AspectRatio(
            aspectRatio: 10/9,
            child: DChartBarCustom(
              showMeasureLine: true, //y축 수평선
              showDomainLine: true,  //x축 수평선
              showDomainLabel: true, //각 x축 레이블값
              showMeasureLabel: true, //y축 범위
              spaceBetweenItem: 9,  //그래프간의 간격
              //spaceDomainLinetoChart: 0, //그래프 바닥 띄우는것
              //spaceMeasureLabeltoChart: 10, //y축 숫자에 그래프의 간격
              spaceMeasureLinetoChart: 5, //y축과 그래프 간격
              //radiusBar: BorderRadius.circular(20), //그래프 둥글게 함

              /* 무덤모양 그래프
                radiusBar: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),*/

              //큐브모양 그래프
              radiusBar: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),

              max: 50,  //y축 최대값 50
              valueAlign: Alignment.topRight,

              listData: [
                DChartBarDataCustom(
                    value: 13,
                    label: '기쁨',
                    color: Colors.pinkAccent,
                    showValue: true, //그래프 값이 보이게 하는
                    valueStyle: TextStyle(color: Colors.white), //그래프에 쓰여진 글씨 색깔
                    onTap: (){
                      print('메롱');
                    }

                ),
                DChartBarDataCustom(value: 20, label: '슬픔', color: Colors.lightBlueAccent),  //value은 값, label: 'Jan'
                DChartBarDataCustom(value: 30, label: '화남', color: Colors.red),
                DChartBarDataCustom(value: 40, label: '놀라움',color: Colors.yellow ),
                DChartBarDataCustom(value: 25, label: '변화없음',color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


