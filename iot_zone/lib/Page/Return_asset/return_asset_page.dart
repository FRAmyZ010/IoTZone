import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'return_asset_card.dart';
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:iot_zone/Page/api_helper.dart';

// 📚 หน้าสำหรับจัดการครุภัณฑ์ที่รอการรับคืน
class ReturnAssetsPage extends StatefulWidget {
  const ReturnAssetsPage({super.key});

  @override
  State<ReturnAssetsPage> createState() => _ReturnAssetsPageState();
}

class _ReturnAssetsPageState extends State<ReturnAssetsPage> {
  List requests = [];
  bool loading = true;
  String url = AppConfig.baseUrl;

  int? receiverId; // ✅ ดึงจาก session จริง
  String? receiverName;

  @override
  void initState() {
    super.initState();
    _loadReceiverFromSession(); // ✅ โหลด user_id จาก session
    fetchRequests();
  }

  // ✅ โหลดข้อมูลผู้รับคืนจาก SharedPreferences
  Future<void> _loadReceiverFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    final name = prefs.getString('name');
    setState(() {
      receiverId = id;
      receiverName = name;
    });
    debugPrint('🟢 Receiver ID Loaded: $receiverId ($receiverName)');
  }

  // 🔹 ดึงข้อมูลครุภัณฑ์ที่รอรับคืนจาก backend
  Future<void> fetchRequests() async {
    setState(() => loading = true);

    try {
      // 🔥 เรียก API พร้อม auto refresh token
      final response = await ApiHelper.callApi(
        "/show/return-asset",
        method: "GET",
      );

      print("📡 Return Asset → ${response.statusCode}");
      print("📡 Body: ${response.body}");

      // ---------------------------------------
      // 🔴 Token หมดอายุจริงๆ → Logout
      // ---------------------------------------
      if (response.statusCode == 401) {
        final msg = jsonDecode(response.body)["message"];

        if (msg == "invalid_token" || msg == "expired_refresh_token") {
          if (context.mounted) ApiHelper.forceLogout(context);
        }

        throw Exception("Unauthorized");
      }

      // ---------------------------------------
      // 🟢 โหลดข้อมูลสำเร็จ
      // ---------------------------------------
      if (response.statusCode == 200) {
        final List fetchedData = json.decode(response.body);

        // กรองเฉพาะที่ status == 2 (รอรับคืน)
        final List pendingReturns = fetchedData.where((r) {
          final status = r['status'].toString();
          return status == '2';
        }).toList();

        setState(() {
          requests = pendingReturns;
          loading = false;
        });

        print('✅ Loaded ${pendingReturns.length} pending return requests');
        return;
      }

      // ---------------------------------------
      // 🔴 Error อื่น ๆ
      // ---------------------------------------
      throw Exception("HTTP ${response.statusCode}");
    } catch (e) {
      print("❌ Error fetching return assets: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("โหลดข้อมูลการคืนทรัพย์สินล้มเหลว\n$e")),
        );
      }

      setState(() => loading = false);
    }
  }

  // 🔸 ระบบ “รับคืนครุภัณฑ์”
  Future<void> acceptReturnAsset(int historyId, int assetId) async {
    if (receiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No session found. Please log in again.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // ✅ ส่ง receiverId จริงไปใน URL
      final endpoint =
          '$url/accept/return_asset/$historyId/$assetId/$receiverId';

      final response = await http.put(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        // 🔄 อัปเดตสถานะในหน้าจอทันที
        setState(() {
          requests.removeWhere((r) => r['id'] == historyId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Asset received successfully.')),
        );
      } else {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => loading = true);
              fetchRequests();
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text('No assets pending return today.'))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return ReturnAssetCard(
                  request: req,
                  // ✅ ส่งฟังก์ชันรับคืนจริง พร้อม receiverId จาก session
                  onAcceptReturn: (historyId, assetId) =>
                      acceptReturnAsset(historyId, assetId),
                );
              },
            ),
    );
  }
}
