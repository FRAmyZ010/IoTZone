import 'package:flutter/material.dart';
import 'package:iot_zone/Page/homepagelender.dart';
import 'package:iot_zone/Page/Dashboard/Dashboard-lecture.dart';
import 'package:iot_zone/Page/Asset_page/assetlender.dart';
import 'package:iot_zone/Page/History_page/history_lender.dart';

class LenderMain extends StatefulWidget {
  const LenderMain({super.key});

  // ✅ ให้ลูก ๆ เรียกเปลี่ยนแท็บได้: LenderMain.of(context)?.changeTab(2)
  static _LenderMainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_LenderMainState>();

  @override
  State<LenderMain> createState() => _LenderMainState();
}

class _LenderMainState extends State<LenderMain> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Homepagelender(), // 0
    HistoryLenderPage(), // 1
    DashboardLender(), // 2
    Assetlender(), // 3  ← เพิ่มแท็บ Asset ไว้ใน Shell
  ];

  static _LenderMainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_LenderMainState>();

  void changeTab(int i) {
    if (_selectedIndex == i) return;
    setState(() => _selectedIndex = i);
  }

  // ถ้าต้องการให้ bottom bar เปิด route บางอันก็ทำ handler แบบนี้ได้
  void _handleBottomTap(int index) {
    // ตัวอย่าง: ทั้ง 3 ปุ่มสลับแท็บใน Shell
    changeTab(index);
    // หรือถ้าจะให้ index 1 เปิดหน้าชื่อ '/history':
    // if (index == 1) Navigator.pushNamed(context, '/history'); else changeTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      // ✅ คง state ของแต่ละหน้า
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
                _buildNavItem(Icons.home, 0),
                _buildNavItem(Icons.history, 1),
                _buildNavItem(Icons.dashboard, 2), // ชัดว่าเป็น Dashboard
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
