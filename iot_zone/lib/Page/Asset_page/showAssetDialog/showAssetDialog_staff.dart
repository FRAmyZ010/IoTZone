import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../asset_listmap/asset_model.dart';
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:iot_zone/Page/api_helper.dart';

class ShowAssetDialogStaff extends StatefulWidget {
  final AssetModel? asset;
  const ShowAssetDialogStaff({super.key, this.asset});

  @override
  State<ShowAssetDialogStaff> createState() => _ShowAssetDialogStaffState();
}

class _ShowAssetDialogStaffState extends State<ShowAssetDialogStaff> {
  final picker = ImagePicker();
  File? _imageFile;
  late TextEditingController nameController;
  late TextEditingController descController;
  late String selectedType;
  final String ip = AppConfig.serverIP;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.asset?.name ?? '');
    descController = TextEditingController(
      text: widget.asset?.description ?? '',
    );
    selectedType = widget.asset?.type ?? 'Type';
  }

  // ✅ ฟังก์ชันเลือกรูปจาก Gallery
  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // ✅ ฟังก์ชันอัปโหลดรูปไป Server
  Future<String?> _uploadImage(File imageFile) async {
    final response = await ApiHelper.callMultipartApi(
      "/upload",
      fields: {}, // ไม่มี field เพิ่ม
      filePath: imageFile.path,
      fileField: "image", // ชื่อ field ต้องตรงกับ backend
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Uploaded: ${data['filePath']}");
      return data["filePath"]; // เช่น /uploads/x.png
    }

    print("❌ Upload failed: ${response.statusCode}");
    return null;
  }

  // ✅ ตัวช่วยสร้าง ImageProvider ปลอดภัย
  ImageProvider _buildImageProvider(String imagePath) {
    if (imagePath.isEmpty) {
      return const AssetImage('asset/img/no_image.png');
    }

    // ✅ ถ้ามี path เต็มอยู่แล้ว เช่น asset/img/Resistor.png
    if (imagePath.startsWith('asset/')) {
      return AssetImage(imagePath);
    }

    // ✅ ถ้าเก็บแค่ชื่อไฟล์ เช่น SN74LS32N.png
    if (imagePath.endsWith('.png') && !imagePath.contains('asset/')) {
      return AssetImage('asset/img/$imagePath');
    }

    // ✅ ถ้าเก็บแค่ชื่อ (ไม่มี .png)
    if (!imagePath.contains('.') && !imagePath.contains('/')) {
      return AssetImage('asset/img/$imagePath.png');
    }

    // ✅ ถ้ามาจาก server upload
    if (imagePath.startsWith('/uploads/')) {
      return NetworkImage('http://$ip:3000$imagePath');
    }

    // fallback
    return const AssetImage('asset/img/no_image.png');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.asset != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Title
              Text(
                isEditing ? 'Edit Asset' : 'Add New Asset',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 รูปภาพ
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.deepPurpleAccent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : (widget.asset?.image != null &&
                              widget.asset!.image.isNotEmpty)
                        ? Image(
                            image: _buildImageProvider(widget.asset!.image),
                            fit: BoxFit.cover,
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 60,
                                color: Colors.deepPurpleAccent,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Upload',
                                style: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // ✅ ปุ่มเพิ่มรูปภาพ (ใหม่)
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage, // เรียกฟังก์ชันเดิมได้เลย
                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                label: const Text(
                  'Add Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  elevation: 3,
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Name
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: "Asset's name",
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items:
                    [
                          'Type',
                          'Board',
                          'Module',
                          'Sensor',
                          'Tool',
                          'Component',
                          'Measurement',
                          'Logic',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (value) => setState(() => selectedType = value!),
              ),
              const SizedBox(height: 12),

              // 🔹 Description ช่องกรอกรายละเอียด
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.black87),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ✅ ปุ่มยืนยัน (สีม่วง ข้อความขาว)
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please filled Asset's name"),
                          ),
                        );
                        return;
                      }
                      if (descController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please filled Asset's description"),
                          ),
                        );
                        return;
                      }
                      String imagePath =
                          widget.asset?.image ?? 'asset/img/default.png';
                      if (_imageFile != null) {
                        final uploadedPath = await _uploadImage(_imageFile!);
                        if (uploadedPath != null) imagePath = uploadedPath;
                      }

                      final newAsset =
                          widget.asset?.copyWith(
                            name: nameController.text,
                            type: selectedType,
                            description: descController.text,
                            image: imagePath,
                          ) ??
                          AssetModel(
                            id: DateTime.now().millisecondsSinceEpoch,
                            name: nameController.text,
                            type: selectedType,
                            description: descController.text,
                            image: imagePath,
                            status: 'Available',
                            statusColorValue: Colors.green.value,
                          );

                      Navigator.pop(context, newAsset);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      isEditing ? 'SAVE' : 'CONFIRM',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white, // ✅ ข้อความขาว
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                  ),

                  // ✅ ปุ่มยกเลิก (สีเทา ข้อความขาว)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white, // ✅ ข้อความขาว
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
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
