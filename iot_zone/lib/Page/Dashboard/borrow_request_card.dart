import 'package:flutter/material.dart';

class BorrowRequestCard extends StatelessWidget {
  final Map request;
  final VoidCallback onApprove; // ✅ ระบบอนุมัติ
  final VoidCallback onReject; // ❌ ระบบปฏิเสธ

  //มีปุ่ม อนุมัติ / ปฏิเสธ
  const BorrowRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = request['status'] ?? 'pending';
    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

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
              'Request #${request['id']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text('Book: ${request['book_name'] ?? 'Unknown'}'),
            Text('Requester: ${request['user_name'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(status.toUpperCase()),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Approve',
                      onPressed: status == 'pending'
                          ? onApprove
                          : null, // ✅ จุดระบบอนุมัติ
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Reject',
                      onPressed: status == 'pending'
                          ? onReject
                          : null, // ❌ จุดระบบปฏิเสธ
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
