import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryStaffPage extends StatefulWidget {
  const HistoryStaffPage({super.key});

  @override
  State<HistoryStaffPage> createState() => _HistoryStaffPageState();
}

class _HistoryStaffPageState extends State<HistoryStaffPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> historyList = [];
  List<Map<String, dynamic>> filteredList = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // ✅ ดึงข้อมูลจาก API จริง
  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getInt('user_id') ?? 1;

      final url = Uri.parse('${AppConfig.baseUrl}/api/staff-history/$staffId');
      print('📡 Fetching staff history: $url');

      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        setState(() {
          historyList = List<Map<String, dynamic>>.from(data);
          filteredList = historyList;
          _isLoading = false;
        });
        print('✅ Loaded ${historyList.length} staff history records');
      } else {
        throw Exception('HTTP ${resp.statusCode}');
      }
    } catch (e) {
      print('⚠️ Fetch error: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดข้อมูล Staff History ไม่สำเร็จ\n$e')),
      );
    }
  }

  // ✅ ค้นหา
  void _searchItem(String query) {
    final q = query.toLowerCase();
    setState(() {
      filteredList = historyList.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(q);
      }).toList();
      if (_selectedDate != null) _filterByDate(_selectedDate);
    });
  }

  // ✅ กรองตามวันที่
  void _filterByDate(DateTime? date) {
    if (date == null) return;
    final selected = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      filteredList = historyList.where((item) {
        final borrowDate = (item['borrowDate'] ?? '').toString();
        return borrowDate.startsWith(selected);
      }).toList();
    });
  }

  // ✅ ปฏิทินเลือกวัน
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFC368FF),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _filterByDate(picked);
    }
  }

  // ✅ ฟังก์ชันเลือก image ตาม path ที่เจอ
  ImageProvider _resolveImageProvider(dynamic imgPath) {
    if (imgPath == null || imgPath.toString().isEmpty) {
      return const AssetImage('asset/img/placeholder.png');
    }

    final String path = imgPath.toString().trim();

    // ถ้าเป็น path เต็ม เช่น asset/img/Capacitor.png
    if (path.startsWith('asset/')) {
      return AssetImage(path);
    }

    // ถ้าเป็นแค่ชื่อไฟล์ เช่น SN74LS32N.png
    if (path.endsWith('.png') || path.endsWith('.jpg')) {
      return AssetImage('asset/img/$path');
    }

    // ถ้าเป็น URL หรือ uploads จาก server
    if (path.startsWith('http') || path.startsWith('uploads/')) {
      return NetworkImage('${AppConfig.baseUrl}/$path');
    }

    // fallback
    return const AssetImage('asset/img/placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFC368FF);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        title: const Text(
          'History', // หัวข้อหน้า
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent, // พื้นหลัง AppBar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search + Calendar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                                    hintText: 'Search item',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.black54),
                                  ),
                                  onChanged: _searchItem,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Colors.black,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // History list
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(
                            child: Text(
                              "No records found",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) =>
                                _buildHistoryCard(filteredList[index]),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // ✅ การ์ดแสดงข้อมูลแต่ละรายการ
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    const purple = Color(0xFFC368FF);
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
            child: Image(
              image: _resolveImageProvider(item["image"]),
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
                Text(
                  item["name"] ?? "Unknown Item",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                if (item["borrowedBy"] != null)
                  Text("Borrowed by ${item["borrowedBy"]}"),
                if (item["approvedBy"] != null)
                  Text("Approved by ${item["approvedBy"]}"),
                if (item["receivedBy"] != null)
                  Text("Received by ${item["receivedBy"]}"),
                if (item["status"] == "Rejected" && item["reason"] != null)
                  Text(
                    "Reason: ${item["reason"]}",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
