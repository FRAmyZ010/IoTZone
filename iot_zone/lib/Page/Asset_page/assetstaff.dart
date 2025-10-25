import 'package:flutter/material.dart';
import 'asset_listmap/asset_model.dart';

class AssetStaff extends StatefulWidget {
  const AssetStaff({super.key});

  @override
  State<AssetStaff> createState() => _AssetStaffState();
}

class _AssetStaffState extends State<AssetStaff> {
  String selected = 'All';

  // ✅ ตัวอย่างข้อมูล AssetModel
  List<AssetModel> assets = [
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
          'A measuring instrument combining voltage, current, and resistance functions.',
      statusColorValue: Colors.red.value,
    ),
    AssetModel(
      id: 3,
      type: 'Component',
      name: 'Resistor',
      status: 'Borrowed',
      image: 'asset/img/Resistor.png',
      description: 'A passive component that limits current flow.',
      statusColorValue: Colors.grey.value,
    ),
    AssetModel(
      id: 4,
      type: 'Component',
      name: 'Capacitor',
      status: 'Pending',
      image: 'asset/img/Capacitor.png',
      description: 'Stores and releases electrical energy.',
      statusColorValue: Colors.orange.value,
    ),
  ];

  // 🔹 เปิด Dialog สำหรับ Add/Edit
  void _openAssetDialog({AssetModel? asset}) {
    final isEditing = asset != null;
    final nameController = TextEditingController(
      text: isEditing ? asset.name : '',
    );
    final descController = TextEditingController(
      text: isEditing ? asset.description : '',
    );
    String selectedType = isEditing ? asset.type : 'Type';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Edit Asset' : 'Add New Asset',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 60, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Upload',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Asset's name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items:
                      ['Type', 'Board', 'Module', 'Sensor', 'Tool', 'Component']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) => selectedType = value!,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing ? '✅ Changes saved' : '✅ Asset added',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(isEditing ? 'SAVE' : 'CONFIRM'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('CANCEL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 ฟังก์ชันเปลี่ยนสถานะ Disabled / Available
  void _toggleStatus(AssetModel asset) {
    setState(() {
      final updatedList = assets.map((a) {
        if (a.id == asset.id) {
          if (a.status == 'Disabled') {
            return a.copyWith(
              status: 'Available',
              statusColorValue: Colors.green.value,
            );
          } else {
            return a.copyWith(
              status: 'Disabled',
              statusColorValue: Colors.red.value,
            );
          }
        }
        return a;
      }).toList();

      assets = updatedList;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          asset.status == 'Disabled'
              ? '✅ ${asset.name} enabled'
              : '❌ ${asset.name} disabled',
        ),
        backgroundColor: asset.status == 'Disabled'
            ? Colors.green
            : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ----------------------------- UI หลัก -----------------------------
  @override
  Widget build(BuildContext context) {
    final filteredAssets = selected == 'All'
        ? assets
        : assets.where((a) => a.type == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asset (Staff)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 320,
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

            // 🔍 Search + Add button
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 12),
                        Icon(Icons.search, color: Colors.black54, size: 22),
                        SizedBox(width: 8),
                        Expanded(
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
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _openAssetDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '+ Add item',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Asset List",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // ✅ GridView
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredAssets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7, // 🔹 ลดค่าลง = กล่องสูงขึ้น
                ),
                itemBuilder: (context, index) {
                  final asset = filteredAssets[index];
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
                          "Status: ${asset.status}",
                          style: TextStyle(
                            color: asset.statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 🔹 ปุ่ม EDIT
                        ElevatedButton.icon(
                          onPressed: () => _openAssetDialog(asset: asset),
                          icon: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'EDIT',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // 🔹 ปุ่ม DISABLE / ENABLE
                        ElevatedButton.icon(
                          onPressed: () => _toggleStatus(asset),
                          icon: Icon(
                            asset.status == 'Disabled'
                                ? Icons.refresh
                                : Icons.block,
                            size: 14,
                            color: Colors.white,
                          ),
                          label: Text(
                            asset.status == 'Disabled' ? 'ENABLE' : 'DISABLE',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: asset.status == 'Disabled'
                                ? Colors.green
                                : Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
