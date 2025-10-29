import 'package:flutter/material.dart';

// 🔧 ปรับ path ตามโครงโปรเจกต์ของคุณ
import 'package:iot_zone/Page/homepage.dart';
import 'package:iot_zone/Page/Asset_page/assetpage.dart';
import 'package:iot_zone/Page/History_page/history_student.dart';
import 'package:iot_zone/Page/Request Status/Req_Status.dart';

class StudentMain extends StatefulWidget {
  const StudentMain({super.key});

  // ให้ลูก ๆ เรียกเปลี่ยนแท็บได้: StudentMain.of(context)?.changeTab(3)
  static _StudentMainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_StudentMainState>();

  @override
  State<StudentMain> createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Homepage(), // 0
    HistoryStudentPage(), // 1 (ตัวอย่าง)
    RequestStatusPage(), // 2
    Assetpage(), // 3 (ซ่อนในไอคอน เรียกด้วย changeTab)
  ];
  static _StudentMainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_StudentMainState>();

  void changeTab(int i) {
    if (_selectedIndex == i) return;
    setState(() => _selectedIndex = i);
  }

  /// แบบ A: หน้าแม่ตัดสินใจ
  void _handleBottomTap(int index) {
    switch (index) {
      case 0: // Home
        changeTab(0);
        break;
      case 1: // History
        changeTab(1);
        break;
      case 2: // Dashboard
        changeTab(2);
        break;
    }
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

// ---------------- Bottom Nav (dumb widget) ----------------
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
                  _buildNavItem(Icons.home, 0), // Home → changeTab(0)
                  _buildNavItem(Icons.history, 1),
                  _buildNavItem(
                    Icons.hourglass_empty,
                    2,
                  ), // → /history // Dashboard → changeTab(2)
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
          widget.onTap(index); // ให้หน้าแม่ตัดสินใจ (แบบ A)
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
