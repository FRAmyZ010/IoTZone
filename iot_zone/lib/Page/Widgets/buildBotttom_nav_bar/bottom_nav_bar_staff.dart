import 'package:flutter/material.dart';
import 'package:iot_zone/Page/homepagestaff.dart';
import 'package:iot_zone/Page/Dashboard/Dashboard.dart';
import 'package:iot_zone/Page/Asset_page/assetstaff.dart';
import 'package:iot_zone/Page/History_page/history_staff.dart';

class StaffMain extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const StaffMain({super.key, this.userData});

  static _StaffMainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_StaffMainState>();

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepagestaff(userData: widget.userData), // 0
      HistoryStaffPage(), // 1
      Dashboard(), // 2
      Center(child: Text('⚙️ Settings')), // 3
      AssetStaff(), // 4
    ];
  }

  void changeTab(int i) {
    setState(() {
      if (_selectedIndex == i) {
        // 🔁 ถ้ากดแท็บเดิม → รีโหลดหน้า (สร้าง widget ใหม่)
        switch (i) {
          case 0:
            _pages[0] = Homepagestaff(
              userData: widget.userData,
              key: UniqueKey(),
            );
            break;
          case 1:
            _pages[1] = HistoryStaffPage(key: UniqueKey());
            break;
          case 2:
            _pages[2] = Dashboard(key: UniqueKey());
            break;
          case 3:
            _pages[3] = Center(key: UniqueKey());
            break;
          case 4:
            _pages[4] = AssetStaff(key: UniqueKey());
            break;
        }
      }
      _selectedIndex = i;
    });
  }

  // ✅ ใช้ switch เหมือนเดิม
  void _handleBottomTap(int index) {
    switch (index) {
      case 0:
        changeTab(0); // Home
        break;
      case 1:
        changeTab(1); // History
        break;
      case 2:
        changeTab(2); // Request Status (Dashboard)
        break;
      case 3:
        changeTab(3); // Asset
        break;
      default:
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
        onTap: _handleBottomTap, // ✅ เรียกผ่าน switch
      ),
    );
  }
}

// ---------------- Bottom Nav ----------------
class CustomBottomNavBarStaff extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBarStaff({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBarStaff> createState() =>
      _CustomBottomNavBarStaffState();
}

class _CustomBottomNavBarStaffState extends State<CustomBottomNavBarStaff> {
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
          // 🔹 Gradient ด้านหลัง
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

          // 🔹 ปุ่มจริง
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
                  _buildNavItem(Icons.check_circle_outline, 3),
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
          widget.onTap(index);
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
