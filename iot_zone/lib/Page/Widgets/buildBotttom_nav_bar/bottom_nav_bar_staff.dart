import 'package:flutter/material.dart';
// ปรับ path ให้ตรงโปรเจกต์ของคุณ
import 'package:iot_zone/Page/homepagestaff.dart';
import 'package:iot_zone/Page/Dashboard/Dashboard-staff.dart';
import 'package:iot_zone/Page/Asset_page/assetstaff.dart';

class StaffMain extends StatefulWidget {
  const StaffMain({super.key});

  // ให้ลูก ๆ ดึง state ของ StaffMain ได้ (ถ้าต้องใช้ changeTab จากหน้าอื่น)
  static _StaffMainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_StaffMainState>();

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Homepagestaff(), // 0
    Center(child: Text('⚙️ Settings')), // 1 (แค่ตัวอย่าง)
    DashboardStaff(), // 2
    AssetStaff(), // 3 (อยู่ใน Shell แต่ไม่มีไอคอน)
  ];

  void changeTab(int i) {
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
        Navigator.pushNamed(context, '/history');
        break;
      case 2:
        // ✅ Dashboard → สลับแท็บไป index 2
        changeTab(2);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBarStaff(
        currentIndex: _selectedIndex,
        onTap: _handleBottomTap, // 👈 ใช้ฟังก์ชันแบบ A
      ),
    );
  }
}

// ---------------- Bottom Nav (dumb widget) ----------------
class CustomBottomNavBarStaff extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBarStaff({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBarStaff> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBarStaff> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBarStaff oldWidget) {
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
                  _buildNavItem(Icons.history, 1), // → /history
                  _buildNavItem(Icons.window, 2), // → /menu
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
