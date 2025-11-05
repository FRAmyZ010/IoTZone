import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ import หน้าตาม role
import 'package:iot_zone/Page/Login/login_page.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_staff.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_lender.dart';

class CheckSessionPage extends StatefulWidget {
  const CheckSessionPage({super.key});

  @override
  State<CheckSessionPage> createState() => _CheckSessionPageState();
}

class _CheckSessionPageState extends State<CheckSessionPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // 🔹 ฟังก์ชันตรวจ session
  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    debugPrint('🟢 Session Check → isLoggedIn = $isLoggedIn');

    if (isLoggedIn) {
      final role = prefs.getString('role');
      final username = prefs.getString('username');
      final userId = prefs.getInt('user_id');
      final name = prefs.getString('name');
      final image = prefs.getString('image');

      debugPrint('🔹 Restore session for $name ($role)');

      // ✅ สร้าง userData map ส่งเข้าไปหน้า role
      final userData = {
        'id': userId,
        'username': username,
        'name': name,
        'role': role,
        'image': image,
      };

      Widget nextPage;
      switch (role) {
        case 'student':
          nextPage = StudentMain(userData: userData);
          break;
        case 'staff':
          nextPage = StaffMain(userData: userData);
          break;
        case 'lender':
          nextPage = LenderMain(userData: userData);
          break;
        default:
          nextPage = const LoginPage();
      }

      // ✅ หน่วงเวลาแสดง splash 1 วิ
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextPage),
        );
      }
    } else {
      // ❌ ไม่มี session → ไปหน้า Login
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  // 🔹 ฟังก์ชัน logout (ถ้าอยากเรียกใช้ตอน refresh)
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('isLoggedIn', false);
    await prefs.commit();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4D5DFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Checking session...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
