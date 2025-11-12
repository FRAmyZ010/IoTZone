import 'package:flutter/material.dart';

class BorrowRequestCard extends StatelessWidget {
  final Map request;
  final void Function(int id) onApprove;
  final void Function(int id) onReject;

  const BorrowRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  Map<String, dynamic> _getStatus(dynamic rawStatus) {
    String statusString = 'pending';
    Color statusColor = Colors.orange;
    int statusInt = 1;

    if (rawStatus is String) {
      statusInt = int.tryParse(rawStatus) ?? 1;
    } else if (rawStatus is int) {
      statusInt = rawStatus;
    }

    switch (statusInt) {
      case 2:
        statusString = 'approved';
        statusColor = Colors.green;
        break;
      case 3:
        statusString = 'rejected';
        statusColor = Colors.red;
        break;
      default:
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
        request['asset_name'] ?? request['name'] ?? 'Unknown Asset';
    final borrowerName = request['borrowerName'] ?? 'Unknown Requester';
    final imagePath = 'asset/img/${request['img'] ?? 'default.png'}';
    final borrowDate =
        request['borrowDate']?.toString().substring(0, 10) ?? '-';
    final returnDate =
        request['returnDate']?.toString().substring(0, 10) ?? 'N/A';
    final reason = request['reason'] ?? '';

    Widget _buildInfoRow(String title, String value, {Color? valueColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 95,
              child: Text(
                '$title:',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _statusTag(String text, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชื่ออุปกรณ์
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              assetName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปภาพ
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // รายละเอียด
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Borrower', borrowerName),
                    _buildInfoRow('Borrow Date', borrowDate),
                    _buildInfoRow(
                      'Return Date',
                      returnDate,
                      valueColor: status == 'approved'
                          ? Colors.blue.shade700
                          : Colors.grey,
                    ),
                    if (status == 'rejected' && reason.isNotEmpty)
                      _buildInfoRow('Reason', reason, valueColor: Colors.red),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // แถวสถานะ + ปุ่ม
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusTag(status, statusColor),
              Row(
                children: [
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
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: rawStatus == 1
                        ? () => onApprove(request['id'])
                        : null,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('REJECT', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
    );
  }
}
