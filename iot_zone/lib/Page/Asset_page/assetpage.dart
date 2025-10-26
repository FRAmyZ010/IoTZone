import 'package:flutter/material.dart';
import 'showAssetDialog/showAssetDialog_student.dart';
import 'asset_listmap/asset_model.dart';
import '../Widgets/bottom_nav_bar.dart';

class Assetpage extends StatefulWidget {
  const Assetpage({super.key});

  @override
  State<Assetpage> createState() => _AssetpageState();
}

class _AssetpageState extends State<Assetpage> {
  String selected = 'All';

  // ✅ ข้อมูลตัวอย่าง AssetModel
  final List<AssetModel> assets = [
    AssetModel(
      id: 1,
      type: 'Board',
      name: 'SN74LS32N',
      status: 'Available',
      image: 'asset/img/SN74LS32N.png',
      description:
          'A quad 2-input OR gate IC commonly used in digital logic circuits.',
      statusColorValue: Colors.green.value,
    ),
    AssetModel(
      id: 2,
      type: 'Tool',
      name: 'Multimeter',
      status: 'Disabled',
      image: 'asset/img/Multimeter.png',
      description:
          'An electronic measuring instrument that combines several measurement functions like voltage, current, and resistance.',
      statusColorValue: Colors.red.value,
    ),
    AssetModel(
      id: 3,
      type: 'Component',
      name: 'Resistor',
      status: 'Borrowed',
      image: 'asset/img/Resistor.png',
      description:
          'A passive electrical component that limits or regulates the flow of electrical current in a circuit.',
      statusColorValue: Colors.grey.value,
    ),
    AssetModel(
      id: 4,
      type: 'Component',
      name: 'Capacitor',
      status: 'Pending',
      image: 'asset/img/Capacitor.png',
      description:
          'A component that stores and releases electrical energy, often used for filtering or timing applications.',
      statusColorValue: Colors.orange.value,
    ),
    AssetModel(
      id: 5,
      type: 'Module',
      name: 'Transistor',
      status: 'Available',
      image: 'asset/img/Transistor.png',
      description:
          'A semiconductor device used to amplify or switch electronic signals in circuits.',
      statusColorValue: Colors.green.value,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ ฟิลเตอร์ข้อมูลตามปุ่มที่เลือก
    final filteredAssets = selected == 'All'
        ? assets
        : assets.where((a) => a.type == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asset',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Filter buttons
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 300, // ✅ ลดขนาด Container
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['All', 'Board', 'Module'].map((label) {
                    final isSelected = selected == label;
                    return GestureDetector(
                      onTap: () => setState(() => selected = label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
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
                            fontSize: 14,
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
            ),

            const SizedBox(height: 20),

            // 🔍 Search box
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
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
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search your item',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 GridView (แสดงตาม Filter)
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredAssets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final asset = filteredAssets[index];
                  final isAvailable = asset.status == 'Available';

                  return GestureDetector(
                    onTap: isAvailable
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  BorrowAssetDialog(asset: asset.toMap()),
                            );
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${asset.name} is currently not available.',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                    child: Opacity(
                      opacity: isAvailable ? 1.0 : 0.6,
                      child: Container(
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
                              child: Image.asset(
                                asset.image,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              asset.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              asset.status,
                              style: TextStyle(
                                color: asset.statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // หน้าปัจจุบัน (Home)
        onTap: (index) {
          setState(() {
            // index ที่เลือก (0 = Home, 1 = History, 2 = Menu)
            print("Tapped index: $index");
          });

          // ✅ ตัวอย่างการลิงก์ไปหน้าอื่น
          if (index == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/menu');
          }
        },
      ),
    );
  }
}
