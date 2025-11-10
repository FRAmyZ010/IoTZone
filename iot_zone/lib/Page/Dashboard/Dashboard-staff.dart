import 'package:flutter/material.dart';

void main() {
  runApp(const SafeAreaApp());
}

class SafeAreaApp extends StatelessWidget {
  const SafeAreaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

// -------------------------------------------------------
// 🔹 DASHBOARD PAGE (หน้าแยกแสดงสรุปสถานะประจำวัน)
// -------------------------------------------------------
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // 🔸 Mock data ตัวอย่างสรุปสถานะของ asset วันนี้
  final int availableCount = 5;
  final int pendingCount = 3;
  final int disabledCount = 1;
  final int borrowedCount = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: const Color(0xFF7C4DFF),
          padding: const EdgeInsets.only(top: 25, left: 16),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Dashboard Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today’s Asset Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusCard(
                  label: 'Available',
                  value: availableCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                StatusCard(
                  label: 'Disabled',
                  value: disabledCount.toString(),
                  icon: Icons.block,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusCard(
                  label: 'Pending',
                  value: pendingCount.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
                StatusCard(
                  label: 'Borrowed',
                  value: borrowedCount.toString(),
                  icon: Icons.shopping_bag,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),

      // bottomNavigationBar: Container(
      //   decoration: BoxDecoration(
      //     borderRadius: const BorderRadius.only(
      //       topLeft: Radius.circular(25),
      //       topRight: Radius.circular(25),
      //     ),
      //     color: Colors.grey.shade200,
      //   ),
      //   padding: const EdgeInsets.symmetric(vertical: 8),
      //   child: const Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       Icon(Icons.home, size: 28, color: Colors.black),
      //       Icon(Icons.dashboard, size: 28, color: Colors.deepPurple),
      //       Icon(Icons.settings, size: 28, color: Colors.black),
      //     ],
      //   ),
      // ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatusCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
