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

// 🔹 Dashboard Page (มีช่อง search + รายการ Borrowed)
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController searchController = TextEditingController();

  // 🔸 รายการ Borrowed ทั้งหมด
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

  // 🔹 เก็บผลลัพธ์ที่ค้นหา
  List<Map<String, String>> filteredEquipments = [];

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
        final title = item['title']!.toLowerCase();
        final borrower = item['borrowedBy']!.toLowerCase();
        return title.contains(query) || borrower.contains(query);
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
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: const Color(0xFF7C4DFF),
          padding: const EdgeInsets.only(top: 25, left: 16),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
      ),

      // 🔸 Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatusCard(
                  label: 'Available',
                  value: '2',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                StatusCard(
                  label: 'Disabled',
                  value: '1',
                  icon: Icons.block,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatusCard(
                  label: 'Pending',
                  value: '3',
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
                StatusCard(
                  label: 'Borrowed',
                  value: '4',
                  icon: Icons.shopping_bag,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by item or borrower...',
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
              'Borrowed Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 🔹 แสดงรายการ Borrowed
            for (var item in filteredEquipments)
              EquipmentTile(
                imageUrl: item['image']!,
                title: item['title']!,
                borrowedBy: item['borrowedBy']!,
                borrowedOn: item['borrowedOn']!,
                approvedBy: item['approvedBy']!,
                returnedOn: item['returnedOn']!,
              ),

            if (filteredEquipments.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    'No matching items found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),

      // 🔸 Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          color: Colors.grey.shade200,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.home, size: 28, color: Colors.black),
            Icon(Icons.dashboard, size: 28, color: Colors.black),
            Icon(Icons.settings, size: 28, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

// ---------- Status Card ----------
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

// ---------- Equipment Tile ----------
class EquipmentTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String borrowedBy;
  final String borrowedOn;
  final String approvedBy;
  final String returnedOn;

  const EquipmentTile({
    super.key,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.network(imageUrl, width: 40, height: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Borrowed by $borrowedBy'),
        trailing: GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => EquipmentDialog(
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

// ---------- Popup Dialog ----------
class EquipmentDialog extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String borrower;
  final String borrowedOn;
  final String approvedBy;
  final String returnedOn;

  const EquipmentDialog({
    super.key,
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
            Image.network(imageUrl, width: 70, height: 70),
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
            const SizedBox(height: 15),
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
