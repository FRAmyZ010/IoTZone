import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'return_asset_card.dart'; // Component แสดงผลแต่ละรายการ
import 'package:iot_zone/Page/AppConfig.dart';

// ❗ Placeholder สำหรับ ID ผู้รับคืน (Receiver ID)
// ในแอปพลิเคชันจริง: ค่านี้ควรถูกดึงมาจากระบบ Authenticate ของผู้ใช้งานที่ Logged in
const int RECEIVER_ID =
    5; // **กรุณาเปลี่ยนเป็น ID ของผู้ใช้ที่กำลังใช้งานระบบจริง (User ที่กำลังรับคืน)**

// 📚 หน้าสำหรับจัดการครุภัณฑ์ที่ถูกนำมาคืน (รอการรับคืน)
class ReturnAssetsPage extends StatefulWidget {
  const ReturnAssetsPage({super.key});

  @override
  State<ReturnAssetsPage> createState() => _ReturnAssetsPageState();
}

class _ReturnAssetsPageState extends State<ReturnAssetsPage> {
  List requests = [];
  bool loading = true;
  String url = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // 🔹 ดึงข้อมูลครุภัณฑ์ที่รอรับคืนจาก backend
  Future<void> fetchRequests() async {
    try {
      final response = await http.get(Uri.parse('$url/show/return-asset'));

      if (response.statusCode == 200) {
        // ตรวจสอบข้อมูลก่อนนำมาใช้
        final List fetchedData = json.decode(response.body);

        // กรองเฉพาะสถานะ '2' ที่รอรับคืน
        final List pendingReturns = fetchedData.where((r) {
          final status = r['status'].toString();
          return status == '2';
        }).toList();

        setState(() {
          requests = pendingReturns;
          loading = false;
        });
      } else {
        throw Exception(
          'Failed to load return requests. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Error fetching return assets: $e");
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error loading return data.')),
        );
      }
    }
  }

  // 🔸 ระบบ “รับคืนครุภัณฑ์” (Accept Return)
  // ✅ เพิ่ม receiverId เข้ามาใน parameter
  Future<void> acceptReturnAsset(
    int historyId,
    int assetId,
    int receiverId,
  ) async {
    try {
      // ✅ สร้าง URL ใหม่โดยเพิ่ม receiverId เป็น Parameter ตัวสุดท้าย
      // URL: /accept/return_asset/:id/:asset_id/:receiver_id
      final endpoint =
          '$url/accept/return_asset/$historyId/$assetId/$receiverId';

      final response = await http.put(
        Uri.parse(endpoint),
        // ไม่ต้องส่ง body แล้ว เพราะข้อมูลถูกส่งผ่าน URL Params
      );

      if (response.statusCode == 200) {
        // 🔄 อัปเดตสถานะในหน้าจอทันที (ลบรายการที่คืนเรียบร้อยแล้วออกจาก List)
        setState(() {
          // ลบรายการที่เพิ่งรับคืนสำเร็จออกจากรายการที่รออยู่
          requests.removeWhere((r) => r['id'] == historyId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Asset received successfully. Status updated.'),
          ),
        );
      } else {
        // แสดงข้อความ error จาก Backend หากมี
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Failed to accept return.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("Accept Return error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to accept return: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Return Assets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC386FF),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text('No assets pending return today.'))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];

                // 💡 ใช้ ReturnAssetCard
                return ReturnAssetCard(
                  request: req,
                  // ✅ ส่งฟังก์ชัน acceptReturnAsset ที่รับ receiverId เข้าไปด้วย
                  onAcceptReturn: (historyId, assetId) => acceptReturnAsset(
                    historyId,
                    assetId,
                    RECEIVER_ID, // <-- ใช้ ID ผู้รับคืนจาก Global Constant
                  ),
                );
              },
            ),
    );
  }
}
