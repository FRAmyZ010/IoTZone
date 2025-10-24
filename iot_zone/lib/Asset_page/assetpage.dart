import 'package:flutter/material.dart';

class Assetpage extends StatefulWidget {
  const Assetpage({super.key});

  @override
  State<Assetpage> createState() => _AssetpageState();
}

class _AssetpageState extends State<Assetpage> {
  String selected = 'All';

  // ✅ สมมุติข้อมูล Asset (เชื่อม DB ได้ในอนาคต)
  final List<Map<String, dynamic>> assets = [
    {
      'name': 'SN74LS32N',
      'status': 'Available',
      'statusColor': Colors.green,
      'image': 'asset/img/SN74LS32N.png',
    },
    {
      'name': 'Multimeter',
      'status': 'Disabled',
      'statusColor': Colors.red,
      'image':
          'https://cdn.thewirecutter.com/wp-content/media/2022/07/multimeters-2048px-02656.jpg',
    },
    {
      'name': 'Resistor',
      'status': 'Borrowed',
      'statusColor': Colors.brown,
      'image':
          'https://cdn.sparkfun.com//assets/parts/1/1/3/8/8/11622-Resistor_1K-01.jpg',
    },
    {
      'name': 'Capacitor',
      'status': 'Pending',
      'statusColor': Colors.orange,
      'image':
          'https://www.electronicscomp.com/image/cache/catalog/capacitors/electrolytic/100uf-50v-electrolytic-capacitor-1000x1000.jpg',
    },
    {
      'name': 'Transistor',
      'status': 'Available',
      'statusColor': Colors.green,
      'image':
          'https://cdn.sparkfun.com//assets/parts/1/1/1/4/1/10213-Transistor_2N2222A-01.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asset Page',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F6FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Filter buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['All', 'Board', 'Module'].map((label) {
                  final isSelected = selected == label;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selected = label);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8C6BFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 🔍 Search box
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.black54, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search your item',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      onChanged: (value) {
                        // ✅ logic ค้นหาจะใส่ตรงนี้ทีหลัง
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ แสดง Asset 2 คอลัมน์แบบ GridView
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: assets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // ✅ 2 ช่องต่อแถว
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8, // ✅ อัตราส่วนกว้าง/สูงของแต่ละการ์ด
                ),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: asset['image'].toString().startsWith('http')
                              ? Image.network(
                                  asset['image'],
                                  height: 90,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  asset['image'],
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          asset['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          asset['status'],
                          style: TextStyle(
                            color: asset['statusColor'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
