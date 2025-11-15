import 'package:flutter/material.dart';
import 'package:iot_zone/Page/Dashboard/borrow_requests_page.dart';
import 'package:iot_zone/Page/homepagelender.dart';
import 'package:iot_zone/Page/Dashboard/Dashboard.dart';
import 'package:iot_zone/Page/Asset_page/assetlender.dart';
import 'package:iot_zone/Page/History_page/history_lender.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LenderMain extends StatefulWidget {
  final Map<String, dynamic>?
  userData; // ✅ ข้อมูลผู้ใช้จาก CheckSession หรือ Login

  const LenderMain({super.key, this.userData});

  static _LenderMainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_LenderMainState>();

  @override
  State<LenderMain> createState() => _LenderMainState();
}

class _LenderMainState extends State<LenderMain> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initPages(); // ⭐ โหลดหน้า
  }

  // ✅ ส่ง userData ไปหน้าที่ต้องใช้
  void _initPages() {
    _pages = [
      Homepagelender(userData: widget.userData), // 0
      HistoryLenderPage(), // 1
      BorrowRequestsPage(), // 2
      Dashboard(), // 3
      Assetlender(), // 4
    ];
  }

  void changeTab(int i) {
    setState(() {
      if (_selectedIndex == i) {
        // 🔁 รีโหลดหน้าเดิม (สร้าง widget ใหม่)
        switch (i) {
          case 0:
            _pages[0] = Homepagelender(
              userData: widget.userData,
              key: UniqueKey(),
            );
            break;
          case 1:
            _pages[1] = HistoryLenderPage(key: UniqueKey());
            break;
          case 2:
            _pages[2] = BorrowRequestsPage(key: UniqueKey());
            break;
          case 3:
            _pages[3] = Dashboard(key: UniqueKey());
            break;
          case 4:
            _pages[4] = Assetlender(key: UniqueKey());
            break;
        }
      }
      _selectedIndex = i;
    });
  }

  void _handleBottomTap(int index) {
    switch (index) {
      case 0:
        changeTab(0); // Home
        break;
      case 1:
        changeTab(1); // History
        break;
      case 2:
        changeTab(2); // Dashboard
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
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBarLender(
        currentIndex: _selectedIndex,
        onTap: _handleBottomTap,
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
  State<CustomBottomNavBarLender> createState() =>
      _CustomBottomNavBarLenderState();
}

class _CustomBottomNavBarLenderState extends State<CustomBottomNavBarLender> {
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
                _buildNavItem(Icons.home, 0),
                _buildNavItem(Icons.check_circle_outline, 2),
                _buildNavItem(Icons.history, 1),
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
          widget.onTap(index);
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
