import 'package:flutter/material.dart';

class ShowAssetDialogLender extends StatelessWidget {
  final Map<String, dynamic> asset;
  const ShowAssetDialogLender({super.key, required this.asset});

  final String ip = '192.168.145.1'; // ✅ กำหนด IP ที่ใช้ใน network

  // ✅ โหลดภาพแบบสมส่วน (รองรับทั้ง http, /uploads/, uploads/, asset/)
  Widget _buildImage(String imagePath) {
    final borderRadius = BorderRadius.circular(16);
    final bool isNetwork =
        imagePath.startsWith('http') || imagePath.contains('uploads/');

    String finalUrl = imagePath;
    if (!imagePath.startsWith('http')) {
      if (imagePath.startsWith('/uploads/')) {
        finalUrl = 'http://$ip:3000$imagePath';
      } else if (imagePath.startsWith('uploads/')) {
        finalUrl = 'http://$ip:3000/$imagePath';
      } else {
        // ใช้รูปใน asset
        finalUrl = imagePath;
      }
    }

    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain,
            child: isNetwork
                ? Image.network(
                    finalUrl,
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
                    finalUrl,
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

  // ✅ กำหนดสีตามสถานะ
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'disabled':
        return Colors.redAccent;
      case 'pending':
        return Colors.orange;
      case 'borrowed':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = asset['name'] ?? "Unknown Asset";
    final String type = asset['type'] ?? 'Unknown';
    final String status = asset['status'] ?? 'N/A';
    final String description = asset['description']?.isNotEmpty == true
        ? asset['description']
        : 'No description available';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Asset Name
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 14),

            // 🔹 Image
            _buildImage(asset['image'] ?? ''),
            const SizedBox(height: 14),

            // 🔹 Read-only label
            const Text(
              "You can only view asset details",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Type
            Text(
              "Type: $type",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Status (มีสี + ฟอนต์ใหญ่)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),

                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // 🔹 Close Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 45,
                  vertical: 14,
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
