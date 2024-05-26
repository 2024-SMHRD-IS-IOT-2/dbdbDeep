import 'package:final_project/bottom.dart';
import 'package:final_project/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; //dio 임포트



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false, //디버그 표시없애기

      home:LoginPage(),

      //Bottom(),
      //LoginPage(),
    );
  }
}