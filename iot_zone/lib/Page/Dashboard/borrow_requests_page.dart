import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'borrow_request_card.dart';
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:iot_zone/Page/api_helper.dart';

// 🔹 หน้ารายการคำขอยืมหนังสือ
class BorrowRequestsPage extends StatefulWidget {
  const BorrowRequestsPage({super.key});

  @override
  State<BorrowRequestsPage> createState() => _BorrowRequestsPageState();
}

class _BorrowRequestsPageState extends State<BorrowRequestsPage> {
  List requests = [];
  bool loading = true;
  String url = AppConfig.baseUrl;

  int? approverId; // ✅ ดึงจาก session
  String? approverName;

  @override
  void initState() {
    super.initState();
    _loadApproverFromSession();
    fetchRequests();
  }

  // ✅ โหลดข้อมูล approver จาก SharedPreferences
  Future<void> _loadApproverFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    final name = prefs.getString('name');
    setState(() {
      approverId = id;
      approverName = name;
    });
    debugPrint('🟢 Approver ID Loaded: $approverId ($approverName)');
  }

  // 🔹 ดึงข้อมูลคำขอยืมหนังสือจาก backend
  Future<void> fetchRequests() async {
    try {
      final response = await ApiHelper.callApi(
        "/borrow_requests",
        method: "GET",
      );

      if (response.statusCode == 200) {
        setState(() {
          requests = json.decode(response.body);
          loading = false;
        });
      } else if (response.statusCode == 401) {
        await ApiHelper.forceLogout(context);
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  // 🔸 ระบบ “อนุมัติ” พร้อมตรวจ session
  Future<void> approveRequest(int id) async {
    if (approverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No session found. Please log in again.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final response = await ApiHelper.callApi(
        "/borrow_requests/$id/approve",
        method: "POST",
        body: {"approverId": approverId},
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = requests.indexWhere((r) => r['id'] == id);
          if (index != -1) requests[index]['status'] = 2;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Approved successfully')),
        );
      } else if (response.statusCode == 401) {
        await ApiHelper.forceLogout(context);
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Approve error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to approve request')),
      );
    }
  }

  // 🔸 ระบบ “ปฏิเสธ” พร้อมตรวจ session
  Future<void> rejectRequest(int id, {String reason = ''}) async {
    if (approverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No session found. Please log in again.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final response = await ApiHelper.callApi(
        "/borrow_requests/$id/reject",
        method: "POST",
        body: {"approverId": approverId, "reason": reason},
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
      } else if (response.statusCode == 401) {
        await ApiHelper.forceLogout(context);
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Reject error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to reject request')),
      );
    }
  }

  // 📝 Dialog สำหรับใส่เหตุผลปฏิเสธ
  Future<void> rejectRequestWithReason(int id, String borrowerName) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Borrower: $borrowerName',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
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
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final reason = reasonController.text.trim();

                    if (reason.isEmpty) {
                      // โชว์ SnackBar หรือ Alert แจ้งเตือน
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter the rejection reason."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // ❌ ไม่ปิด dialog และไม่ส่งต่อ
                    }

                    Navigator.of(context).pop();
                    rejectRequest(id, reason: reason);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
        backgroundColor: const Color.fromARGB(255, 130, 77, 255),
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
                  onReject: (id) => rejectRequestWithReason(id, borrowerName),
                );
              },
            ),
    );
  }
}
