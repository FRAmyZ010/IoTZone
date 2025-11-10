import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot_zone/Page/AppConfig.dart';
import 'dart:convert';

// 🧭 import หน้าหลัง login
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar.dart'; // ✅ StudentMain อยู่ในไฟล์นี้
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_staff.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_lender.dart';

import 'package:iot_zone/Page/Login/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 🎨 Colors
  final Color blackColor = const Color(0xFF1e1e1e);
  final Color primary = const Color(0xFF4D5DFF);
  final Color purpleColor = const Color(0xFFC368FF);

  // 🔹 Controller
  final TextEditingController tcUser = TextEditingController();
  final TextEditingController tcPass = TextEditingController();

  // 🔹 ฟังก์ชันตรวจสอบ login
  void _handleLogin() async {
    final username = tcUser.text.trim();
    final password = tcPass.text.trim();
    final ip = AppConfig.serverIP;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ โปรดกรอกชื่อผู้ใช้และรหัสผ่าน')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://$ip:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['user'] != null) {
        final role = data['user']['role'];

        // ✅ บันทึก session ก่อน
        await _saveSession(data['user']);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ เข้าสู่ระบบสำเร็จ!')));

        // 🧭 ไปหน้าตาม role
        switch (role) {
          case 'student':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentMain(userData: data['user']),
              ),
            );
            break;
          case 'staff':
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => StudentMain(userData: data['user']),
              ),
              (route) => false,
            );
            break;
          case 'lender':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LenderMain(userData: data['user']),
              ),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('⚠️ ไม่พบสิทธิ์ผู้ใช้ (role)')),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${data['message'] ?? 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์\n$e'),
        ),
      );
    }
  }

  Future<void> _saveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('role', user['role']);
    await prefs.setString('username', user['username']);
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('name', user['name']);
    await prefs.setString('phone', user['phone']);
    await prefs.setString('email', user['email']);
    await prefs.setString('image', user['image'] ?? '');
    await prefs.commit();
    print('✅ Session saved: ${user['username']} (${user['role']})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 พื้นหลัง Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [purpleColor, primary],
              ),
            ),
          ),

          // 🔹 รูปพื้นหลังโปร่งใส
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

          // 🔹 เนื้อหา
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

                  // กล่อง Login
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
