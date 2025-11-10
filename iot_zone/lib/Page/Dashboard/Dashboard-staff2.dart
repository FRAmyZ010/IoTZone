// import 'package:flutter/material.dart';

// void main() {
//   runApp(const SafeAreaApp());
// }

// class SafeAreaApp extends StatelessWidget {
//   const SafeAreaApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: DashboardPage(),
//     );
//   }
// }

// // 🔹 Dashboard Page
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   final TextEditingController searchController = TextEditingController();

//   // 🔸 รายการ Borrowed ทั้งหมด
//   final List<Map<String, dynamic>> allEquipments = [
//     {
//       'image': 'https://cdn-icons-png.flaticon.com/512/1048/1048953.png',
//       'title': 'Sensor',
//       'borrowedBy': 'Ice',
//       'borrowedOn': 'Oct 29, 2025',
//       'status': 'Pending',
//     },
//     {
//       'image': 'https://cdn-icons-png.flaticon.com/512/2645/2645897.png',
//       'title': 'Multimeter',
//       'borrowedBy': 'Max',
//       'borrowedOn': 'Oct 29, 2025',
//       'status': 'Pending',
//     },
//     {
//       'image': 'https://cdn-icons-png.flaticon.com/512/3081/3081988.png',
//       'title': 'Capacitor',
//       'borrowedBy': 'C',
//       'borrowedOn': 'Oct 29, 2025',
//       'status': 'Pending',
//     },
//   ];

//   List<Map<String, dynamic>> filteredEquipments = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredEquipments = List.from(allEquipments);
//     searchController.addListener(_filterSearch);
//   }

//   void _filterSearch() {
//     String query = searchController.text.toLowerCase();
//     setState(() {
//       filteredEquipments = allEquipments.where((item) {
//         final title = item['title']!.toLowerCase();
//         final borrower = item['borrowedBy']!.toLowerCase();
//         return title.contains(query) || borrower.contains(query);
//       }).toList();
//     });
//   }

//   void _confirmRequest(int index) {
//     setState(() {
//       filteredEquipments[index]['status'] = 'Confirmed';
//       // อัปเดตใน allEquipments ด้วย เพื่อให้ข้อมูลตรงกัน
//       int originalIndex = allEquipments.indexWhere(
//           (e) => e['title'] == filteredEquipments[index]['title']);
//       if (originalIndex != -1) {
//         allEquipments[originalIndex]['status'] = 'Confirmed';
//       }
//     });
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F2FB),
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         backgroundColor: const Color(0xFF7C4DFF),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🔹 Search Bar
//             TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search),
//                 hintText: 'Search by item or borrower...',
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             const Text(
//               'Borrowed Items',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             for (int i = 0; i < filteredEquipments.length; i++)
//               EquipmentTile(
//                 imageUrl: filteredEquipments[i]['image'],
//                 title: filteredEquipments[i]['title'],
//                 borrowedBy: filteredEquipments[i]['borrowedBy'],
//                 borrowedOn: filteredEquipments[i]['borrowedOn'],
//                 status: filteredEquipments[i]['status'],
//                 onConfirm: () => _confirmRequest(i),
//               ),

//             if (filteredEquipments.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.only(top: 20),
//                 child: Center(
//                   child: Text(
//                     'No matching items found.',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------- Equipment Tile ----------
// class EquipmentTile extends StatelessWidget {
//   final String imageUrl;
//   final String title;
//   final String borrowedBy;
//   final String borrowedOn;
//   final String status;
//   final VoidCallback onConfirm;

//   const EquipmentTile({
//     super.key,
//     required this.imageUrl,
//     required this.title,
//     required this.borrowedBy,
//     required this.borrowedOn,
//     required this.status,
//     required this.onConfirm,
//   });

//   @override
//   Widget build(BuildContext context) {
//     bool isConfirmed = status == 'Confirmed';

//     return Card(
//       color: const Color(0xFFF4EFFA),
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         leading: Image.network(imageUrl, width: 40, height: 40),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text('Borrowed by $borrowedBy\nOn $borrowedOn'),
//         trailing: ElevatedButton(
//           onPressed: isConfirmed ? null : onConfirm,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: isConfirmed ? Colors.grey : Colors.green,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           ),
//           child: Text(
//             isConfirmed ? 'Confirmed' : 'Confirm',
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }
