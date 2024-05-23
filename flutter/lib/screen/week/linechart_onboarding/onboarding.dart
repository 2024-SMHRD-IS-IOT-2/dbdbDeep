import 'package:final_project/screen/week/linechart_onboarding/linechart_angry.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_neutral.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_happy.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_sad.dart';
import 'package:flutter/material.dart';
class Onboarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          children: <Widget>[
            Center(child: Happiness_linechart()),  //행복
            Center(child: Sadness_linechart()),    //슬픔
            Center(child: Angry_linechart()),      //분노
            Center(child: Neutral_linechart()),    //안정
          ] ),
    );
  }
}