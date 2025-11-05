import 'package:flutter/material.dart';

class DashboardLender extends StatefulWidget {
  const DashboardLender({super.key});

  @override
  State<DashboardLender> createState() => _DashboardLenderState();
}

class _DashboardLenderState extends State<DashboardLender> {
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

  void updateStatus(String title, String newStatus, [String? reason]) {
    setState(() {
      final item = allEquipments.firstWhere((e) => e['title'] == title);
      item['status'] = newStatus;
      if (reason != null) item['reason'] = reason; // ✅ เก็บเหตุผลไว้ด้วย
      _filterSearch();
    });
  }

  void _showRejectDialog(BuildContext context, String title) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.redAccent.shade100, width: 1.2),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, color: Colors.redAccent, size: 60),
              const SizedBox(height: 12),
              const Text(
                "Reject Request",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please provide a reason for rejecting this request.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // กล่องกรอกเหตุผล
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Enter reason here...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ปุ่ม action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (reasonController.text.trim().isNotEmpty) {
                        Navigator.pop(context);
                        updateStatus(title, 'Rejected', reasonController.text);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Text(
                              'Rejected "$title" successfully.',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.send, size: 18, color: Colors.white),
                    label: const Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.black54,
                    ),
                    label: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, // ✅ ต้องใส่ชื่อ property
          ),
        ),
        backgroundColor: const Color(0xFF7C4DFF),
        centerTitle: true, // (ถ้าอยากให้ข้อความอยู่ตรงกลาง)
        elevation: 0, // (ถ้าไม่อยากให้มีเงา)
      ),
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
                  value: allEquipments
                      .where((e) => e['status'] == 'Approved')
                      .length
                      .toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                StatusCard(
                  label: 'Rejected',
                  value: allEquipments
                      .where((e) => e['status'] == 'Rejected')
                      .length
                      .toString(),
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
                  value: allEquipments
                      .where((e) => e['status'] == 'Pending')
                      .length
                      .toString(),
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
                hintText: 'Search...',
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
              'Borrowing requests (Oct 30, 2025)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            for (var item in filteredEquipments)
              EquipmentTile(
                imageUrl: item['image'],
                title: item['title'],
                borrowedBy: item['borrowedBy'],
                status: item['status'],
                onApprove: () => updateStatus(item['title'], 'Approved'),
                onReject: () => _showRejectDialog(context, item['title']),
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Helper Widgets --------------------
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
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

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
