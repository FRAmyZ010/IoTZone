import 'package:flutter/material.dart';

class BorrowRequestCard extends StatelessWidget {
  final Map request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

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

    if (rawStatus is String) {
      // ใช้สถานะที่เป็น String จากการอัปเดต State ในหน้า BorrowRequestsPage
      statusString = rawStatus;
    } else if (rawStatus is int) {
      // ใช้สถานะที่เป็น Integer (1) จากการโหลดข้อมูลครั้งแรก
      if (rawStatus == 1) statusString = 'pending';
    }

    switch (statusString) {
      case '2':
        statusString = 'approved';
        statusColor = Colors.green;
        break;
      case '3':
        statusString = 'rejected';
        statusColor = Colors.red;
        break;
      case '1':
        statusColor = Colors.orange;
        statusString = 'pending';
    }

    return {'status': statusString, 'color': statusColor};
  }

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatus(request['status']);
    final status = statusData['status'] as String;
    final statusColor = statusData['color'] as Color;

    // ✅ แก้ไข: ใช้ 'name' (สำหรับ Asset Name) และ 'borrowerName' (สำหรับชื่อผู้ขอยืม)
    final assetName = request['name'] ?? 'Unknown Asset';
    final borrowerName = request['borrowerName'] ?? 'Unknown Requester';

    // จัดรูปแบบวันที่ให้สั้นลง
    final borrowDate = request['borrowDate'] != null
        ? request['borrowDate'].toString().substring(0, 10)
        : '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request No. #${request['id']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('Asset: $assetName', style: const TextStyle(fontSize: 14)),
            Text(
              'Borrower: $borrowerName',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Borrow date: $borrowDate',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    status == 'approved'
                        ? 'Approved'
                        : status == 'rejected'
                        ? 'Rejected'
                        : 'Pending',
                  ),
                  backgroundColor: statusColor.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: status == 'approved'
                        ? Colors.green
                        : status == 'rejected'
                        ? Colors.red
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // เปลี่ยนเป็น ElevatedButton.icon เพื่อให้ปุ่มใช้งานง่ายขึ้น
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('APPROVE'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      // ปุ่มจะใช้งานได้เมื่อสถานะเป็น pending เท่านั้น
                      onPressed: status == 'pending' ? onApprove : null,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      // ปุ่มจะใช้งานได้เมื่อสถานะเป็น pending เท่านั้น
                      onPressed: status == 'pending' ? onReject : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
