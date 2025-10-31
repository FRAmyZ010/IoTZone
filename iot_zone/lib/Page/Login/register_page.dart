import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:iot_zone/Page/Login/login_page.dart';
import 'package:iot_zone/Page/Login/textfield_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Color blackColor = const Color(0xFF1e1e1e);
  Color primary = const Color(0xFF4D5DFF);
  Color purpleColor = const Color(0xFFC368FF);
  Color green = const Color(0xFF14f105);
  Color red = const Color(0xFFFF0004);

  final tcUser = TextEditingController();
  final tcPass = TextEditingController();
  final tcConfirmPass = TextEditingController();
  final tcName = TextEditingController();
  final tcPhone = TextEditingController();
  final tcEmail = TextEditingController();

  final String ip = AppConfig.serverIP;

  // ✅ ฟังก์ชันสมัครสมาชิก
  Future<void> _registerUser() async {
    final username = tcUser.text.trim();
    final password = tcPass.text.trim();
    final confirm = tcConfirmPass.text.trim();
    final name = tcName.text.trim();
    final phone = tcPhone.text.trim();
    final email = tcEmail.text.trim();

    // 🔸 ตรวจสอบค่าว่าง
    if (username.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ กรุณากรอกข้อมูลให้ครบทุกช่อง')),
      );
      return;
    }

    // 🔸 ตรวจสอบ password
    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ รหัสผ่านไม่ตรงกัน')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://$ip:3000/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'name': name,
          'phone': phone,
          'email': email,
          'role': 'student',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        // ✅ สมัครสำเร็จ
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ ${data['message']}')));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้')),
      );
    }
  }

  // ✅ แสดง Alert สำเร็จ
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 100,
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('asset/icon/check.png', width: 80),
                const SizedBox(height: 20),
                const Text(
                  'Register Successfully!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: red),
              child: const Text('Close'),
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
            // 🔹 พื้นหลัง
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [purpleColor, primary],
                ),
              ),
            ),

            // 🔹 กล่อง Register
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('asset/icon/register.png', width: 45),
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 🔸 ช่องกรอก
                        InputFieldWidget(
                          hintText: 'Username',
                          controller: tcUser,
                          assetPath: 'asset/icon/user.png',
                        ),
                        const SizedBox(height: 20),
                        InputFieldWidget(
                          hintText: 'Password',
                          controller: tcPass,
                          assetPath: 'asset/icon/padlock.png',
                        ),
                        const SizedBox(height: 20),
                        InputFieldWidget(
                          hintText: 'Confirm Password',
                          controller: tcConfirmPass,
                          assetPath: 'asset/icon/padlock.png',
                        ),
                        const SizedBox(height: 20),
                        InputFieldWidget(
                          hintText: 'Full Name',
                          controller: tcName,
                          assetPath: 'asset/icon/id-card.png',
                        ),
                        const SizedBox(height: 20),
                        InputFieldWidget(
                          hintText: 'Phone',
                          controller: tcPhone,
                          assetPath: 'asset/icon/phone.png',
                        ),
                        const SizedBox(height: 20),
                        InputFieldWidget(
                          hintText: 'Email',
                          controller: tcEmail,
                          assetPath: 'asset/icon/gmail.png',
                        ),
                        const SizedBox(height: 40),

                        // 🔸 ปุ่ม
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: _registerUser,
                              style: FilledButton.styleFrom(
                                backgroundColor: green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
