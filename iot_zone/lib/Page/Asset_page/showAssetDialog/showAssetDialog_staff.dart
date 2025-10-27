import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../asset_listmap/asset_model.dart';

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
    try {
      final uri = Uri.parse('http://10.0.2.2:3000/upload');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = jsonDecode(res.body);
        print('✅ Uploaded: ${data['filePath']}');
        return data['filePath']; // เช่น /uploads/1730039123.png
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Upload error: $e');
      return null;
    }
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
      return NetworkImage('http://10.0.2.2:3000$imagePath');
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
              Text(
                isEditing ? 'Edit Asset' : 'Add New Asset',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 รูปภาพ (Preview + Upload)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
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
                    [
                          'Type',
                          'Board',
                          'Module',
                          'Sensor',
                          'Tool',
                          'Component',
                          'Measurement', // ✅ เพิ่มบรรทัดนี้
                          'Logic', // ✅ เพิ่มด้วยถ้ามี type Logic
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (value) => setState(() => selectedType = value!),
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
                    onPressed: () async {
                      String imagePath =
                          widget.asset?.image ?? 'asset/img/default.png';

                      // ✅ ถ้ามีเลือกรูปใหม่ → upload ไป server
                      if (_imageFile != null) {
                        final uploadedPath = await _uploadImage(_imageFile!);
                        if (uploadedPath != null) imagePath = uploadedPath;
                      }

                      // ✅ เก็บ path เดิมถ้าไม่ได้เลือกใหม่
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
