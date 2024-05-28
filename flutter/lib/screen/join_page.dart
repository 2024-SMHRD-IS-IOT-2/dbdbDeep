import 'package:final_project/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class JoinPage extends StatelessWidget {
  const JoinPage({Key? key});

  @override
  Widget build(BuildContext context) {
    TextEditingController input_id = TextEditingController();
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
            SizedBox(width: 50),
            Image.asset(
              'image/sign_up.png',
              width: 25,
              height: 25,
            ),
            Text(
              " 회원가입",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
              ),
            ),
            SizedBox(width: 100),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(11),
          child: SizedBox(),
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30),
              _buildTextFieldWithIcon(
                icon: Icons.account_circle,
                label: '아이디',
                controller: input_id,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              _buildTextFieldWithIcon(
                icon: Icons.lock,
                label: '비밀번호',
                hintText: '비밀번호',
                controller: input_pw,
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              _buildTextFieldWithIcon(
                icon: Icons.lock,
                label: '비밀번호확인',
                hintText: '비밀번호확인',
                controller: input_pw2,
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              _buildTextFieldWithIcon(
                icon: Icons.person,
                label: '이름',
                hintText: '이름',
                controller: input_name,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              _buildTextFieldWithIcon(
                icon: Icons.location_on_outlined,
                label: '주소',
                hintText: '주소',
                controller: input_addr,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),


              _buildTextFieldWithIcon(
                icon: Icons.phone_android,
                label: '전화번호',
                hintText: '전화번호',
                controller: input_tel,
                keyboardType: TextInputType.phone, // 숫자 키패드를 나타내도록 설정
              ),

              SizedBox(height: 20),
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


              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // 회원 가입 버튼 클릭 시 동작
                  joinMember(context, input_id.text, input_pw.text, input_name.text, input_addr.text, input_tel.text, input_birth.text);
                },
                child: Text(
                  '회원 가입',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    bool obscureText = false,
    String? hintText, // hintText 추가
    Color? textColor,
    Function()? onTap,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText, // hintText 적용
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.amber),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.amber, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: textColor), // 텍스트 색상
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      controller: controller,
      onTap: onTap, // onTap 추가
    );
  }
}



//--------------------------------------------


//회원가입 메소드
void joinMember(BuildContext context, String id, String pw, String name, String addr, String tel, String birth) async {
  await dotenv.load(fileName: 'keys.env');
  dynamic host = dotenv.env['MYSQL_HOST'];
  dynamic port = dotenv.env['MYSQL_PORT'];
  dynamic user = dotenv.env['MYSQL_USER'];
  dynamic pw = dotenv.env['MYSQL_PASSWORD'];
  dynamic db = dotenv.env['MYSQL_DATABASE'];
  final conn = await MySQLConnection.createConnection(
    host: host,
    port: int.parse(port),
    userName: user,
    password: pw,
    databaseName: db,
  );

  // 데이터베이스 연결
  await conn.connect();

  var result = await conn.execute(
      "insert into TB_USERS values(:id, sha2(:pw,256), :name, :addr, :tel, :birth, NOW())",
      {
        "id": id,
        "pw": pw,
        "name": name,
        "addr": addr,
        "tel": tel,
        "birth": birth
      });

  print("↓result"); print(result.affectedRows);

  if (result.affectedRows.toInt() > 0) {
    print('okay');
    await conn.execute("insert into TB_MUSIC_FEATURES values (:id,'Sad',0.958006,0.531184,0.716826,0.981885,0.814176,0.757748,0.311619,0.625644,0.583695,0.924431,0.525728,0.15192,0.765535,0.101648,0.125926,0.619863,0.499165,0.911591,0.529076,0.741617,0.850199,0.770272,0.352221,0.163972,0.879409,0.750945,0.337519,0.767891,0.870961,0.0335149,0.583209,0.169955,0.16929,0.351999,0.334049,0.796606,0.649813,0.100497,0.0250407,0.233764,0.9706,0.666187,0.15117,0.749314,0.25179,0.706055,0.858256,0.377221,0.463923,0.622998,0.246001,0.510334,0.23649,0.220311,0.301654,0.894388,0.823068)",{"id" : id});
    await conn.execute("insert into TB_MUSIC_FEATURES values (:id, 'Neutral',-0.167305, -0.167305, -0.167305, -0.167305, -0.166423, 0.0105263, -0.166459, -0.0278256, -0.165746, 0.0962994, -0.167305, -0.167305, -0.136885, -0.167305, -0.136885, -0.167305, -0.167249, -0.13695, -0.164363, -0.167248, -0.166689, -0.167319, -0.16712, -0.167307, -0.167218, -0.1673, -0.167234, -0.167311, -0.16719, -0.167308, -0.167216, -0.136894, -0.167234, -0.13689, -0.167262, -0.167306, -0.167236, -0.136891, -0.167237, -0.136886, -0.167262, -0.136889, -0.167248, -0.167307, -0.16728, -0.167308, -0.167275, -0.167307, -0.167258, -0.136886, -0.167263, -0.167304, -0.167252, -0.136887, -0.167247, -0.167304, -0.167227)",{"id" : id});
    await conn.execute("insert into TB_MUSIC_FEATURES values (:id, 'Angry',6.42964e-07, 1.49501e-07, 4.93676e-07, 1.38567e-08, 0.00588834, 0.963534, 0.0053542, 0.186716, 0.012631, 2.22212, 2.83436e-07, 1.23814e-08, 4.04709e-11, 3.24184e-08, 2.28664e-10, 8.46718e-09, 0.000240802, -2.83017e-05, 0.00939492, 9.92092e-05, 0.000951446, 2.31452e-05, 0.000588215, 3.16125e-05, 0.000354701, 1.42507e-05, 0.000204212, 2.39606e-06, 0.00028009, -3.79613e-06, 0.000209929, -9.73191e-07, 0.000184859, -7.98728e-06, 0.000191139, 4.26047e-06, 0.000177659, -1.48567e-05, 0.00013996, -4.99615e-06, 0.000138088, -1.05425e-05, 0.000146358, 1.01032e-06, 0.000125728, -4.32169e-06, 0.000167214, 9.48976e-06, 0.000166077, 4.6228e-06, 0.00016739, 3.55596e-06, 0.000132583, -8.79813e-07, 0.000151151, 1.31958e-06, 0.000172224)",{"id" : id});
    await conn.execute("insert into TB_MUSIC_FEATURES values (:id, 'Happy',0.225686, 0.472411, 0.77299, 0.922346, 0.000683064, 0.523321, 0.860735, 0.838096, 0.871589, 0.810944, 0.28986, 0.144662, 0.910337, 0.918302, 0.749885, 0.681277, 0.0576484, 0.437577, 0.908412, 0.662117, 0.763417, 0.248491, 0.392677, 0.155026, 0.0670612, 0.678981, 0.734663, 0.640865, 0.888263, 0.538595, 0.493373, 0.671149, 0.29873, 0.435396, 0.143134, 0.720787, 0.572726, 0.586174, 0.177219, 0.822151, 0.0697596, 0.266299, 0.238478, 0.718564, 0.519444, 0.495338, 0.150132, 0.543177, 0.605782, 0.921851, 0.371847, 0.656711, 0.158297, 0.194033, 0.471392, 0.230788, 0.928355 )",{"id" : id});

    // 데이터베이스 연결 종료
    await conn.close();
    // 회원가입 성공 시 LoginPage로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}


