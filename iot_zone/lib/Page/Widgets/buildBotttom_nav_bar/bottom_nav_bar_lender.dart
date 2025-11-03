import 'package:flutter/material.dart';
import 'package:iot_zone/Page/homepagelender.dart';
import 'package:iot_zone/Page/Dashboard/Dashboard-lecture.dart';
import 'package:iot_zone/Page/Asset_page/assetlender.dart';
import 'package:iot_zone/Page/History_page/history_lender.dart';

class LenderMain extends StatefulWidget {
  final Map<String, dynamic>? userData; // ✅ รับข้อมูลผู้ใช้จากหน้า login

  const LenderMain({super.key, this.userData});

  // ✅ ใช้ให้หน้าอื่นเรียกเปลี่ยนแท็บได้ เช่น LenderMain.of(context)?.changeTab(2)
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

    // ✅ ส่ง userData ไปหน้าที่ต้องใช้
    _pages = [
      Homepagelender(userData: widget.userData), // 0
      const HistoryLenderPage(), // 1
      const Center(child: Text('⚙️ Settings')), // 2
      DashboardLender(), // 3
      const Assetlender(), // 4
    ];
  }

  void changeTab(int i) {
    if (_selectedIndex == i) return;
    setState(() => _selectedIndex = i);
  }

  void _handleBottomTap(int index) {
    switch (index) {
      case 0:
        changeTab(0);
        break;
      case 1:
        changeTab(1);
        break;
      case 2:
        changeTab(2);
        break;
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
                _buildNavItem(Icons.history, 1),
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
