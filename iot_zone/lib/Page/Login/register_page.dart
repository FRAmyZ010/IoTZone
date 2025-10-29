import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Color blackColor = const Color(0xFF1e1e1e);
  Color primary = Color(0xFF4D5DFF);
  Color purpleColor = const Color(0xFFC368FF);

  TextEditingController tcUser = TextEditingController();
  TextEditingController tcPass = TextEditingController();
  TextEditingController tcName = TextEditingController();
  TextEditingController tcPhone = TextEditingController();
  TextEditingController tcEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // พื้นหลังไล่สี
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [purpleColor, primary],
                ),
              ),
            ),

            // รูปภาพ
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                'asset/img/login_bg.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x80C368FF), primary],
                ),
              ),
            ),

            // ชั้นโปร่งใส
            Container(color: Colors.white.withOpacity(0.1)),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: 350,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('asset/icon/register.png', width: 45),
                      Text(
                        'Register',
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Row(
                          children: [
                            Image.asset('asset/icon/user.png', width: 30),
                            SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: tcUser,
                                keyboardType: TextInputType.text,
                                // obscureText: true, //
                                decoration: InputDecoration(
                                  hintText: 'Username',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // เพิ่มฟอร์มการสมัครสมาชิกที่นี่
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
