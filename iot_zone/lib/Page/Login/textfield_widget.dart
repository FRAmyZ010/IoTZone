import 'package:flutter/material.dart';

class InputFieldWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String assetPath; // สำหรับ path ของ icon
  final double iconWidth;

  const InputFieldWidget({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.assetPath,
    this.iconWidth = 30.0, // กำหนดค่าเริ่มต้น
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Icon
        Image.asset(assetPath, width: iconWidth),

        // 2. ระยะห่าง (Space)
        const SizedBox(width: 20),

        // 3. TextField (ห่อด้วย SizedBox ตามเดิม)
        SizedBox(
          width: 220, // สามารถทำให้ยืดหยุ่นกว่านี้ได้ (เช่นใช้ Expanded)
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 28,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
