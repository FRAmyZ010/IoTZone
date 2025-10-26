import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _imageFile;

  final TextEditingController _usernameController = TextEditingController(
    text: 'Doi,za007',
  );
  final TextEditingController _fullnameController = TextEditingController(
    text: 'Parinthon Somphakdee',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'doiza007@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '0xxxxxxxxx',
  );

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // ใช้ .pickImage โดยระบุแหล่งที่มา เช่น gallery หรือ camera
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      // 💡 อธิบาย: หากเลือกรูปภาพได้สำเร็จ (pickedFile ไม่ใช่ null)
      // เราจะใช้ setState() เพื่อแจ้งให้ Flutter ทำการ 'สร้าง' (re-build) Widget ใหม่
      // พร้อมกับค่าสถานะ _imageFile ที่เปลี่ยนไปเป็นรูปภาพใหม่
      setState(() {
        _imageFile = File(pickedFile.path); // แปลง XFile เป็น File
      });
    }
  }

  Widget _buildProfileImagePicker() {
    // 💡 อธิบาย: GestureDetector/InkWell ใช้ตรวจจับการแตะ
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap:
                _pickImage, // เมื่อแตะที่รูปโปรไฟล์ จะเรียกฟังก์ชันเลือกรูปภาพ
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                // การตัดสินใจว่าจะแสดงอะไร: รูปที่เลือก vs. รูปเริ่มต้น
                image: DecorationImage(
                  image: _imageFile != null
                      ? FileImage(_imageFile!)
                            as ImageProvider // รูปที่เลือกจากไฟล์
                      : const AssetImage(
                          'asset/icon/user.png',
                        ), // รูปเริ่มต้น (ต้องมีไฟล์นี้ใน assets)
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[200],
              ),
              child: _imageFile == null
                  ? const Icon(Icons.person, size: 70, color: Colors.grey)
                  : null, // ถ้ามีรูปแล้ว ไม่ต้องแสดงไอคอน placeholder
            ),
          ),
          // ปุ่ม UPLOAD เล็กๆ มุมล่างขวา
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'UPLOAD',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // เพิ่มโค้ดนี้ในคลาส _ProfileEditScreenState

  // 💡 อธิบาย: ใช้ TextFormField เพื่อให้สามารถมีตัวควบคุม (controller)
  // และการจัดรูปแบบ (Decoration) ได้ง่าย
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    IconData icon = Icons.info_outline, // ค่าเริ่มต้น
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: InputBorder.none, // ลบเส้นขีดใต้
                isDense: true,
                contentPadding: const EdgeInsets.only(top: 10, bottom: 5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับปุ่มยืนยัน
  void _confirmProfile() {
    // 💡 อธิบาย: เมื่อผู้ใช้กดปุ่ม เราจะสามารถดึงค่าที่ผู้ใช้กรอกจาก Controllers ได้
    print('บันทึกข้อมูล: ${_fullNameController.text}');
    // TODO: ใส่ Logic การบันทึกข้อมูล (Save to API/Database)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    // Navigator.pop(context); // อาจจะย้อนกลับหน้าเดิม
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _confirmProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'CONFIRM',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            _buildProfileImagePicker(), // ส่วนสำหรับรูปโปรไฟล์
            const SizedBox(height: 30),
            _buildInputField(
              label: 'Full Name',
              controller: _fullnameController,
            ), // ช่องกรอกข้อมูล
            // ... เพิ่มช่องกรอกอื่นๆ
            const SizedBox(height: 50),
            _buildConfirmButton(), // ปุ่มยืนยัน
          ],
        ),
      ),
    );
  }
}
