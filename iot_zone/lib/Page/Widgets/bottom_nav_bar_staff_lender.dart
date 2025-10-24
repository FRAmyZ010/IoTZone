import 'package:flutter/material.dart';

class BottomNavBarStaffLender extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBarStaffLender({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 💜 Gradient Border
          Container(
            height: 63,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(
                colors: [Color(0xFF4D5DFF), Color(0xFFC368FF)],
              ),
            ),
          ),

          // ⚪ พื้นขาว
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
                  _buildIcon(Icons.home, 0, currentIndex, onTap),
                  _buildIcon(Icons.history, 1, currentIndex, onTap),
                  _buildIcon(Icons.window, 2, currentIndex, onTap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(
    IconData icon,
    int index,
    int currentIndex,
    Function(int) onTap,
  ) {
    final bool isActive = currentIndex == index;
    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        size: 26,
        color: isActive ? const Color(0xFF6B45FF) : Colors.black,
      ),
    );
  }
}
