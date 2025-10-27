import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'asset_listmap/asset_model.dart';
import 'showAssetDialog/showAssetDialog_staff.dart';

class AssetStaff extends StatefulWidget {
  const AssetStaff({super.key});

  @override
  State<AssetStaff> createState() => _AssetStaffState();
}

class _AssetStaffState extends State<AssetStaff> {
  String selected = 'All';
  List<AssetModel> assets = [];
  bool isLoading = true;
  String? errorMessage;

  // ✅ ฟังก์ชันช่วยเลือก image provider ให้รองรับทุกกรณี
  ImageProvider _buildImageProvider(String imagePath) {
    if (imagePath.isEmpty) {
      return const AssetImage('asset/img/no_image.png');
    }

    // กรณี path อยู่ใน asset/
    if (imagePath.startsWith('asset/')) {
      return AssetImage(imagePath);
    }

    // กรณีชื่อไฟล์สั้น เช่น "Resistor.png"
    if (!imagePath.startsWith('/uploads/') && !imagePath.contains('http')) {
      return AssetImage('asset/img/$imagePath');
    }

    // กรณีไฟล์จาก server
    if (imagePath.startsWith('/uploads/')) {
      return NetworkImage('http://10.0.2.2:3000$imagePath');
    }

    // fallback
    return const AssetImage('asset/img/no_image.png');
  }

  // 🔹 ดึงข้อมูลทั้งหมดจาก API
  Future<void> fetchAssets() async {
    try {
      print('📡 Fetching assets from API...');
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/assets'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          assets = data.map((e) => AssetModel.fromMap(e)).toList();
          isLoading = false;
          errorMessage = null;
        });
        print('✅ Loaded ${assets.length} assets');
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch data (code ${response.statusCode})';
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Connection error: $e';
      });
    }
  }

  Future<void> updateStatusInAPI(int id, String newStatus) async {
    int statusCode = 1;
    if (newStatus == 'Available')
      statusCode = 1;
    else if (newStatus == 'Disabled')
      statusCode = 2;
    else if (newStatus == 'Pending')
      statusCode = 3;
    else if (newStatus == 'Borrowed')
      statusCode = 4;

    final response = await http.patch(
      Uri.parse('http://10.0.2.2:3000/assets/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': statusCode}),
    );

    if (response.statusCode == 200) {
      print('✅ Status updated on server!');
    } else {
      print('❌ Failed to update status: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAssets(); // โหลดข้อมูลตอนเปิดหน้า
  }

  // 🔹 เพิ่มข้อมูล
  Future<void> addAsset(AssetModel newAsset) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/assets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newAsset.toMap()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      fetchAssets();
    }
  }

  // 🔹 แก้ไขข้อมูล
  Future<void> updateAsset(AssetModel asset) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/assets/${asset.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(asset.toMap()),
    );
    if (response.statusCode == 200) fetchAssets();
  }

  // 🔹 ลบข้อมูล
  Future<void> deleteAsset(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/assets/$id'),
    );
    if (response.statusCode == 200) fetchAssets();
  }

  // 🔹 เปิด Dialog เพิ่ม/แก้ไข
  void _openAssetDialog({AssetModel? asset}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ShowAssetDialogStaff(asset: asset),
    );

    if (result is AssetModel) {
      if (asset == null) {
        addAsset(result);
      } else {
        updateAsset(result);
      }
    }
  }

  // 🔹 เปลี่ยนสถานะ
  void _toggleStatus(AssetModel asset) async {
    final newStatus = asset.status == 'Disabled' ? 'Available' : 'Disabled';

    // ✅ อัปเดตในฐานข้อมูลจริง
    await updateStatusInAPI(asset.id, newStatus);

    // ✅ อัปเดตในจอ
    setState(() {
      assets = assets.map((a) {
        if (a.id == asset.id) {
          return a.copyWith(
            status: newStatus,
            statusColorValue: newStatus == 'Available'
                ? Colors.green.value
                : Colors.red.value,
          );
        }
        return a;
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'Available'
              ? '✅ ${asset.name} enabled'
              : '❌ ${asset.name} disabled',
        ),
        backgroundColor: newStatus == 'Available'
            ? Colors.green
            : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ----------------------------- UI หลัก -----------------------------
  @override
  Widget build(BuildContext context) {
    final filteredAssets = selected == 'All'
        ? assets
        : assets.where((a) => a.type == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asset (Staff)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F6FF),

      body: RefreshIndicator(
        onRefresh: fetchAssets,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurpleAccent,
                  ),
                )
              : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: fetchAssets,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Filter buttons
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 320,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
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

                    // 🔍 Search + Add button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.2,
                              ),
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
                                Icon(
                                  Icons.search,
                                  color: Colors.black54,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search your item',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _openAssetDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            '+ Add item',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Asset List",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ GridView แสดงข้อมูลจริง
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredAssets.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.59,
                            ),
                        itemBuilder: (context, index) {
                          final asset = filteredAssets[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
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
                                  child: Image(
                                    image: _buildImageProvider(asset.image),
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  asset.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Status: ${asset.status}",
                                  style: TextStyle(
                                    color: asset.statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _openAssetDialog(asset: asset),
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'EDIT',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton.icon(
                                  onPressed: () => _toggleStatus(asset),
                                  icon: Icon(
                                    asset.status == 'Disabled'
                                        ? Icons.refresh
                                        : Icons.block,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    asset.status == 'Disabled'
                                        ? 'ENABLE'
                                        : 'DISABLE',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: asset.status == 'Disabled'
                                        ? Colors.green
                                        : Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
