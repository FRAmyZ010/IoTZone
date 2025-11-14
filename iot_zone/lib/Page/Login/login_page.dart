import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot_zone/Page/AppConfig.dart';
import 'dart:convert';
import 'package:iot_zone/Page/Login/check_session_page.dart';

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

  // ----------------------------------------------------------
  // 🔥 ฟังก์ชัน Login (เพิ่ม token + refresh token ให้ครบ)
  // ----------------------------------------------------------
  void _handleLogin() async {
    final username = tcUser.text.trim();
    final password = tcPass.text.trim();
    final ip = AppConfig.serverIP;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter both username and password'),
        ),
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

        // ----------------------------------------------------------
        // ✔ เก็บ session + accessToken + refreshToken
        // ----------------------------------------------------------
        await _saveSession(
          data['user'],
          data['accessToken'],
          data['refreshToken'],
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Login successful!')));

        // ----------------------------------------------------------
        // 🧭 Navigate by role
        // ----------------------------------------------------------
        switch (role) {
          case 'student':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CheckSessionPage()),
            );

            break;

          case 'staff':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CheckSessionPage()),
            );

            break;

          case 'lender':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CheckSessionPage()),
            );

            break;

          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('⚠️ User role not found')),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${data['message'] ?? 'Invalid username or password'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Connection error. Unable to reach server.\n$e'),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // 📦 Save Session + Tokens
  // ----------------------------------------------------------
  Future<void> _saveSession(
    Map<String, dynamic> user,
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('role', user['role']);
    await prefs.setString('username', user['username']);
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('name', user['name']);
    await prefs.setString('phone', user['phone']);
    await prefs.setString('email', user['email']);
    await prefs.setString('image', user['image'] ?? '');

    // ✔ เก็บ token ต่างหาก
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);

    await prefs.commit();

    print('✅ Session saved: ${user['username']} (${user['role']})');
    print('🔐 AccessToken Saved');
    print('🔁 RefreshToken Saved');
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

                  // ------------------------------------------------
                  // 🔐 กล่อง Login (เหมือนเดิม ไม่แตะ UI)
                  // ------------------------------------------------
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
