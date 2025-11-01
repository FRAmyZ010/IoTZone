import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BorrowAssetDialog extends StatefulWidget {
  final Map<String, dynamic> asset;

  const BorrowAssetDialog({super.key, required this.asset});

  @override
  State<BorrowAssetDialog> createState() => _BorrowAssetDialogState();
}

class _BorrowAssetDialogState extends State<BorrowAssetDialog> {
  final String ip = AppConfig.serverIP;

  // ✅ โหลดรูปภาพสินทรัพย์
  Widget _buildImage(String imagePath) {
    final borderRadius = BorderRadius.circular(18);
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain,
            child:
                imagePath.startsWith('/uploads/') || imagePath.contains('http')
                ? Image.network(
                    'http://$ip:3000$imagePath',
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 70,
                      color: Colors.grey,
                    ),
                  )
                : Image.asset(
                    imagePath,
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 70,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  bool _isBorrowing = false;

  void _borrowToday() async {
    if (_isBorrowing) return; // 🔒 ป้องกันกดซ้ำ
    setState(() => _isBorrowing = true);

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    try {
      final response = await http.post(
        Uri.parse('http://$ip:3000/api/borrow'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'asset_id': widget.asset['id'], 'borrower_id': 1}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Borrowed "${widget.asset['name']}" (${DateFormat('MMM d').format(now)} → ${DateFormat('MMM d').format(tomorrow)})',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ❌ ถ้ายืมไม่ได้
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('⚠ Cannot Borrow'),
            content: Text(body['message'] ?? 'Borrow failed'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('❌ Error'),
          content: Text('Server error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isBorrowing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 70),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 หัวข้อชื่ออุปกรณ์
            Text(
              asset['name'] ?? "Unknown Asset",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // 🔹 รูปภาพ
            _buildImage(asset['image'] ?? ''),
            const SizedBox(height: 14),

            // 🔹 คำเตือน
            const Text(
              "* You can only borrow 1 asset per day",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 🔹 คำอธิบาย
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                asset['description'] ?? 'No description available.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 26),

            // 🔹 ปุ่มยืม / ยกเลิก
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _borrowToday,
                  label: const Text(
                    'Borrow',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 5,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
