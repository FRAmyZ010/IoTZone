import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'borrow_request_card.dart';
import 'package:iot_zone/Page/AppConfig.dart';

// รายการคำขอยืมหนังสือ
class BorrowRequestsPage extends StatefulWidget {
  const BorrowRequestsPage({super.key});

  @override
  State<BorrowRequestsPage> createState() => _BorrowRequestsPageState();
}

class _BorrowRequestsPageState extends State<BorrowRequestsPage> {
  List requests = [];
  bool loading = true;
  String url = AppConfig.baseUrl;

  // ❗ สมมติ ID ผู้ดูแล (Approver ID) ชั่วคราว
  final int approverId = 3;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // 🔹 ดึงข้อมูลคำขอยืมหนังสือจาก backend
  Future<void> fetchRequests() async {
    try {
      final response = await http.get(Uri.parse('$url/borrow_requests'));

      if (response.statusCode == 200) {
        setState(() {
          requests = json.decode(response.body);
          loading = false;
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  // 🔸 ระบบ “อนุมัติ” (ไม่มีการเปลี่ยนแปลง)
  Future<void> approveRequest(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/borrow_requests/$id/approve'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'approverId': approverId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = requests.indexWhere((r) => r['id'] == id);
          if (index != -1) requests[index]['status'] = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Approved successfully')),
        );
      } else {
        throw Exception('Failed to approve request');
      }
    } catch (e) {
      debugPrint("Approve error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to approve request')),
      );
    }
  }

  // 🔸 ระบบ “ปฏิเสธ” (ยืนยันว่าส่ง reason ไป Backend)
  Future<void> rejectRequest(int id, {String reason = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$url/borrow_requests/$id/reject'),
        headers: {'Content-Type': 'application/json'},
        // ✅ บรรทัดนี้ยืนยันว่า reason ถูกส่งไปใน Body ของ Request
        body: json.encode({'approverId': approverId, 'reason': reason}),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = requests.indexWhere((r) => r['id'] == id);
          if (index != -1) {
            requests[index]['status'] = 3;
            requests[index]['reason'] = reason;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Rejected successfully')),
        );
      } else {
        throw Exception('Failed to reject request');
      }
    } catch (e) {
      debugPrint("Reject error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to reject request')),
      );
    }
  }

  // 📝 ฟังก์ชันแสดง Dialog เพื่อใส่เหตุผลในการปฏิเสธ (UI ตามดีไซน์ที่ต้องการ)
  Future<void> rejectRequestWithReason(int id, String borrowerName) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // 1. หัวข้อ Dialog (แสดงชื่อผู้ยืม)
          title: Text(
            'Borrower: $borrowerName',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0.0),

          // 2. เนื้อหา Dialog (Label Reject reason + TextField)
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reject reason',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    hintText: "Enter rejection reason",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  minLines: 4,
                  maxLines: 4,
                ),
              ),
            ],
          ),

          // 3. ปรับปุ่ม Action (จัดเรียงและเปลี่ยนสีตามภาพ)
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ปุ่ม Send (Reject/ยืนยัน) - สีเขียว
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // เรียก rejectRequest พร้อมส่งเหตุผลที่ผู้ใช้กรอก
                    rejectRequest(id, reason: reasonController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // 🎨 สีเขียว
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    minimumSize: const Size(120, 50),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                // ปุ่ม Cancel - สีแดง
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // 🎨 สีแดง
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    minimumSize: const Size(120, 50),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Borrow Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 130, 77, 255),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text('No borrow requests found'))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final borrowerName = req['borrowerName'] ?? 'Unknown Requester';
                return BorrowRequestCard(
                  request: req,
                  onApprove: approveRequest,
                  // ✅ ส่ง id และ borrowerName ไปยัง Dialog
                  onReject: (id) => rejectRequestWithReason(id, borrowerName),
                );
              },
            ),
    );
  }
}
