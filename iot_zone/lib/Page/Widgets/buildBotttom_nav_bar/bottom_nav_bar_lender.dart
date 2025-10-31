import 'package:flutter/material.dart';
import 'package:iot_zone/Page/homepagelender.dart';
import 'package:iot_zone/Page/Dashboard/Dashboard-lecture.dart';
import 'package:iot_zone/Page/Asset_page/assetlender.dart';
import 'package:iot_zone/Page/History_page/history_lender.dart';

class LenderMain extends StatefulWidget {
  const LenderMain({super.key});

  static _LenderMainState? of(
    BuildContext context,
  ) => // หา State ของ LenderMain ใน context ปัจจุบัน
      context.findAncestorStateOfType<_LenderMainState>(); //👈

  @override
  State<LenderMain> createState() => _LenderMainState(); // สร้าง State ของ LenderMain
}

class _LenderMainState extends State<LenderMain> {
  int _selectedIndex = 0; // ตัวแปรเก็บดัชนีของแท็บที่เลือก

  final List<Widget> _pages = const [
    // รายการหน้าต่าง ๆ ที่จะแสดงตามแท็บที่เลือก
    Homepagelender(),
    HistoryLenderPage(),
    Center(child: Text('⚙️ Settings')),
    DashboardLender(),
    Assetlender(),
  ];

  void changeTab(int i) {
    // ฟังก์ชันเปลี่ยนแท็บ
    if (_selectedIndex == i) return;
    setState(() => _selectedIndex = i);
  }

  /// ✅ แบบ A: ให้หน้าแม่ตัดสินใจการนำทาง/สลับแท็บ
  void _handleBottomTap(int index) {
    switch (index) {
      case 0:
        // Home → สลับแท็บใน Shell
        changeTab(0);
        break;
      case 1:
        // History → เปิดด้วย named route
        changeTab(1);
        break;
      case 2:
        // ✅ Dashboard → สลับแท็บไป index 2
        changeTab(2);
        break;
      // ✅ Dashboard → สลับแท็บไป index 3
      case 3:
        changeTab(3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBarLender(
        currentIndex: _selectedIndex,
        onTap: _handleBottomTap, // 👈 ใช้ฟังก์ชันแบบ A
      ),
    );
  }
}

// ---------------- Bottom Nav ----------------
class CustomBottomNavBarLender extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBarLender({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBarLender> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBarLender> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBarLender oldWidget) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 0), // Home → changeTab(0)
                _buildNavItem(Icons.history, 1), // → /history
                _buildNavItem(Icons.check_circle_outline, 2),
                _buildNavItem(Icons.window, 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isActive = _selectedIndex == index;

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: isActive ? 1.2 : 1.0,
      child: IconButton(
        onPressed: () {
          setState(() => _selectedIndex = index);
          widget.onTap(index); // ให้หน้าแม่ตัดสินใจ
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
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
