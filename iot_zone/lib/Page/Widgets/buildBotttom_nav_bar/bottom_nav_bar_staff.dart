import 'package:flutter/material.dart';
// ปรับ path ให้ตรงโปรเจกต์ของคุณ
import 'package:iot_zone/Page/homepagestaff.dart';
import 'package:iot_zone/Page/Dashboard/Dashboard-staff.dart';

class StaffMain extends StatefulWidget {
  const StaffMain({super.key});

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Homepagestaff(),
    Center(
      child: Text(
        "⚙️ Settings Page (กำลังพัฒนา)",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ),
    DashboardStaff(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      // ถ้าต้องการคง state ของแต่ละหน้า เปลี่ยนเป็น IndexedStack ได้
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CustomBottomNavBarStaff(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

// ---------------- Bottom Nav (รวมไฟล์เดียวกันเหมือนตัวอย่าง) ----------------
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
    // ซิงก์ไอคอนกับ currentIndex จากหน้าแม่
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
          // กรอบนอก Gradient
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
          // แถบขาวด้านใน
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
                  _buildNavItem(Icons.home, 0),
                  _buildNavItem(Icons.history, 1),
                  _buildNavItem(Icons.window, 2),
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
          widget.onTap(index); // ให้หน้าแม่สลับหน้า (ไม่ใช้ Navigator)
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
