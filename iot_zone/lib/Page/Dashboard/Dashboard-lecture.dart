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
// 🔹 DASHBOARD PAGE
// -------------------------------------------------------
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  final int approvedCount = 5;
  final int pendingCount = 3;
  final int rejectedCount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C4DFF),
        elevation: 0,
        title: const Text(
          'Dashboard Overview',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Asset Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                StatusCard(
                  label: 'Approved',
                  value: approvedCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                StatusCard(
                  label: 'Rejected',
                  value: rejectedCount.toString(),
                  icon: Icons.block,
                  color: Colors.red,
                ),
                StatusCard(
                  label: 'Pending',
                  value: pendingCount.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.list, color: Colors.white),
                label: const Text(
                  "View Borrow Requests",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BorrowingRequestPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// 🔹 STATUS CARD
// -------------------------------------------------------
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
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
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

// -------------------------------------------------------
// 🔹 BORROWING REQUEST PAGE
// -------------------------------------------------------
class BorrowingRequestPage extends StatefulWidget {
  const BorrowingRequestPage({super.key});

  @override
  State<BorrowingRequestPage> createState() => _BorrowingRequestPageState();
}

class _BorrowingRequestPageState extends State<BorrowingRequestPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> allEquipments = [
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/3602/3602145.png',
      'title': 'Sensor',
      'borrowedBy': 'Max',
      'borrowDate': 'Nov 10, 2025',
      'returnDate': 'Nov 12, 2025',
      'status': 'Pending',
      'rejectReason': ''
    },
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/2910/2910768.png',
      'title': 'Capacitor',
      'borrowedBy': 'C',
      'borrowDate': 'Nov 10, 2025',
      'returnDate': 'Nov 11, 2025',
      'status': 'Pending',
      'rejectReason': ''
    },
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/2942/2942724.png',
      'title': 'Board',
      'borrowedBy': 'Ice',
      'borrowDate': 'Nov 10, 2025',
      'returnDate': 'Nov 13, 2025',
      'status': 'Pending',
      'rejectReason': ''
    },
  ];

  List<Map<String, dynamic>> filteredEquipments = [];

  @override
  void initState() {
    super.initState();
    filteredEquipments = List.from(allEquipments);
    searchController.addListener(_filterSearch);
  }

  void _filterSearch() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredEquipments = allEquipments.where((item) {
        return item['title'].toLowerCase().contains(query) ||
            item['borrowedBy'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void updateStatus(String title, String newStatus, {String reason = ""}) {
    setState(() {
      final item = allEquipments.firstWhere((e) => e['title'] == title);
      item['status'] = newStatus;
      item['rejectReason'] = reason;
      _filterSearch();
    });
  }

  void showRejectDialog(String title) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Request"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: "Enter rejection reason",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Submit"),
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                updateStatus(title, 'Rejected', reason: reasonController.text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C4DFF),
        title: const Text(
          "Borrowing Requests",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search equipment or borrower',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEquipments.length,
                itemBuilder: (context, index) {
                  final item = filteredEquipments[index];
                  return EquipmentTile(
                    imageUrl: item['image'],
                    title: item['title'],
                    borrowedBy: item['borrowedBy'],
                    borrowDate: item['borrowDate'],
                    returnDate: item['returnDate'],
                    status: item['status'],
                    rejectReason: item['rejectReason'],
                    onApprove: () => updateStatus(item['title'], 'Approved'),
                    onReject: () => showRejectDialog(item['title']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// 🔹 EQUIPMENT TILE (ปุ่มหายเมื่อไม่ Pending + มีแสดงเหตุผลถ้า Reject)
// -------------------------------------------------------
class EquipmentTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String borrowedBy;
  final String borrowDate;
  final String returnDate;
  final String status;
  final String rejectReason;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const EquipmentTile({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.borrowedBy,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
    required this.rejectReason,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Approved'
        ? Colors.green
        : status == 'Rejected'
            ? Colors.red
            : Colors.orange;

    return Card(
      color: const Color(0xFFF4EFFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(imageUrl, width: 40, height: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Borrowed by: $borrowedBy'),
            Text('Borrow Date: $borrowDate'),
            Text('Return Date: $returnDate'),
            
            if (status == 'Rejected' && rejectReason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text("Reason: $rejectReason", style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 8),

            if (status == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton('Approve', Colors.green, onApprove),
                  const SizedBox(width: 6),
                  _actionButton('Reject', Colors.red, onReject),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
