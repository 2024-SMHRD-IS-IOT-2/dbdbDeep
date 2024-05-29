import 'package:final_project/bottom.dart';
import 'package:final_project/model/member_model.dart';
import 'package:final_project/screen/join_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mysql_client/mysql_client.dart';

final storage = FlutterSecureStorage(); // 사용자가 앱을 종료하거나 재부팅하더라도 데이터를 안전하게 보관할 수 있도록 해줌

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController idCon = TextEditingController();
  TextEditingController pwCon = TextEditingController();
  bool autoLogin = false;
  bool saveId = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  // 이미지 추가
                  Image.asset(
                    'image/main.png',
                    height: 250, // 원하는 높이로 설정
                  ),

                  SizedBox(height: 15),

                  _buildTextFieldWithIcon(
                    icon: Icons.account_circle,
                    label: '아이디',
                    hintText: '아이디',
                    controller: idCon,
                    keyboardType: TextInputType.emailAddress,
                    width: 350,
                    height: 55,
                    iconColor: Colors.amber, // 아이콘 색깔 지정
                    borderColor: Colors.amber, // 테두리 색깔 지정
                    fontSize: 14, // 글씨 크기 지정
                  ),

                  SizedBox(height: 2),

                  _buildTextFieldWithIcon(
                    icon: Icons.lock,
                    label: '비밀번호',
                    hintText: '비밀번호',
                    controller: pwCon,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    width: 350,
                    height: 55,
                    iconColor: Colors.amber, // 아이콘 색깔 지정
                    borderColor: Colors.amber, // 테두리 색깔 지정
                    fontSize: 14, // 글씨 크기 지정
                  ),

                  SizedBox(height: 1), // 수정: 간격 축소

                  Row(
                    children: [
                      Checkbox(
                        value: autoLogin,
                        onChanged: (value) {
                          setState(() {
                            autoLogin = value ?? false;
                          });
                        },
                        activeColor: Colors.amber, // 체크 박스가 선택되었을 때의 색상 지정
                      ),
                      Text('자동 로그인', style: TextStyle(color: Colors.black45),),

                      SizedBox(width: 5),

                      Checkbox(
                        value: saveId,
                        onChanged: (value) {
                          setState(() {
                            saveId = value ?? false;
                          });
                        },
                        activeColor: Colors.amber, // 체크 박스가 선택되었을 때의 색상 지정
                      ),
                      Text('아이디 저장', style: TextStyle(color: Colors.black45),),
                    ],
                  ),
                  SizedBox(height: 20), // 수정: 간격 축소
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          login(idCon.text, pwCon.text, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(horizontal: 130, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text('로그인', style: TextStyle(fontSize: 14, color: Colors.black45)),
                      ),
                      SizedBox(height: 7), // 로그인 버튼과 회원가입 버튼 사이의 간격

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => JoinPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 123, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text('회원가입', style: TextStyle(fontSize: 14, color: Colors.black45)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required IconData icon,
    required String label,
    required String hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    bool obscureText = false,
    double? width,
    double? height,
    Color? iconColor, // 아이콘 색깔 매개변수 추가
    Color? borderColor, // 테두리 색깔 매개변수 추가
    double? fontSize, // 글씨 크기 매개변수 추가
  }) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(fontSize: fontSize), // 입력된 텍스트의 글씨 크기
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(fontSize: fontSize), // 라벨의 글씨 크기
          hintStyle: TextStyle(fontSize: fontSize), // 힌트 텍스트의 글씨 크기
          border: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? Colors.grey), // 기본 테두리 색깔
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? Colors.blue, width: 2.0), // 포커스 시 테두리 색깔
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 1.0), // 기본 테두리 색깔
          ),
          prefixIcon: Icon(icon, color: iconColor), // 아이콘 색깔 지정
        ),
      ),
    );
  }
}


//--------------------------------------------------
// 로그인 메소드
void login(id, pw, context) async {
  final conn = await MySQLConnection.createConnection(
    host: 'project-db-campus.smhrd.com',
    port: 3307,
    userName: 'smhrd_dbdbDeep',
    password: 'dbdb1234!',
    databaseName: 'smhrd_dbdbDeep',
  );

  // 데이터베이스 연결
  await conn.connect();

  var result = await conn.execute("SELECT * FROM TB_USERS WHERE USER_ID = :id AND USER_PW = sha2(:pw,256)", {
    "id": id,
    "pw": pw,
  });

  // 데이터베이스 연결 종료
  await conn.close();

  if (result.isNotEmpty) {
    var userRow = result.rows.first.assoc();
    MemberModel user = MemberModel.fromJson(userRow);

    // 로그인 성공 시 Bottom 페이지로 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Bottom(member: user)),
          (route) => false,
    );
  } else {
    // 로그인 실패 시
    print('로그인 실패: 아이디 또는 비밀번호가 일치하지 않습니다.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("아이디 또는 패스워드가 잘못 되었습니다")),
    );
  }
}

