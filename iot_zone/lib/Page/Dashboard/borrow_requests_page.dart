import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'borrow_request_card.dart';
import 'package:iot_zone/Page/AppConfig.dart';

//รายการคำขอยืมหนังสือ
class BorrowRequestsPage extends StatefulWidget {
  const BorrowRequestsPage({super.key});

  @override
  State<BorrowRequestsPage> createState() => _BorrowRequestsPageState();
}

class _BorrowRequestsPageState extends State<BorrowRequestsPage> {
  List requests = [];
  bool loading = true;
  String url = AppConfig.baseUrl;

  // ❗ สมมติ ID ผู้ดูแล (Approver ID) ชั่วคราว คุณควรดึงมาจาก Session/Login State จริง
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

  // 🔸 ระบบ “อนุมัติ”
  Future<void> approveRequest(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/borrow_requests/$id/approve'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'approverId': approverId}), // ✅ ส่ง approverId ไป
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = requests.indexWhere((r) => r['id'] == id);
          if (index != -1)
            requests[index]['status'] = 2; // ✅ อัปเดตเป็น 2 (Approved)
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

  // 🔸 ระบบ “ปฏิเสธ” (ส่ง reason ไปด้วย)
  Future<void> rejectRequest(int id, {String reason = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$url/borrow_requests/$id/reject'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'approverId': approverId, // ✅ ส่ง approverId ไป
          'reason': reason, // ✅ ส่งเหตุผลไป
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = requests.indexWhere((r) => r['id'] == id);
          if (index != -1) {
            requests[index]['status'] = 3; // ✅ อัปเดตเป็น 3 (Rejected)
            requests[index]['reason'] = reason; // ✅ บันทึกเหตุผลใน State
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

  // 📝 ฟังก์ชันแสดง Dialog เพื่อใส่เหตุผลในการปฏิเสธ
  Future<void> rejectRequestWithReason(int id) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: "Enter rejection reason (Optional)",
            ),
            minLines: 1,
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                rejectRequest(id, reason: reasonController.text.trim());
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow Requests'),
        backgroundColor: const Color(0xFF7C4DFF),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text('No borrow requests found'))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return BorrowRequestCard(
                  request: req,
                  // ⚙️ เรียกฟังก์ชันที่รับ ID
                  onApprove: approveRequest,
                  // 📝 เรียกฟังก์ชัน Dialog สำหรับใส่เหตุผล
                  onReject: rejectRequestWithReason,
                );
              },
            ),
    );
  }
}
