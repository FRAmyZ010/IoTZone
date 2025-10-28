import 'package:flutter/material.dart';
import '../../homepagelender.dart';

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
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAnimatedIcon(Icons.home, 0),
                  _buildAnimatedIcon(Icons.history, 1),
                  _buildAnimatedIcon(Icons.window, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    final bool isActive = _selectedIndex == index;

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isActive ? 1.2 : 1.0,
      child: IconButton(
        onPressed: () {
          setState(() => _selectedIndex = index);

          if (index == 0) {
            // ✅ กลับไปหน้า Homepage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Homepagelender()),
              (route) => false,
            );
          } else {
            widget.onTap(index);
          }
        },

        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            icon,
            key: ValueKey(isActive),
            size: 26,
            color: isActive ? const Color(0xFF6B45FF) : Colors.black,
          ),
        ),
      ),
    );
  }
}
