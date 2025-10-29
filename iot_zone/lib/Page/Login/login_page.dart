import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Color blackColor = const Color(0xFF1e1e1e);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังไล่สี
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFC368FF), Color(0xFF4D5DFF)],
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x80C368FF), Color(0xFF4D5DFF)],
              ),
            ),
          ),

          // ชั้นโปร่งใส
          Container(color: Colors.white.withOpacity(0.1)),

          // เนื้อหา
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('asset/img/iot.png', width: 80, height: 80),
                      SizedBox(width: 5),
                      Text(
                        'Zone',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    width: 350,
                    height: 400,
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(20), // มุมโค้ง
                    // ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Image.asset(
                          'asset/icon/padlock.png',
                          width: 40,
                          height: 40,
                        ),
                        Text(
                          'Login',
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
