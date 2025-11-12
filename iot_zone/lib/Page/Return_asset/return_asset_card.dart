import 'package:flutter/material.dart';

// 📝 Card สำหรับแสดงข้อมูลครุภัณฑ์ที่ "รอรับคืน"
class ReturnAssetCard extends StatelessWidget {
  final Map request;
  // ✅ ฟังก์ชันสำหรับรับคืนครุภัณฑ์ (รับ history id และ asset_id)
  final void Function(int historyId, int assetId) onAcceptReturn;

  const ReturnAssetCard({
    super.key,
    required this.request,
    required this.onAcceptReturn,
  });

  // 🔹 ฟังก์ชันแปลงสถานะจากตัวเลข/สตริงให้เป็นสตริงมาตรฐานและกำหนดสี
  // ในหน้า Return Asset นี้ สถานะที่ดึงมาจะเป็น '2' (รอนำกลับมาคืน) เสมอ
  Map<String, dynamic> _getStatus(dynamic rawStatus) {
    String statusString = 'Pending Return';
    Color statusColor = Colors.blue;
    int statusInt = 2; 

    if (rawStatus is String) {
      statusInt = int.tryParse(rawStatus) ?? 2;
    } else if (rawStatus is int) {
      statusInt = rawStatus;
    }

    // ในระบบรับคืน สถานะที่สนใจคือ 2 (รอนำกลับมาคืน)
    switch (statusInt) {
      case 2:
        statusString = 'Pending Return';
        statusColor = Colors.blue;
        break;
      case 4: // สถานะ 4: Received (รับคืนแล้ว)
        statusString = 'Received';
        statusColor = Colors.green;
        break;
      default: 
        statusString = 'Unknown Status';
        statusColor = Colors.grey;
    }

    return {
      'status': statusString,
      'color': statusColor,
      'rawStatus': statusInt,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatus(request['status']);
    final status = statusData['status'] as String;
    final statusColor = statusData['color'] as Color;
    final rawStatus = statusData['rawStatus'] as int;

    // 💡 ดึงข้อมูลจากการ JOIN Table ใน Backend
    final assetName = request['asset_name'] ?? 'Unknown Asset';
    final borrowerName = request['borrower_name'] ?? 'Unknown Borrower'; // ดึงจากชื่อที่ Join
    final approverName = request['approver_name'] ?? 'N/A'; // 🌟 เพิ่มชื่อ Approver
    
    // กำหนด path รูปภาพ
    final imagePath = 'asset/img/${request['img'] ?? 'default.png'}';

    // จัดรูปแบบวันที่ให้สั้นลง
    final borrowDate =
        request['borrow_date'] != null // 💡 ใช้ borrow_date จาก DB
            ? request['borrow_date'].toString().substring(0, 10)
            : '-';

    final returnDate =
        request['return_date'] != null // 🗓️ เพิ่ม return_date
            ? request['return_date'].toString().substring(0, 10)
            : 'N/A';

    // 🔹 ฟังก์ชันสำหรับสร้าง Text Row
    Widget _buildInfoRow(String title, String value, {Color? valueColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(
                '$title:',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ดึง ID ที่จำเป็นสำหรับการ Accept Return
    final historyId = request['id'] as int;
    final assetId = request['asset_id'] as int;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🖼️ ส่วนแสดงรูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 📝 ส่วนแสดงข้อมูล
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assetName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildInfoRow('Borrower', borrowerName),
                  _buildInfoRow('Approver', approverName), // 🌟 แสดงชื่อ Approver
                  _buildInfoRow('Borrow Date', borrowDate),
                  _buildInfoRow(
                    'Return Date',
                    returnDate,
                    valueColor: Colors.red.shade700, // เน้นวันที่คืน
                  ),

                  const SizedBox(height: 8),

                  // ⚙️ ส่วนสถานะและปุ่ม
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(status.toUpperCase()),
                        backgroundColor: statusColor.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 1. ปุ่ม Accept Return (แสดงเมื่อสถานะเป็น 'Pending Return' เท่านั้น)
                      if (rawStatus == 2)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download_done, size: 18),
                          label: const Text(
                            'ACCEPT RETURN',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                          onPressed: () => onAcceptReturn(historyId, assetId),
                        ),
                      // 2. ถ้าสถานะไม่ใช่ 2, แสดงป้าย 'Received' แทนปุ่ม
                      if (rawStatus == 4)
                        const Chip(
                           label: Text('RECEIVED'),
                           backgroundColor: Color.fromARGB(255, 187, 240, 190),
                           labelStyle: TextStyle(
                            color: Color.fromARGB(255, 33, 117, 36),
                            fontWeight: FontWeight.bold,
                           ),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}