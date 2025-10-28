import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'showAssetDialog/showAssetDialog_student.dart';
import 'asset_listmap/asset_model.dart';
import '../Widgets/buildBotttom_nav_bar/bottom_nav_bar.dart';

class Assetpage extends StatefulWidget {
  const Assetpage({super.key});

  @override
  State<Assetpage> createState() => _AssetpageState();
}

class _AssetpageState extends State<Assetpage> {
  // --- Filter state ---
  final List<String> types = const [
    'Type', // ใช้เป็น hint ใน dropdown
    'Board',
    'Module',
    'Sensor',
    'Tool',
    'Component',
    'Measurement',
    'Logic',
  ];
  String selectedType = 'All';
  String ip = '192.168.145.1';

  late Future<List<AssetModel>> futureAssets;

  @override
  void initState() {
    super.initState();
    futureAssets = fetchAssets();
  }

  // ✅ ดึงข้อมูลจาก API
  Future<List<AssetModel>> fetchAssets() async {
    final response = await http.get(Uri.parse('http://$ip:3000/assets'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => AssetModel.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load assets');
    }
  }

  // ✅ โหลดภาพแบบสมส่วน (ไม่โดนครอป)
  Widget _buildImage(String imagePath) {
    final baseUrl = 'http://$ip:3000';
    final isNetwork =
        imagePath.startsWith('/uploads/') || imagePath.contains('http');

    return Container(
      height: 120,
      width: double.infinity,
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.contain,
        child: isNetwork
            ? Image.network(
                imagePath.contains('http') ? imagePath : '$baseUrl$imagePath',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey,
                ),
              )
            : Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asset',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Filter: All + Dropdown
            Row(
              children: [
                // ปุ่ม All
                OutlinedButton.icon(
                  onPressed: () => setState(() => selectedType = 'All'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: selectedType == 'All'
                          ? const Color(0xFF8C6BFF)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    backgroundColor: selectedType == 'All'
                        ? const Color(0xFF8C6BFF).withOpacity(0.08)
                        : null,
                  ),

                  label: Text(
                    'All',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selectedType == 'All'
                          ? const Color(0xFF8C6BFF)
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Dropdown
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: (selectedType != 'All' && selectedType != 'Type')
                            ? selectedType
                            : null, // ถ้า All หรือ Type → แสดง hint
                        hint: const Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        items: types.map((t) {
                          return DropdownMenuItem<String>(
                            value: t,
                            child: Text(
                              t,
                              style: TextStyle(
                                color: t == 'Type'
                                    ? Colors
                                          .grey // สีอ่อนเฉพาะ Type
                                    : Colors.black,
                                fontWeight: t == 'Type'
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v == null) return;

                          // ✅ ถ้าเลือก "Type" ให้เท่ากับ All
                          if (v == 'Type') {
                            setState(() => selectedType = 'All');
                          } else {
                            setState(() => selectedType = v);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔍 Search box
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.black54, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search your item',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ โหลดข้อมูลจาก API
            Expanded(
              child: FutureBuilder<List<AssetModel>>(
                future: futureAssets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No assets found.'));
                  }

                  final allAssets = snapshot.data!;
                  final filteredAssets = (selectedType == 'All')
                      ? allAssets
                      : allAssets.where((a) => a.type == selectedType).toList();

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredAssets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemBuilder: (context, index) {
                      final asset = filteredAssets[index];
                      final isAvailable = asset.status == 'Available';

                      return GestureDetector(
                        onTap: isAvailable
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      BorrowAssetDialog(asset: asset.toMap()),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${asset.name} is currently not available.',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                        child: Opacity(
                          opacity: isAvailable ? 1.0 : 0.6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildImage(asset.image),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  asset.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  asset.status,
                                  style: TextStyle(
                                    color: asset.statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 🔹 BottomNavBar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/menu');
          }
        },
      ),
    );
  }
}
