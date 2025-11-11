import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'borrow_request_card.dart';

//รายการคำขอยืมหนังสือ
class BorrowRequestsPage extends StatefulWidget {
  const BorrowRequestsPage({super.key});

  @override
  State<BorrowRequestsPage> createState() => _BorrowRequestsPageState();
}

class _BorrowRequestsPageState extends State<BorrowRequestsPage> {
  List requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // 🔹 ดึงข้อมูลคำขอยืมหนังสือจาก backend
  Future<void> fetchRequests() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/borrow_requests'),
      );

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
        Uri.parse('http://localhost:3000/borrow_requests/$id/approve'),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = requests.indexWhere((r) => r['id'] == id);
          if (index != -1) requests[index]['status'] = 'approved';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Approved successfully')),
        );
      }
    } catch (e) {
      debugPrint("Approve error: $e");
    }
  }

  // 🔸 ระบบ “ปฏิเสธ”
  Future<void> rejectRequest(int id) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/borrow_requests/$id/reject'),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = requests.indexWhere((r) => r['id'] == id);
          if (index != -1) requests[index]['status'] = 'rejected';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Rejected successfully')),
        );
      }
    } catch (e) {
      debugPrint("Reject error: $e");
    }
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
                  onApprove: () => approveRequest(req['id']), // ✅ ระบบอนุมัติ
                  onReject: () => rejectRequest(req['id']), // ❌ ระบบปฏิเสธ
                );
              },
            ),
    );
  }
}
