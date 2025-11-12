import 'package:flutter/material.dart';

class BorrowRequestCard extends StatelessWidget {
  final Map request;
  final void Function(int id) onApprove; // เปลี่ยนเป็น function รับ id
  final void Function(int id) onReject; // เปลี่ยนเป็น function รับ id

  // มีปุ่ม อนุมัติ / ปฏิเสธ
  const BorrowRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  // 🔹 ฟังก์ชันแปลงสถานะจากตัวเลข/สตริงให้เป็นสตริงมาตรฐานและกำหนดสี
  Map<String, dynamic> _getStatus(dynamic rawStatus) {
    String statusString = 'pending';
    Color statusColor = Colors.orange;
    int statusInt = 1; // สถานะตัวเลขเริ่มต้นเป็น 1 (pending)

    if (rawStatus is String) {
      // พยายามแปลง String เป็น Integer
      statusInt = int.tryParse(rawStatus) ?? 1;
    } else if (rawStatus is int) {
      // ใช้สถานะที่เป็น Integer
      statusInt = rawStatus;
    }

    // 💡 ใช้ statusInt ในการกำหนดสถานะและสี (1: Pending, 2: Approved, 3: Rejected)
    switch (statusInt) {
      case 2:
        statusString = 'approved';
        statusColor = Colors.green;
        break;
      case 3:
        statusString = 'rejected';
        statusColor = Colors.red;
        break;
      default: // 1 หรือค่าอื่น ๆ ที่ไม่รู้จัก
        statusString = 'pending';
        statusColor = Colors.orange;
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

    final assetName =
        request['asset_name'] ??
        request['name'] ??
        'Unknown Asset'; // 💡 ใช้ asset_name จาก DB
    final borrowerName = request['borrowerName'] ?? 'Unknown Requester';
    final imagePath =
        'asset/img/${request['img'] ?? 'default.png'}'; // 🖼️ กำหนด path รูป

    // จัดรูปแบบวันที่ให้สั้นลง
    final borrowDate =
        request['borrowDate'] !=
            null // 💡 ใช้ borrow_date จาก DB
        ? request['borrowDate'].toString().substring(0, 10)
        : '-';

    final returnDate =
        request['returnDate'] !=
            null // 🗓️ เพิ่ม return_date
        ? request['returnDate'].toString().substring(0, 10)
        : 'N/A';

    final reason = request['reason'] ?? ''; // 📝 เพิ่ม reason

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
                  // _buildInfoRow(
                  //   'ID',
                  //   '#${request['id']}',
                  //   valueColor: Colors.purple,
                  // ),
                  _buildInfoRow('Borrower', borrowerName),
                  _buildInfoRow('Borrow Date', borrowDate),
                  _buildInfoRow(
                    'Return Date',
                    returnDate,
                    valueColor: status == 'approved'
                        ? Colors.blue.shade700
                        : Colors.grey,
                  ),

                  // ✅ โค้ดส่วนนี้จะแสดงเหตุผลการปฏิเสธ (ถ้ามี)
                  if (status == 'rejected' && reason != null)
                    _buildInfoRow('Reason', reason, valueColor: Colors.red),

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
                      Row(
                        children: [
                          // ปุ่ม Approve
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text(
                              'APPROVE',
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
                            // ปุ่มจะใช้งานได้เมื่อสถานะเป็น pending (1) เท่านั้น
                            onPressed: rawStatus == 1
                                ? () => onApprove(request['id'])
                                : null,
                          ),
                          const SizedBox(width: 8),
                          // ปุ่ม Reject
                          ElevatedButton.icon(
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text(
                              'REJECT',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                            ),
                            // ปุ่มจะใช้งานได้เมื่อสถานะเป็น pending (1) เท่านั้น
                            onPressed: rawStatus == 1
                                ? () => onReject(request['id'])
                                : null,
                          ),
                        ],
                      ),
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
