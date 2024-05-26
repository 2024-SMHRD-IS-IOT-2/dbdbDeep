import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';


import '../login_page.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context) {
    TextEditingController input_id = TextEditingController(text: userId);
    TextEditingController input_pw = TextEditingController();
    TextEditingController input_pw2 = TextEditingController();
    TextEditingController input_name = TextEditingController();
    TextEditingController input_addr = TextEditingController();
    TextEditingController input_tel = TextEditingController();
    TextEditingController input_birth = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 43),
            Image.asset(
              'image/sign_up.png',
              width: 30,
              height: 30,
            ),
            Text(
              " 회원정보수정",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
              ),
            ),
            SizedBox(width: 115),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(11),
          child: SizedBox(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 15),
              _buildTextField(
                controller: input_id,
                label: "아이디 입력",
                icon: Icons.account_circle,
                readOnly: true,
              ),
              _buildTextField(
                controller: input_pw,
                label: "비밀번호 입력",
                icon: Icons.key,
                obscureText: true,
              ),
              _buildTextField(
                controller: input_pw2,
                label: "비밀번호확인",
                icon: Icons.key,
                obscureText: true,
              ),
              _buildTextField(
                controller: input_name,
                label: "이름 입력",
                icon: Icons.person,
              ),
              _buildTextField(
                controller: input_addr,
                label: "주소 입력",
                icon: Icons.home,
              ),
              _buildTextFieldWithIcon(
                controller: input_tel,
                label: '전화번호 입력',
                icon: Icons.phone,
                keyboardType: TextInputType.phone, onTap: () {  }, hintText: '', // 숫자 키패드를 나타내도록 설정
              ),
              _buildTextFieldWithIcon(
                icon: Icons.calendar_today,
                label: '생년월일',
                hintText: 'YYYY-MM-DD',
                controller: input_birth,
                keyboardType: TextInputType.text,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    String formattedDate = picked.year.toString().padLeft(4, '0') +
                        '-' +
                        picked.month.toString().padLeft(2, '0') +
                        '-' +
                        picked.day.toString().padLeft(2, '0');
                    input_birth.text = formattedDate;
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Update(
                    userId, input_pw.text, input_name.text, input_addr.text, input_tel.text, input_birth.text, context,);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 135),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '회원정보수정',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 14.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.amber,
          ),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 13),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required Function()? onTap, required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 14.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.amber,
          ),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 13),
        ),
      ),
    );
  }
}

void Update(id, pw, name, addr, tel, birth, context,) async {
  final conn = await MySQLConnection.createConnection(
    host: '211.48.228.19',
    port: 3306,
    userName: 'xx',
    password: '1234',
    databaseName: 'mymy',
  );

  // 데이터베이스 연결
  await conn.connect();

  var result = await conn.execute(
      "UPDATE TB_USERS SET USER_PW = SHA2(:pw,256), USER_NAME = :name, USER_ADDR = :addr, USER_TEL = :tel, USER_BIRTH = :birth WHERE USER_ID = :input_id",
      {
        "pw": pw,
        "name": name,
        "addr": addr,
        "tel": tel,
        "birth": birth,
        "input_id": id // 여기서 `id`는 사용자 ID 변수입니다.
      }
  );

  // 데이터베이스 연결 종료
  await conn.close();

  if (result.affectedRows.toInt() > 0) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LoginPage()) , (route) => false);
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('실패'),
          content: Text('회원정보 수정에 실패했습니다.'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 알림창 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
