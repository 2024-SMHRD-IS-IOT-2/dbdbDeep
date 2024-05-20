import 'package:final_project/screen/week/linechart_onboarding/linechart_angry.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_neutral.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_happiness.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_disgust.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_fear.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_sadness.dart';
import 'package:final_project/screen/week/linechart_onboarding/linechart_surprise.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          children: <Widget>[
            Center(child: Happiness_linechart()),    //행복
            Center(child: Sadness_linechart()),      //슬픔
            Center(child: Angry_linechart()),    //분노
            Center(child: Surprise_linechart()), //놀람
            Center(child: Fear_linechart()),  //불안
            Center(child: Disgust_linechart()),     //혐오
            Center(child: Neutral_linechart()),     //안정
          ] ),
    );
  }
}