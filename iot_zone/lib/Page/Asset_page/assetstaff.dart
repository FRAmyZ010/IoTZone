import 'package:flutter/material.dart'; // UI หลักของ Flutter
import 'package:http/http.dart' as http; // ใช้สำหรับเรียก API (HTTP)
import 'dart:convert'; // ใช้แปลง JSON ↔ Object

import 'asset_listmap/asset_model.dart'; // โมเดล AssetModel
import 'showAssetDialog/showAssetDialog_staff.dart'; // หน้าต่างเพิ่ม/แก้ไขสินทรัพย์
import 'package:iot_zone/Page/AppConfig.dart'; // ค่า config เช่น IP Server

// 🔹 หน้าจอหลักสำหรับจัดการสินทรัพย์ (ของ Staff)
class AssetStaff extends StatefulWidget {
  const AssetStaff({super.key});

  @override
  State<AssetStaff> createState() => _AssetStaffState();
}

class _AssetStaffState extends State<AssetStaff> {
  // 🔸 รายการประเภทของสินทรัพย์
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

  String selectedType = 'All'; // ประเภทสินค้าที่เลือกกรอง (ค่าเริ่มต้น = All)
  final String ip = AppConfig.serverIP; // IP ของ server ที่เก็บ API

  List<AssetModel> assets = []; // เก็บรายการสินทรัพย์ทั้งหมดจากฐานข้อมูล
  bool isLoading = true; // สถานะโหลดข้อมูล
  String? errorMessage; // เก็บข้อความ error (ถ้ามี)

  // 🔹 ฟังก์ชันเลือกแหล่งรูปภาพ (asset หรือ network)
  ImageProvider _buildImageProvider(String imagePath) {
    if (imagePath.isEmpty)
      return const AssetImage(
        'asset/img/no_image.png',
      ); // ถ้าไม่มีรูป → รูป default
    if (imagePath.startsWith('asset/'))
      return AssetImage(imagePath); // ถ้าเป็น asset ในแอป
    if (!imagePath.startsWith('/uploads/') && !imagePath.contains('http')) {
      return AssetImage('asset/img/$imagePath'); // โหลดจากโฟลเดอร์ asset/img/
    }
    if (imagePath.startsWith('/uploads/')) {
      return NetworkImage(
        'http://$ip:3000$imagePath',
      ); // โหลดจาก server (เช่น /uploads/)
    }
    return const AssetImage('asset/img/no_image.png'); // กรณีไม่เข้าเงื่อนไขใด
  }

  // 🔹 ฟังก์ชันดึงข้อมูลสินทรัพย์จาก API
  Future<void> fetchAssets() async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip:3000/assets'),
      ); // GET /assets
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(
          response.body,
        ); // แปลง JSON → List
        setState(() {
          assets = data
              .map((e) => AssetModel.fromMap(e))
              .toList(); // แปลงแต่ละ item → AssetModel
          isLoading = false; // โหลดเสร็จ
        });
      } else {
        // ❌ ถ้าสถานะ HTTP ไม่ใช่ 200
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch data (${response.statusCode})';
        });
      }
    } catch (e) {
      // ❌ ถ้ามี error เช่น ไม่มีการเชื่อมต่อ
      setState(() {
        isLoading = false;
        errorMessage = 'Connection error: $e';
      });
    }
  }

  // 🔹 ฟังก์ชันอัปเดตสถานะ (เช่น Available → Disabled)
  Future<void> updateStatusInAPI(int id, String newStatus) async {
    // แปลงสถานะจากชื่อ → รหัส (ตามหลังบ้าน)
    int statusCode = switch (newStatus) {
      'Available' => 1,
      'Disabled' => 2,
      'Pending' => 3,
      'Borrowed' => 4,
      _ => 1,
    };
    // เรียก API เพื่ออัปเดตสถานะ
    await http.patch(
      Uri.parse(
        'http://$ip:3000/assets/$id/status',
      ), // PATCH /assets/:id/status
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': statusCode}), // ส่งค่า status code ใหม่
    );
  }

  @override
  void initState() {
    super.initState();
    fetchAssets(); // โหลดข้อมูลสินทรัพย์ทันทีเมื่อเปิดหน้า
  }

  // 🔹 เพิ่มสินทรัพย์ใหม่
  Future<void> addAsset(AssetModel newAsset) async {
    await http.post(
      Uri.parse('http://$ip:3000/assets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newAsset.toMap()), // ส่งข้อมูลสินทรัพย์ในรูป JSON
    );
    fetchAssets(); // โหลดข้อมูลใหม่หลังเพิ่มเสร็จ
  }

  Future<bool> checkAssetInUse(int assetId) async {
    final response = await http.get(
      Uri.parse('http://$ip:3000/api/check-asset-usage/$assetId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['inUse'] == true;
    }
    return false;
  }

  // 🔹 อัปเดตข้อมูลสินทรัพย์เดิม
  Future<void> updateAsset(AssetModel asset) async {
    await http.put(
      Uri.parse('http://$ip:3000/assets/${asset.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(asset.toMap()),
    );
    fetchAssets(); // โหลดข้อมูลใหม่
  }

  // 🔹 ลบสินทรัพย์
  Future<void> deleteAsset(int id) async {
    await http.delete(Uri.parse('http://$ip:3000/assets/$id'));
    fetchAssets(); // โหลดข้อมูลใหม่
  }

  // 🔹 เปิดหน้าต่าง (Dialog) สำหรับเพิ่ม/แก้ไขข้อมูลสินทรัพย์
  void _openAssetDialog({AssetModel? asset}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ShowAssetDialogStaff(asset: asset),
    );
    if (result is AssetModel) {
      if (asset == null) {
        addAsset(result); // ถ้าเป็นของใหม่ → เพิ่ม
      } else {
        updateAsset(result); // ถ้ามีอยู่แล้ว → แก้ไข
      }
    }
  }

  // 🔹 เปลี่ยนสถานะของสินทรัพย์ (Enable / Disable)
  void _toggleStatus(AssetModel asset) async {
    // 🛑 เช็คก่อน disable
    if (asset.status != 'Disabled') {
      bool inUse = await checkAssetInUse(asset.id);
      if (inUse) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ Cannot disable this asset because it is currently borrowed or pending approval.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    final newStatus = asset.status == 'Disabled' ? 'Available' : 'Disabled';
    await updateStatusInAPI(asset.id, newStatus);

    setState(() {
      assets = assets.map((a) {
        if (a.id == asset.id) {
          return a.copyWith(
            status: newStatus,
            statusColorValue: newStatus == 'Available'
                ? Colors.green.value
                : Colors.redAccent.value,
          );
        }
        return a;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 กรองรายการสินทรัพย์ตามประเภทที่เลือก
    final filteredAssets = selectedType == 'All'
        ? assets
        : assets.where((a) => a.type == selectedType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asset (Staff)', // หัวข้อหน้า
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent, // พื้นหลัง AppBar
      ),
      backgroundColor: const Color(0xFFF9F6FF), // สีพื้นหลังของหน้าหลัก
      body: RefreshIndicator(
        // ดึงลงเพื่อรีเฟรชข้อมูล
        onRefresh: fetchAssets,
        child:
            isLoading // ถ้ายังโหลดอยู่
            ? const Center(
                child: CircularProgressIndicator(
                  // วงกลมโหลด
                  color: Colors.deepPurpleAccent,
                ),
              )
            : errorMessage !=
                  null // ถ้ามี error
            ? Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 แถวกรองประเภทสินทรัพย์ (All / Type Dropdown)
                    Row(
                      children: [
                        OutlinedButton(
                          // ปุ่ม All
                          onPressed: () => setState(() => selectedType = 'All'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: selectedType == 'All'
                                  ? const Color(0xFF8C6BFF)
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            'All',
                            style: TextStyle(
                              color: selectedType == 'All'
                                  ? const Color(0xFF8C6BFF)
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        const SizedBox(width: 12),
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
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value:
                                    (selectedType != 'All' &&
                                        selectedType != 'Type')
                                    ? selectedType
                                    : null,
                                hint: const Text(
                                  'Select Type',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                items: types.map((t) {
                                  return DropdownMenuItem<String>(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        color: t == 'Type'
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(
                                    () => selectedType = (v == 'Type')
                                        ? 'All'
                                        : v,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔍 ช่องค้นหา + ปุ่มเพิ่ม item
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Search your item',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _openAssetDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
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
                      "Asset List", // หัวข้อรายการ
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 แสดงรายการสินทรัพย์แบบตาราง
                    Expanded(
                      child: GridView.builder(
                        itemCount: filteredAssets.length, // จำนวนการ์ดทั้งหมด
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 คอลัมน์
                              mainAxisSpacing: 16, // ระยะห่างแนวตั้ง
                              crossAxisSpacing: 16, // ระยะห่างแนวนอน
                              childAspectRatio: 0.59, // อัตราส่วนการ์ด
                            ),
                        itemBuilder: (context, index) {
                          final asset =
                              filteredAssets[index]; // ดึงข้อมูลสินค้าตาม index
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // รูปภาพสินค้า
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image(
                                    image: _buildImageProvider(asset.image),
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // ชื่อสินค้า
                                Text(
                                  asset.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // แสดงสถานะพร้อมสี
                                const SizedBox(height: 10),
                                // ปุ่มแก้ไข
                                ElevatedButton(
                                  onPressed: () =>
                                      _openAssetDialog(asset: asset),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'EDIT',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // ปุ่มเปิด/ปิดการใช้งาน
                                ElevatedButton(
                                  onPressed:
                                      (asset.status == 'Pending' ||
                                          asset.status == 'Borrowed')
                                      ? null // ปิดปุ่ม
                                      : () => _toggleStatus(asset),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (asset.status == 'Pending' ||
                                            asset.status == 'Borrowed')
                                        ? Colors
                                              .grey
                                              .shade600 // เทาเข้ม
                                        : asset.status == 'Disabled'
                                        ? Colors.green
                                        : Colors.redAccent,
                                    foregroundColor:
                                        (asset.status == 'Pending' ||
                                            asset.status == 'Borrowed')
                                        ? Colors
                                              .white // สีเหลืองเมื่อ In Use
                                        : Colors.white,
                                    disabledBackgroundColor: Colors
                                        .grey
                                        .shade600, // ให้สีเทาเข้มคงอยู่แม้ปิดปุ่ม
                                    disabledForegroundColor: Colors
                                        .white, // ตัวอักษรเหลืองตอนปิดปุ่ม
                                  ),
                                  child: Text(
                                    (asset.status == 'Pending' ||
                                            asset.status == 'Borrowed')
                                        ? 'IN USE'
                                        : asset.status == 'Disabled'
                                        ? 'ENABLE'
                                        : 'DISABLE',
                                    style: TextStyle(
                                      color:
                                          (asset.status == 'Pending' ||
                                              asset.status == 'Borrowed')
                                          ? Colors.white
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
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
