import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iot_zone/Page/Request Status/Req_Status.dart'; // ✅ แก้ path ให้ตรงไฟล์จริง
import 'package:shared_preferences/shared_preferences.dart';

class BorrowAssetDialog extends StatefulWidget {
  final Map<String, dynamic> asset;
  final VoidCallback? onBorrowSuccess; // ✅ callback สำหรับ refresh หน้า

  const BorrowAssetDialog({
    super.key,
    required this.asset,
    this.onBorrowSuccess,
  });

  @override
  State<BorrowAssetDialog> createState() => _BorrowAssetDialogState();
}

class _BorrowAssetDialogState extends State<BorrowAssetDialog> {
  final String ip = AppConfig.serverIP;
  bool _isBorrowing = false;

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

  // ✅ ฟังก์ชันยืมอุปกรณ์
  Future<void> _borrowToday() async {
    if (_isBorrowing) return;
    setState(() => _isBorrowing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      final token = prefs.getString('accessToken');
      final ip = AppConfig.serverIP;

      if (id == null || token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session expired, please login again."),
            ),
          );
        }
        await prefs.clear();
        if (mounted) Navigator.pushReplacementNamed(context, "/login");
        return;
      }

      final response = await http.post(
        Uri.parse('http://$ip:3000/api/borrow'),
        headers: {
          "Authorization": "Bearer $token", // ⭐ ส่ง token
          "Content-Type": "application/json",
        },
        body: jsonEncode({'asset_id': widget.asset['id'], 'borrower_id': id}),
      );

      final body = jsonDecode(response.body);

      // 🔥 borrow สำเร็จ
      if (response.statusCode == 200) {
        widget.onBorrowSuccess?.call();
        RequestStatusPage.refreshRequestPage?.call();
        Navigator.of(context).pop(true);
      }
      // 🔥 token หมดอายุ → ให้ logout
      else if (response.statusCode == 401 || response.statusCode == 403) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session expired, please login again."),
            ),
          );
        }
        await prefs.clear();
        if (mounted) Navigator.pushReplacementNamed(context, "/login");
        return;
      }
      // 🔥 Borrow failed (เช่น limit วันละครั้ง)
      else {
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
          title: const Text('❌ Server Error'),
          content: Text('Cannot connect to server: $e'),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              _buildImage(asset['image'] ?? ''),
              const SizedBox(height: 14),

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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ปุ่ม Borrow
                  ElevatedButton(
                    onPressed: _isBorrowing ? null : _borrowToday,
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
                    child: _isBorrowing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Borrow',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),

                  // ปุ่ม Cancel
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
      ),
    );
  }
}
