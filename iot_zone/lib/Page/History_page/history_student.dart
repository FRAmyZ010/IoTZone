import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'as http; 
import 'package:iot_zone/Page/AppConfig.dart';
import 'dart:convert';

class HistoryStudentPage extends StatefulWidget {
  const HistoryStudentPage({super.key});

  @override
  State<HistoryStudentPage> createState() => _HistoryStudentPageState();
}

class _HistoryStudentPageState extends State<HistoryStudentPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> historyList = [];
  List<Map<String, dynamic>> filteredList = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

 // ✅ ฟังก์ชันดึงข้อมูลจาก API จริง
  Future<void> _fetchHistory() async {
  setState(() {
    _isLoading = true;
  });
  try {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/history/1'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        historyList = List<Map<String, dynamic>>.from(data);
        filteredList = historyList;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load history data');
    }
  } catch (e) {
    print('⚠️ Error fetching history: $e');
    setState(() {
      _isLoading = false;
    });
  }
}



  // ✅ ฟังก์ชันค้นหา
 void _searchItem(String query) {
  final lowerQuery = query.toLowerCase();
  setState(() {
    filteredList = historyList.where((item) {
      final name = (item["name"] ?? "").toString().toLowerCase();
      return name.contains(lowerQuery);
    }).toList();

    if (_selectedDate != null) {
      _filterByDate(_selectedDate);
    }
  });
}


  // ✅ ฟังก์ชันกรองวันที่ (เลือกวัน)
  void _filterByDate(DateTime? date) {
  if (date == null) return;

  final selected = DateFormat('yyyy-MM-dd').format(date);
  setState(() {
    filteredList = historyList.where((item) {
      final borrowDateStr = (item["borrowDate"] ?? "").toString();

      // แปลงวันที่จาก string (เช่น "2025-10-24T00:00:00.000Z") → yyyy-MM-dd
      DateTime? borrowDate;
      try {
        borrowDate = DateTime.parse(borrowDateStr);
      } catch (e) {
        return false; // ถ้า parse ไม่ได้ก็ข้ามไป
      }

      final formattedBorrow = DateFormat('yyyy-MM-dd').format(borrowDate);
      return formattedBorrow == selected;
    }).toList();
  });
}


  // ✅ ปฏิทินเลือกวันที่
  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4D5DFF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _filterByDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFC368FF);
    const bg = Color(0xFFF9F9FF);

    return Scaffold(
      backgroundColor: bg,
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
          "History",
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


      // ✅ แสดงผลใน Body
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // โหลดอยู่
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔍 Search bar
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
                              const Icon(Icons.search,
                                  color: Colors.black54, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Search your item',
                                    border: InputBorder.none,
                                    hintStyle:
                                        TextStyle(color: Colors.black54),
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
                          child: const Icon(Icons.calendar_month,
                              color: Colors.black, size: 26),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🧾 รายการประวัติ
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(
                            child: Text("No history records found.",
                                style: TextStyle(color: Colors.black54)))
                        : ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              var item = filteredList[index];
                              return _buildHistoryCard(item);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // ✅ ส่วนของ Card แสดงข้อมูลแต่ละรายการ
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
        // ✅ ส่วนรูปภาพอุปกรณ์
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item["image"] != null && item["image"].isNotEmpty
              ? Image.asset(
                  // ถ้า path เริ่มต้นด้วย asset/ ให้ใช้ตรง ๆ
                  item["image"].startsWith('asset/')
                      ? item["image"]
                      // ถ้าเก็บแค่ชื่อไฟล์ เช่น "Multimeter.png" ให้เพิ่ม path เอง
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
                )
              : Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
        ),
        const SizedBox(width: 12),

          // ✅ รายละเอียด
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item["name"] ?? "Unknown Item",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        children: [
                          const TextSpan(
                            text: 'Status: ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: item["status"] ?? "Unknown",
                            style: TextStyle(
                              color: item["status"] == "Rejected"
                                  ? Colors.red
                                  : (item["status"] == "Returned"
                                      ? const Color.fromARGB(255, 98, 100, 98)
                                      : Colors.black54),
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