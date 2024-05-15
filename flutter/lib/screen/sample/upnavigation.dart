

import 'package:flutter/material.dart';

// 나중에 사용할 네비게이션 페이지

class Mypage2 extends StatelessWidget {
  const Mypage2({Key? key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0), // 원하는 높이로 조정
          child: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  text: '회원정보',
                ),
                Tab(
                  text: '자주하는질문',
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            //Member_information(),
            //Question(),
          ],
        ),
      ),
    );
  }
}
