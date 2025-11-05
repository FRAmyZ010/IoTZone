import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔧 ปรับ path ตามโครงโปรเจกต์ของคุณ
import 'package:iot_zone/Page/homepage.dart';
import 'package:iot_zone/Page/Asset_page/assetpage.dart';
import 'package:iot_zone/Page/History_page/history_student.dart';
import 'package:iot_zone/Page/Request Status/Req_Status.dart';
import 'package:iot_zone/Page/Login/login_page.dart';

class StudentMain extends StatefulWidget {
  final Map<String, dynamic>? userData; // ✅ รับข้อมูล user จาก login

  const StudentMain({super.key, this.userData});

  // ✅ ใช้เพื่อให้หน้าอื่นเรียกเปลี่ยนแท็บได้ เช่น StudentMain.of(context)?.changeTab(3)
  static _StudentMainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_StudentMainState>();

  @override
  State<StudentMain> createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // ✅ ส่ง userData ไปหน้า Homepage
    _pages = [
      Homepage(userData: widget.userData), // ส่งข้อมูลผู้ใช้มาจาก login
      const HistoryStudentPage(),
      const RequestStatusPage(),
      const Assetpage(),
    ];
  }

  // ✅ ฟังก์ชันเปลี่ยนแท็บ
  void changeTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  // ✅ เมื่อกด icon ด้านล่าง
  void _handleBottomTap(int index) {
    switch (index) {
      case 0:
        changeTab(0); // Home
        break;
      case 1:
        changeTab(1); // History
        break;
      case 2:
        changeTab(2); // Request Status
        break;
      case 3:
        changeTab(3); // Asset
        break;
      default:
        break;
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 🧹 ล้างทุกค่า
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBarStudent(
        currentIndex: _selectedIndex,
        onTap: _handleBottomTap,
      ),
    );
  }
}

// ---------------- Bottom Nav ----------------
class CustomBottomNavBarStudent extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBarStudent({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBarStudent> createState() =>
      _CustomBottomNavBarStudentState();
}

class _CustomBottomNavBarStudentState extends State<CustomBottomNavBarStudent> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBarStudent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _selectedIndex) {
      _selectedIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔹 แถบ gradient ด้านหลัง
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 63,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(
                colors: [Color(0xFF4D5DFF), Color(0xFFC368FF)],
              ),
            ),
          ),

          // 🔹 แถบปุ่มจริง
          Container(
            height: 54,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 14,
                  spreadRadius: -2,
                  offset: Offset(0, 8),
                  color: Colors.black12,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(Icons.home, 0), // 🏠 Home
                  _buildNavItem(Icons.hourglass_empty, 2), // ⏳ Request
                  _buildNavItem(Icons.history, 1), // 📜 History
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isActive = _selectedIndex == index;

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isActive ? 1.2 : 1.0,
      child: IconButton(
        splashRadius: 24,
        onPressed: () {
          setState(() => _selectedIndex = index);
          widget.onTap(index); // ✅ แจ้งหน้าแม่เปลี่ยนแท็บ
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            icon,
            key: ValueKey('${icon}_$isActive'),
            size: 28,
            color: isActive ? const Color(0xFF6B45FF) : Colors.black,
          ),
        ),
      ),
    );
  }
}
