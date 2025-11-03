import 'package:flutter/material.dart';

// 👇 import หน้าหลัง login
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_staff.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_lender.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar.dart'; // student
import 'package:iot_zone/Page/Login/register_page.dart';

import 'package:iot_zone/users_preferences.dart';




class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Color blackColor = const Color(0xFF1e1e1e);
  Color primary = const Color(0xFF4D5DFF);
  Color purpleColor = const Color(0xFFC368FF);

  TextEditingController tcUser = TextEditingController();
  TextEditingController tcPass = TextEditingController();

  // 🔹 จำลองฐานข้อมูลผู้ใช้
  final List<Map<String, String>> mockUsers = [
    {'username': 'staff01', 'password': '1234', 'role': 'staff'},
    {'username': 'lender01', 'password': '1234', 'role': 'lender'},
    {'username': 'student01', 'password': '1234', 'role': 'student'},
  ];

  // 🔹 ฟังก์ชันตรวจสอบ login
  void _handleLogin() {
    final user = tcUser.text.trim();
    final pass = tcPass.text.trim();

    // ค้นหาผู้ใช้ใน mock list
    final foundUser = mockUsers.firstWhere(
      (u) => u['username'] == user && u['password'] == pass,
      orElse: () => {},
    );

    if (foundUser.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง')),
      );
      return;
    }

    final role = foundUser['role'];

    // ✅ นำทางตาม role
    switch (role) {
      case 'staff':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StaffMain()),
        );
        break;
      case 'lender':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LenderMain()),
        );
        break;
      case 'student':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentMain()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ ไม่พบสิทธิ์ผู้ใช้ (role)')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                colors: [const Color(0x80C368FF), primary],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // โลโก้
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('asset/img/iot.png', width: 80, height: 80),
                      const SizedBox(width: 5),
                      const Text(
                        'Zone',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // กล่อง login
                  Container(
                    width: 350,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Image.asset('asset/icon/padlock.png', width: 40),
                        Text(
                          'Login',
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Username
                        SizedBox(
                          width: 250,
                          child: TextField(
                            controller: tcUser,
                            decoration: InputDecoration(
                              hintText: 'Username',
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.symmetric(
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
                        const SizedBox(height: 15),

                        // Password
                        SizedBox(
                          width: 250,
                          child: TextField(
                            controller: tcPass,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.symmetric(
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

                        const SizedBox(height: 40),

                        // ปุ่ม Login
                        FilledButton(
                          onPressed: _handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 80,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ปุ่ม Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Register here!',
                                style: TextStyle(
                                  color: purpleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
