import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:iot_zone/Page/Asset_page/showAssetDialog/showAssetDialog_student.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestStatusPage extends StatefulWidget {
  const RequestStatusPage({super.key});
  static VoidCallback? refreshRequestPage;
  @override
  State<RequestStatusPage> createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> requestList = [];
  List<Map<String, dynamic>> filteredList = [];

  @override
  @override
  void initState() {
    super.initState();
    _fetchRequests();

    // ✅ ผูกฟังก์ชันรีเฟรชกับ static ตัวนี้
    RequestStatusPage.refreshRequestPage = () {
      if (mounted) _fetchRequests();
    };
  }

  // ✅ ดึงข้อมูลจาก API จริง
  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);

    try {
      // ✅ ดึง user_id จาก SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      // ✅ เรียก API โดยใช้ userId จาก session
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/request-status/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          requestList = List<Map<String, dynamic>>.from(data);
          filteredList = requestList;
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load request status (status ${response.statusCode})',
        );
      }
    } catch (e) {
      print('⚠️ Error fetching request status: $e');
      setState(() => _isLoading = false);
    }
  }

  // ✅ ฟังก์ชันค้นหา
  void _searchItem(String query) {
    setState(() {
      filteredList = requestList.where((item) {
        final name = item["name"].toString().toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q);
      }).toList();
    });
  }

  void _openBorrowDialog(Map<String, dynamic> asset) async {
    await showDialog(
      context: context,
      builder: (_) => BorrowAssetDialog(
        asset: asset,
        onBorrowSuccess: () async {
          await _fetchRequests(); // ✅ รีเฟรชทันที
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Borrow successful!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFC368FF);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: AppBar(
            backgroundColor: purple,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Request Status",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.search,
                          color: Colors.black54,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Search your request',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black54),
                            ),
                            onChanged: _searchItem,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🧾 แสดงรายการ
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(
                            child: Text(
                              "No requests found",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              var item = filteredList[index];
                              return _buildRequestCard(item);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // ✅ Card Builder
  Widget _buildRequestCard(Map<String, dynamic> item) {
    const purple = Color(0xFFC368FF);

    Color getStatusColor(String status) {
      switch (status) {
        case "Borrowed":
          return Colors.green;
        case "Pending":
          return Colors.orange;
        default:
          return Colors.black54;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: purple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item["image"].toString().startsWith('asset/img/')
                  ? item["image"]
                  : 'asset/img/${item["image"]}',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.red),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item["name"] ?? "Unknown",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(
                            text: "Status: ",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: item["status"] ?? "Unknown",
                            style: TextStyle(
                              color: getStatusColor(item["status"]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                if (item["borrowDate"] != null)
                  Text(
                    "Borrowed on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item["borrowDate"]))}",
                  ),
                if (item["returnDate"] != null)
                  Text(
                    "Returned on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item["returnDate"]))}",
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
