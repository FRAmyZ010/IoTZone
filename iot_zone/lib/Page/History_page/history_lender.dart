import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iot_zone/Page/AppConfig.dart';

class HistoryLenderPage extends StatefulWidget {
  const HistoryLenderPage({super.key});

  @override
  State<HistoryLenderPage> createState() => _HistoryLenderPageState();
}

class _HistoryLenderPageState extends State<HistoryLenderPage> {
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

  // ✅ ดึงข้อมูลจาก API จริง
  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final lenderId = prefs.getInt('user_id');

      if (lenderId == null) {
        throw Exception("ไม่พบข้อมูลผู้ใช้ Lender");
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/lender-history/$lenderId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          historyList = List<Map<String, dynamic>>.from(data);
          filteredList = historyList;
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load history data (status ${response.statusCode})');
      }
    } catch (e) {
      print('⚠️ Error fetching lender history: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดประวัติไม่สำเร็จ: $e')),
      );
    }
  }

  // ✅ ค้นหาชื่ออุปกรณ์
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

  // ✅ ฟิลเตอร์ตามวันที่ยืม
  void _filterByDate(DateTime? date) {
    if (date == null) return;

    final selected = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      filteredList = historyList.where((item) {
        final borrowDateStr = (item["borrowDate"] ?? "").toString();
        DateTime? borrowDate;
        try {
          borrowDate = DateTime.parse(borrowDateStr);
        } catch (e) {
          return false;
        }
        final formattedBorrow = DateFormat('yyyy-MM-dd').format(borrowDate);
        return formattedBorrow == selected;
      }).toList();
    });
  }

  //ปฏิทินเลือกวันที่
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
      setState(() => _selectedDate = pickedDate);
      _filterByDate(pickedDate);
    }
  }

 // โหลดรูปภาพ (asset / uploads / ชื่อไฟล์เปล่า)
Widget _buildImage(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported),
    );
  }

  // กรณี path ใน asset ของ Flutter
  if (imagePath.startsWith('asset/')) {
    return Image.asset(
      imagePath,
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.broken_image,
        color: Colors.red,
      ),
    );
  }

  // กรณีเป็นชื่อไฟล์เฉย ๆ (เช่น Multimeter.png)
  if (!imagePath.contains('/') && !imagePath.contains('\\')) {
    // ตรวจว่าแอปมีไฟล์ใน asset/img หรือไม่
    return Image.asset(
      'asset/img/$imagePath',
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // ถ้าไม่พบใน assets → ดึงจาก server
        return Image.network(
          '${AppConfig.baseUrl}/uploads/$imagePath',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image,
            color: Colors.red,
          ),
        );
      },
    );
  }

  // กรณี path อยู่ใน uploads (server)
  final file = imagePath.replaceAll('\\', '/');
  return Image.network(
    '${AppConfig.baseUrl}/uploads/$file',
    width: 64,
    height: 64,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => const Icon(
      Icons.broken_image,
      color: Colors.red,
    ),
  );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar + Calendar
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
                                    hintText: 'Search',
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

                  // รายการประวัติ
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(
                            child: Text(
                              "No lender history records found.",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
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

 // Card แต่ละรายการ 
Widget _buildHistoryCard(Map<String, dynamic> item) {
  const purple = Color(0xFFC368FF);

  String borrowedOn = '';
  String returnedOn = '';

  try {
    if (item['borrowDate'] != null) {
      borrowedOn =
          "Borrowed on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item['borrowDate']))}";
    }
    if (item['returnDate'] != null) {
      returnedOn =
          "Returned on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item['returnDate']))}";
    }
  } catch (_) {}

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
          child: _buildImage(item["image"]),
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

              if (borrowedOn.isNotEmpty) Text(borrowedOn),
              if (returnedOn.isNotEmpty) Text(returnedOn),

              if ((item["borrowedBy"] ?? '').toString().isNotEmpty)
                Text("Borrowed by ${item["borrowedBy"]}"),

              if ((item["reason"] ?? '').toString().isNotEmpty)
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
