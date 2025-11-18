import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// import หน้า role
import 'package:iot_zone/Page/Login/login_page.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_staff.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_lender.dart';
import 'package:iot_zone/Page/api_helper.dart';
import 'package:iot_zone/Page/AppConfig.dart';

class CheckSessionPage extends StatefulWidget {
  const CheckSessionPage({super.key});

  @override
  State<CheckSessionPage> createState() => _CheckSessionPageState();
}

Timer? _refreshTimer;

class _CheckSessionPageState extends State<CheckSessionPage> {
  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
    _checkSession();
  }

  void _startAutoRefresh() async {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken");
      final refreshToken = prefs.getString("refreshToken");

      if (accessToken == null || refreshToken == null) return;

      // Decode exp in JWT
      final payload = accessToken.split('.')[1];
      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(payload))),
      );

      final exp = decoded["exp"] * 1000;
      final now = DateTime.now().millisecondsSinceEpoch;

      // ถ้าเหลือ < 90 วิ → refresh
      if (exp - now < 30000) {
        debugPrint("⏳ Token almost expired → refreshing...");
        final newToken = await ApiHelper.refreshAccessToken(refreshToken);
        if (newToken != null) {
          debugPrint("🔄 Token refreshed silently ✔");
        }
      }
    });
  }

  // ---------------------------------------------------------
  // 🔥 ฟังก์ชันตรวจ session + ตรวจ token + refresh token
  // ---------------------------------------------------------
  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    debugPrint('🟢 Session Check → isLoggedIn = $isLoggedIn');

    // ดึง token ที่เก็บไว้
    final accessToken = prefs.getString("accessToken");
    final refreshToken = prefs.getString("refreshToken");

    // ❌ ไม่มี session + ไม่มี token → ไปหน้า Login
    if (!isLoggedIn || accessToken == null || refreshToken == null) {
      return _goToLogin();
    }

    // ---------------------------------------------------------
    // 1) ตรวจว่า Access Token หมดอายุหรือยัง
    // ---------------------------------------------------------
    final isTokenValid = await _validateAccessToken(accessToken);

    if (!isTokenValid) {
      debugPrint("⛔ Access Token หมดอายุ → กำลังขอใหม่ด้วย Refresh Token");

      final newAccess = await _refreshAccessToken(refreshToken);

      if (newAccess == null) {
        debugPrint("❌ Refresh Token ใช้ไม่ได้ → Logout");
        return _goToLogin();
      }

      // ✔ token ใหม่ เก็บแทนของเก่า
      await prefs.setString("accessToken", newAccess);

      debugPrint("✅ ได้ Access Token ใหม่เรียบร้อยแล้ว");
    }

    // ---------------------------------------------------------
    // 2) session ยังดีอยู่ → restore userData (เหมือนโค้ดเดิม)
    // ---------------------------------------------------------
    final role = prefs.getString('role');
    final username = prefs.getString('username');
    final userId = prefs.getInt('user_id');
    final name = prefs.getString('name');
    final image = prefs.getString('image');
    final phone = prefs.getString('phone');
    final email = prefs.getString('email');

    debugPrint('🔹 Restore session for $name ($role)');

    final userData = {
      'id': userId,
      'username': username,
      'name': name,
      'role': role,
      'image': image,
      'phone': phone,
      'email': email,
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

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    }
  }

  // ---------------------------------------------------------
  // ⛽ ฟังก์ชันตรวจ Token ว่าหมดอายุไหม
  // ---------------------------------------------------------
  Future<bool> _validateAccessToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload);

      final exp = data["exp"] * 1000;
      final now = DateTime.now().millisecondsSinceEpoch;

      return now < exp; // true = ยังไม่หมดอายุ
    } catch (e) {
      debugPrint("❌ Token decode error → $e");
      return false;
    }
  }

  // ---------------------------------------------------------
  // 🔁 ฟังก์ชัน refresh Access Token จาก Refresh Token
  // ---------------------------------------------------------
  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/refresh-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final newToken = jsonDecode(response.body)["accessToken"];
        debugPrint("🔄 Refresh success → New Access Token saved");
        return newToken;
      }

      return null;
    } catch (e) {
      debugPrint("❌ Refresh Token Error → $e");
      return null;
    }
  }

  // ---------------------------------------------------------
  // 🛑 ฟังก์ชันไปหน้า Login (ใช้ตอน token fail)
  // ---------------------------------------------------------
  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  // ---------------------------------------------------------
  // 🔹 ฟังก์ชัน logout (ตามโค้ดเดิม)
  // ---------------------------------------------------------
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
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

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
