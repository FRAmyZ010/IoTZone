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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> allEquipments = [
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/3602/3602145.png',
      'title': 'Sensor',
      'borrowedBy': 'max',
      'status': 'Pending',
    },
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/2910/2910768.png',
      'title': 'Capacitor',
      'borrowedBy': 'C',
      'status': 'Pending',
    },
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/2942/2942724.png',
      'title': 'Board',
      'borrowedBy': 'Ice',
      'status': 'Pending',
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
        final title = item['title'].toString().toLowerCase();
        final borrower = item['borrowedBy'].toString().toLowerCase();
        return title.contains(query) || borrower.contains(query);
      }).toList();
    });
  }

  int get approvedCount =>
      allEquipments.where((e) => e['status'] == 'Approved').length;
  int get rejectedCount =>
      allEquipments.where((e) => e['status'] == 'Rejected').length;
  int get pendingCount =>
      allEquipments.where((e) => e['status'] == 'Pending').length;

  void updateStatus(String title, String newStatus) {
    setState(() {
      final item = allEquipments.firstWhere((e) => e['title'] == title);
      item['status'] = newStatus;
      _filterSearch();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: const Color(0xFF7C4DFF),
          padding: const EdgeInsets.only(top: 25, left: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {},
              ),
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),

      // ---------------- Body ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusCard(
                  label: 'Pending',
                  value: pendingCount.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Borrowing request on Oct 30, 2025',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            for (var item in filteredEquipments)
              EquipmentTile(
                imageUrl: item['image'],
                title: item['title'],
                borrowedBy: item['borrowedBy'],
                status: item['status'],
                onApprove: () => _showApproveDialog(context, item['title']),
                onReject: () => _showRejectDialog(context, item['title']),
              ),

            if (filteredEquipments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No matching items found',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
          ],
        ),
      ),

      // ---------------- Bottom Navigation ----------------
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          color: Colors.grey.shade200,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Icon(Icons.home, size: 28, color: Colors.black),
            Icon(Icons.dashboard, size: 28, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // -------- Dialogs --------
  void _showApproveDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 10),
            const Text("This request has been confirmed.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25))),
              onPressed: () {
                Navigator.pop(context);
                updateStatus(title, 'Approved');
              },
              child: const Text("Close",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String title) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Reject reason",
                    style: TextStyle(color: Colors.red, fontSize: 14))),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    updateStatus(title, 'Rejected');
                  },
                  child: const Text("Send",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}

// ---------------- Status Card ----------------
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label),
          ],
        ),
      ),
    );
  }
}

// ---------------- Equipment Tile ----------------
class EquipmentTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String borrowedBy;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const EquipmentTile({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.borrowedBy,
    required this.status,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Approved':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      color: const Color(0xFFF4EFFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.network(imageUrl, width: 40, height: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Borrowed by $borrowedBy'),
        trailing: status == 'Pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton('Approve', Colors.green, onApprove),
                  const SizedBox(width: 6),
                  _actionButton('Reject', Colors.red, onReject),
                ],
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold),
                ),
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
