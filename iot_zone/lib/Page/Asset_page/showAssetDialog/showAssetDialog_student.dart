import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iot_zone/Page/Request Status/Req_Status.dart'; // ✅ แก้ path ให้ตรงไฟล์จริง
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iot_zone/Page/api_helper.dart';

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
  bool hasActiveBorrow = false;

  @override
  void initState() {
    super.initState();
    _checkActiveBorrow();
  }

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
      if (id == null) return;

      final response = await ApiHelper.callApi(
        "/api/borrow",
        method: "POST",
        body: {'asset_id': widget.asset['id'], 'borrower_id': id},
      );

      if (response.statusCode == 200) {
        widget.onBorrowSuccess?.call();
        RequestStatusPage.refreshRequestPage?.call();
        Navigator.of(context).pop(true);
      } else {
        final body = jsonDecode(response.body);
        _showMessage(body['message'] ?? "Borrow failed");
      }
    } catch (e) {
      _showMessage("Server error: $e");
    } finally {
      setState(() => _isBorrowing = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.deepOrange),
    );
  }

  Future<void> _forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, "/login");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session expired. Please login again.")),
    );
  }

  Future<void> _checkActiveBorrow() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');

    if (id == null) return;

    final response = await ApiHelper.callApi(
      "/api/check-borrow-status/$id",
      method: "GET",
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        hasActiveBorrow = data['hasActiveRequest'] == true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final bool isAvailable =
        (asset['status'] == 'Available' || asset['status'] == 'AVAILABLE');

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
                  // 🔹 Borrow button (เปลี่ยนเป็น Unavailable หากมี borrow ค้าง)
                  ElevatedButton(
                    onPressed: (!_isBorrowing && !hasActiveBorrow)
                        ? _borrowToday
                        : () => _showMessage(
                            "You already have an active borrow request!",
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasActiveBorrow
                          ? Colors.grey
                          : Colors.deepPurpleAccent,
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
                        : Text(
                            hasActiveBorrow ? "Unavailable" : "Borrow",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),

                  // 🔹 Cancel button แยกอย่างถูกต้อง
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
