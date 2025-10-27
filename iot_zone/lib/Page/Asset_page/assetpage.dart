import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'showAssetDialog/showAssetDialog_student.dart';
import 'asset_listmap/asset_model.dart';
import '../Widgets/bottom_nav_bar.dart';

class Assetpage extends StatefulWidget {
  const Assetpage({super.key});

  @override
  State<Assetpage> createState() => _AssetpageState();
}

class _AssetpageState extends State<Assetpage> {
  String selected = 'All';
  late Future<List<AssetModel>> futureAssets;

  @override
  void initState() {
    super.initState();
    futureAssets = fetchAssets();
  }

  // ✅ ดึงข้อมูลจาก API
  Future<List<AssetModel>> fetchAssets() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/assets'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => AssetModel.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load assets');
    }
  }

  // ✅ โหลดภาพจาก asset หรือ server
  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('/uploads/') || imagePath.contains('http')) {
      // ✅ โหลดจาก server
      return Image.network(
        'http://10.0.2.2:3000$imagePath',
        height: 90,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 70, color: Colors.grey),
      );
    } else {
      // ✅ โหลดจาก assets
      return Image.asset(
        imagePath,
        height: 90,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
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
            // 🔹 Filter buttons
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['All', 'Board', 'Module'].map((label) {
                    final isSelected = selected == label;
                    return GestureDetector(
                      onTap: () => setState(() => selected = label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF8C6BFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
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
                  final filteredAssets = selected == 'All'
                      ? allAssets
                      : allAssets.where((a) => a.type == selected).toList();

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
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
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
