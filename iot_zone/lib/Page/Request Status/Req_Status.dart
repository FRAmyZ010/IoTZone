import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestStatusPage extends StatefulWidget {
  const RequestStatusPage({super.key});

  @override
  State<RequestStatusPage> createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> requestList = [];
  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  // ✅ Mock Data
  void _fetchRequests() async {
    List<Map<String, dynamic>> apiData = [
      {
        "name": "Multimeter",
        "status": "Pending",
        "borrowDate": "2025-10-24",
        "approvedBy": "",
        "note": "Waiting for an approval",
        "image": "asset/img/Multimeter.png",
      },
      {
        "name": "Capacitor",
        "status": "Rejected",
        "borrowDate": "2025-10-22",
        "approvedBy": "Prof. John Doe",
        "reason": "Can borrow only one asset a day",
        "image": "asset/img/Capacitor.png",
      },
      {
        "name": "Resistor",
        "status": "Approved",
        "borrowDate": "2025-10-22",
        "returnDate": "2025-10-23",
        "approvedBy": "Prof. John Doe",
        "image": "asset/img/Resistor.png",
      },
    ];

    setState(() {
      requestList = apiData;
      filteredList = apiData;
    });
  }

  // ฟังก์ชันค้นหา
  void _searchItem(String query) {
    setState(() {
      filteredList = requestList.where((item) {
        final name = item["name"].toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q);
      }).toList();
    });
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
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text(
                    "Request Status",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
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
            // Search
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
                  const Icon(Icons.search, color: Colors.black54, size: 22),
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

            //รายการ
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

  // Card Builder
  Widget _buildRequestCard(Map<String, dynamic> item) {
    const purple = Color(0xFFC368FF);

    // กำหนดสีสถานะ
    Color getStatusColor(String status) {
      switch (status) {
        case "Approved":
          return Colors.green;
        case "Rejected":
          return Colors.red;
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

          //เนื้อหาการ์ด
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
                            text: 'Status : ',
                            style: TextStyle(
                              color: Colors.black,
                            ), // ✅ คำว่า Status เป็นสีดำ
                          ),
                          TextSpan(
                            text: item["status"],
                            style: TextStyle(
                              color: getStatusColor(
                                item["status"],
                              ), // ✅ สีของสถานะยังเปลี่ยนได้
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

                if (item["status"] == "Approved" &&
                    item.containsKey("returnDate"))
                  Text(
                    "Returned on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item["returnDate"]))}",
                  ),

                if (item["status"] == "Pending" && item["note"] != null)
                  Text(
                    item["note"],
                    style: const TextStyle(color: Colors.grey),
                  ),

                if (item["status"] == "Rejected" && item["reason"] != null)
                  Text(
                    "Reason : ${item["reason"]}",
                    style: const TextStyle(color: Colors.redAccent),
                  ),

                if (item.containsKey("approvedBy") &&
                    item["approvedBy"].toString().isNotEmpty)
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
