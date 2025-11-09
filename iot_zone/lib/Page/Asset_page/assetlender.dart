import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'asset_listmap/asset_model.dart';
import 'showAssetDialog/showAssetDialog_lender.dart';
import 'package:iot_zone/Page/AppConfig.dart';

class Assetlender extends StatefulWidget {
  const Assetlender({super.key});

  @override
  State<Assetlender> createState() => _AssetlenderState();
}

class _AssetlenderState extends State<Assetlender> {
  String searchQuery = '';
  final List<String> types = const [
    'Type',
    'Board',
    'Module',
    'Sensor',
    'Tool',
    'Component',
    'Measurement',
    'Logic',
  ];

  String selectedType = 'All';
  final String ip = AppConfig.serverIP;
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

  // ✅ โหลดภาพจาก Asset หรือ Server
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
          'Asset (Lender)',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F6FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Filter: All + Dropdown
            Row(
              children: [
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
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: (selectedType != 'All' && selectedType != 'Type')
                            ? selectedType
                            : null,
                        hint: const Text('Type'),
                        items: types.map((t) {
                          return DropdownMenuItem<String>(
                            value: t,
                            child: Text(t),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(
                            () => selectedType = (v == 'Type') ? 'All' : v,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔍 Search Box
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
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.black54, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search your item',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ โหลดข้อมูลจาก API
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF6B45FF), // สีม่วงของ progress ตอนรีเฟรช
                onRefresh: () async {
                  setState(() {
                    // โหลดข้อมูลใหม่
                    futureAssets = fetchAssets();
                  });
                  await Future.delayed(
                    const Duration(seconds: 1),
                  ); // รอให้ smooth ขึ้น
                },
                child: FutureBuilder<List<AssetModel>>(
                  future: futureAssets,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurpleAccent,
                        ),
                      );
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
                    final filteredAssets = allAssets.where((a) {
                      final matchesType =
                          selectedType == 'All' ||
                          a.type.toLowerCase() == selectedType.toLowerCase();
                      final matchesSearch =
                          searchQuery.isEmpty ||
                          a.name.toLowerCase().contains(searchQuery);
                      return matchesType && matchesSearch;
                    }).toList();

                    return GridView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // ✅ ต้องใช้แบบนี้เพื่อให้ลากลงได้
                      itemCount: filteredAssets.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.6,
                          ),
                      itemBuilder: (context, index) {
                        final asset = filteredAssets[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  ShowAssetDialogLender(asset: asset.toMap()),
                            );
                          },
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
                                const SizedBox(height: 6),
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B45FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(width: 4),
                                      Text(
                                        "See item",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
