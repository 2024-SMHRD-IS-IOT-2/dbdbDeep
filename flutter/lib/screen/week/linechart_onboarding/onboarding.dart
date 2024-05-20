import 'package:final_project/screen/week/linechart_onboarding/linechart_angry.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_easy.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_happy.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_hate.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_nervous.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_sad.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_surprise.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          children: <Widget>[
            Center(child: Happy_linechart()),    //행복
            Center(child: Sad_linechart()),      //슬픔
            Center(child: Angry_linechart()),    //분노
            Center(child: Surprise_linechart()), //놀람
            Center(child: Nervous_linechart()),  //불안
            Center(child: Hate_linechart()),     //혐오
            Center(child: Easy_linechart()),     //안정
          ] ),
    );
  }
}