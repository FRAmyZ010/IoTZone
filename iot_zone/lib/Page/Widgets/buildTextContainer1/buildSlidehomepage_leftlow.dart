import 'package:flutter/material.dart';

class Buildslidehomepageleftlow extends StatelessWidget {
  final String text;
  final Color color;
  final String imagePath;
  final String position; // ✅ topRight หรือ bottomLeft

  const Buildslidehomepageleftlow({
    super.key,
    required this.text,
    required this.color,
    required this.imagePath,
    this.position = 'topRight', // 🔹 ค่าเริ่มต้นคือ ขวาบน
  });

  @override
  Widget build(BuildContext context) {
    Alignment alignment;
    EdgeInsets padding;

    switch (position) {
      case 'bottomLeft':
        alignment = Alignment.bottomLeft;
        padding = const EdgeInsets.only(bottom: 16, left: 16);
        break;
      case 'topRight':
      default:
        alignment = Alignment.topRight;
        padding = const EdgeInsets.only(top: 16, right: 16);
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        image: DecorationImage(
          image: imagePath.startsWith('http')
              ? NetworkImage(imagePath)
              : AssetImage(imagePath) as ImageProvider,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: alignment,
            child: Padding(
              padding: padding,
              child: Text(
                text,
                textAlign: position == 'topRight'
                    ? TextAlign.right
                    : TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
