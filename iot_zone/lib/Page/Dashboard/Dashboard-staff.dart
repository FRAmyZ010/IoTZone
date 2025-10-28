import 'package:flutter/material.dart';

/// ใช้เป็น "Body widget" สำหรับหน้า Dashboard (Staff/Lecture)
class DashboardStaff extends StatefulWidget {
  const DashboardStaff({super.key});

  @override
  State<DashboardStaff> createState() => _DashboardStaffState();
}

class _DashboardStaffState extends State<DashboardStaff> {
  final TextEditingController searchController = TextEditingController();

  // รายการ Borrowed (ตัวอย่าง)
  final List<Map<String, String>> allEquipments = [
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/1048/1048953.png',
      'title': 'Sensor',
      'borrowedBy': 'Ice',
      'borrowedOn': 'Oct 29, 2025',
      'approvedBy': 'Prof. Lecture',
      'returnedOn': 'Oct 30, 2025',
    },
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/2645/2645897.png',
      'title': 'Multimeter',
      'borrowedBy': 'Max',
      'borrowedOn': 'Oct 29, 2025',
      'approvedBy': 'Prof. Lecture',
      'returnedOn': 'Oct 30, 2025',
    },
    {
      'image': 'https://cdn-icons-png.flaticon.com/512/3081/3081988.png',
      'title': 'Capacitor',
      'borrowedBy': 'C',
      'borrowedOn': 'Oct 29, 2025',
      'approvedBy': 'Dr. Lecture',
      'returnedOn': 'Oct 30, 2025',
    },
  ];

  // เก็บผลลัพธ์ที่ค้นหา
  late List<Map<String, String>> filteredEquipments;

  @override
  void initState() {
    super.initState();
    filteredEquipments = List.from(allEquipments);
    searchController.addListener(_filterSearch);
  }

  void _filterSearch() {
    final q = searchController.text.toLowerCase().trim();
    setState(() {
      filteredEquipments = allEquipments.where((item) {
        final title = item['title']!.toLowerCase();
        final borrower = item['borrowedBy']!.toLowerCase();
        return title.contains(q) || borrower.contains(q);
      }).toList();
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
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, // ✅ ต้องใส่ชื่อ property
          ),
        ),
        backgroundColor: const Color(0xFF7C4DFF),
        elevation: 0, // (ถ้าไม่อยากให้มีเงา)
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards (2 แถว ๆ ละ 2 ใบ)
              Row(
                children: const [
                  Expanded(
                    child: _StatusCard(
                      label: 'Available',
                      value: '2',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _StatusCard(
                      label: 'Disabled',
                      value: '1',
                      icon: Icons.block,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(
                    child: _StatusCard(
                      label: 'Pending',
                      value: '3',
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _StatusCard(
                      label: 'Borrowed',
                      value: '4',
                      icon: Icons.shopping_bag,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by item or borrower...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Borrowed Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // รายการ Borrowed (เลื่อนลื่น + ไม่ Overflow)
              Expanded(
                child: filteredEquipments.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching items found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredEquipments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final item = filteredEquipments[i];
                          return _EquipmentTile(
                            imageUrl: item['image']!,
                            title: item['title']!,
                            borrowedBy: item['borrowedBy']!,
                            borrowedOn: item['borrowedOn']!,
                            approvedBy: item['approvedBy']!,
                            returnedOn: item['returnedOn']!,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF6F2FB),
    );
  }
}

// ---------- Internal widgets (private) ----------

class _StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: -4,
            offset: Offset(0, 8),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String borrowedBy;
  final String borrowedOn;
  final String approvedBy;
  final String returnedOn;

  const _EquipmentTile({
    required this.imageUrl,
    required this.title,
    required this.borrowedBy,
    required this.borrowedOn,
    required this.approvedBy,
    required this.returnedOn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF4EFFA),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Borrowed by $borrowedBy'),
        trailing: GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => _EquipmentDialog(
              imageUrl: imageUrl,
              title: title,
              borrower: borrowedBy,
              borrowedOn: borrowedOn,
              approvedBy: approvedBy,
              returnedOn: returnedOn,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD9F2DD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Accept',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EquipmentDialog extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String borrower;
  final String borrowedOn;
  final String approvedBy;
  final String returnedOn;

  const _EquipmentDialog({
    required this.imageUrl,
    required this.title,
    required this.borrower,
    required this.borrowedOn,
    required this.approvedBy,
    required this.returnedOn,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF4EFFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text('Borrower: $borrower'),
            Text('Borrowed on: $borrowedOn'),
            Text('Approved by: $approvedBy'),
            Text('Returned on: $returnedOn'),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CONFIRM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
