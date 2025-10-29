import 'package:flutter/material.dart';
import 'package:iot_zone/Page/Login/login_page.dart';
import 'package:iot_zone/Page/Login/textfield_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Color blackColor = const Color(0xFF1e1e1e);
  Color primary = Color(0xFF4D5DFF);
  Color purpleColor = const Color(0xFFC368FF);
  Color green = const Color(0xFF14f105);
  Color red = const Color(0xFFFF0004);

  TextEditingController tcUser = TextEditingController();
  TextEditingController tcPass = TextEditingController();
  TextEditingController tcConfirmPass = TextEditingController();
  TextEditingController tcName = TextEditingController();
  TextEditingController tcPhone = TextEditingController();
  TextEditingController tcEmail = TextEditingController();

  void showAlert(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 100,
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset('asset/icon/check.png', width: 100),
                SizedBox(height: 20),
                Text(
                  'Register Successfully!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            //   child: Text('OK'),
            // ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: red),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

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
                height: 680,
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
                        child: Column(
                          children: [
                            InputFieldWidget(
                              hintText: 'Username',
                              controller: tcName,
                              assetPath: 'asset/icon/user.png',
                            ),
                            SizedBox(height: 20),
                            InputFieldWidget(
                              hintText: 'Password',
                              controller: tcPass,
                              assetPath: 'asset/icon/padlock.png',
                            ),
                            SizedBox(height: 20),
                            InputFieldWidget(
                              hintText: 'Confirm-password',
                              controller: tcPass,
                              assetPath: 'asset/icon/padlock.png',
                            ),
                            SizedBox(height: 35),
                            InputFieldWidget(
                              hintText: 'Full Name',
                              controller: tcUser,
                              assetPath: 'asset/icon/id-card.png',
                            ),
                            SizedBox(height: 20),
                            InputFieldWidget(
                              hintText: 'Phone',
                              controller: tcPhone,
                              assetPath: 'asset/icon/phone.png',
                            ),
                            SizedBox(height: 20),
                            InputFieldWidget(
                              hintText: 'Email',
                              controller: tcEmail,
                              assetPath: 'asset/icon/gmail.png',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          SizedBox(width: 30),
                          // Confirm button
                          FilledButton(
                            onPressed: () {
                              showAlert(context);
                            },

                            style: FilledButton.styleFrom(
                              backgroundColor: green,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          // Cancel button
                          FilledButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },

                            style: FilledButton.styleFrom(
                              backgroundColor: red,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Cancle',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
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
