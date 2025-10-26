import 'package:flutter/material.dart';
import '../asset_listmap/asset_model.dart'; // ✅ ตรวจ path ให้ถูก

class ShowAssetDialogStaff extends StatelessWidget {
  final AssetModel? asset; // ✅ ตัวแปรรับค่า
  const ShowAssetDialogStaff({super.key, this.asset});

  @override
  Widget build(BuildContext context) {
    final isEditing = asset != null; // ✅ ตรวจว่ามี asset ส่งมาหรือไม่
    final nameController = TextEditingController(text: asset?.name ?? '');
    final descController = TextEditingController(
      text: asset?.description ?? '',
    );
    String selectedType = asset?.type ?? 'Type';

    return Dialog(
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

              // 🔹 รูป
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

              // 🔹 Name
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

              // 🔹 Type dropdown
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
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (value) => selectedType = value!,
              ),
              const SizedBox(height: 12),

              // 🔹 Description
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

              // 🔹 ปุ่ม Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // ✅ สร้าง object ใหม่ / แก้ไข
                      final newAsset =
                          asset?.copyWith(
                            name: nameController.text,
                            type: selectedType,
                            description: descController.text,
                          ) ??
                          AssetModel(
                            id: DateTime.now().millisecondsSinceEpoch,
                            name: nameController.text,
                            type: selectedType,
                            description: descController.text,
                            image: 'asset/img/default.png',
                            status: 'Available',
                            statusColorValue: Colors.green.value,
                          );

                      Navigator.pop(context, newAsset);
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
    );
  }
}
