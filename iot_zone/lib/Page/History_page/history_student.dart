import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryStudentPage extends StatefulWidget {
  const HistoryStudentPage({super.key});

  @override
  State<HistoryStudentPage> createState() => _HistoryStudentPageState();
}

class _HistoryStudentPageState extends State<HistoryStudentPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> historyList = [];
  List<Map<String, dynamic>> filteredList = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  //Mock Data
  void _fetchHistory() async {
    List<Map<String, dynamic>> apiData = [
      {
        "name": "Multimeter",
        "status": "Returned",
        "borrowDate": "2025-10-24",
        "returnDate": "2025-10-25",
        "approvedBy": "Prof. John Doe",
        "image": "asset/img/Multimeter.png",
      },
      {
        "name": "Capacitor",
        "status": "Rejected",
        "borrowDate": "2025-10-22",
        "reason": "Can borrow only one asset a day",
        "approvedBy": "Prof. John Doe",
        "image": "asset/img/Capacitor.png",
      },
      {
        "name": "Transistor",
        "status": "Returned",
        "borrowDate": "2025-10-21",
        "returnDate": "2025-10-23",
        "approvedBy": "Prof. John Doe",
        "image": "asset/img/Transistor.png",
      },
      {
        "name": "Resistor",
        "status": "Rejected",
        "borrowDate": "2025-10-19",
        "reason": "Can borrow only one asset a day",
        "approvedBy": "Prof. John Doe",
        "image": "asset/img/Resistor.png",
      },
    ];

    setState(() {
      historyList = apiData;
      filteredList = apiData;
    });
  }

  //ฟังก์ชันค้นหา
  void _searchItem(String query) {
    setState(() {
      filteredList = historyList.where((item) {
        final name = item["name"].toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q);
      }).toList();
      _filterByDate(_selectedDate);
    });
  }

  //ฟังก์ชันกรองตามวันที่ยืม
  void _filterByDate(DateTime? date) {
    if (date == null) return;
    final selected = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      filteredList = historyList
          .where((item) => item["borrowDate"] == selected)
          .toList();
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
      setState(() {
        _selectedDate = pickedDate;
      });
      _filterByDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFC368FF);
    const blue = Color(0xFF4D5DFF);
    const bg = Color(0xFFF9F9FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: blue,
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const Text(
                  "History",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Search + Calendar
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
                              hintText: 'Search your item',
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

            //รายการ
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
                      itemBuilder: (context, index) {
                        var item = filteredList[index];
                        return _buildHistoryCard(item);
                      },
                    ),
            ),

            //Bottom Nav
            Center(
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4D5DFF), Color(0xFFC368FF)],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: หน้า Home
                        },
                        icon: const Icon(Icons.home_outlined, size: 26),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                            _searchCtrl.clear();
                            filteredList = historyList;
                          });
                        },
                        icon: const Icon(Icons.history, size: 30),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: หน้า Request / Booking
                        },
                        icon: const Icon(Icons.list_alt_outlined, size: 30),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Card Builder
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
            child: Image.asset(
              item["image"],
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
                      item["name"],
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
                            text: 'Status: ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: item["status"],
                            style: TextStyle(
                              color: item["status"] == "Rejected"
                                  ? Colors.red
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Borrowed on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item["borrowDate"]))}",
                ),
                if (item.containsKey("returnDate"))
                  Text(
                    "Returned on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item["returnDate"]))}",
                  ),
                if (item["status"] == "Rejected" && item["reason"] != null)
                  Text(
                    "Reason: ${item["reason"]}",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                if (item.containsKey("approvedBy"))
                  Text(
                    item["status"] == "Rejected"
                        ? "Rejected by ${item["approvedBy"]}"
                        : "Approved by ${item["approvedBy"]}",
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
