import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iot_zone/Page/Login/login_page.dart'; // ✅ import หน้า login
import 'package:path/path.dart' as path;

enum ProfileMenuAction { profile, changepassword, logout }

class UserProfileMenu extends StatelessWidget {
  final Map<String, dynamic>? userData; // ✅ เพิ่มรับข้อมูลผู้ใช้จากภายนอก
  final ImagePicker _picker = ImagePicker();

  UserProfileMenu({super.key, this.userData});

  // ----------------------------------------------------------------------
  // 🧩 Helper: textfield โปรไฟล์
  // ----------------------------------------------------------------------
  Widget _buildProfileEditableItem({
    required Widget icon,
    required String labelText,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20, height: 20, child: icon),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 🔹 PROFILE DIALOG
  // ----------------------------------------------------------------------
  Future<void> _showProfileAlert(BuildContext context) async {
    // ✅ ดึงข้อมูลจาก userData (ถ้าไม่มีให้ fallback เป็น mock)
    String username = userData?['username'] ?? 'Guest';
    String fullName = userData?['name'] ?? 'Unknown User';
    String phone = userData?['phone'] ?? 'N/A';
    String email = userData?['email'] ?? 'N/A';

    File? _tempImageFile;
    String? _tempFileName;

    final TextEditingController userController = TextEditingController(
      text: username,
    );
    final TextEditingController nameController = TextEditingController(
      text: fullName,
    );
    final TextEditingController phoneController = TextEditingController(
      text: phone,
    );
    final TextEditingController emailController = TextEditingController(
      text: email,
    );

    final _formKey = GlobalKey<FormState>();

    Widget iconWidget(String asset) =>
        Image.asset(asset, width: 18, height: 18);

    Future<void> _pickImage() async {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _tempImageFile = File(picked.path);
        _tempFileName = path.basename(picked.path);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await _pickImage();
                    setState(() {});
                  },
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: _tempImageFile != null
                        ? FileImage(_tempImageFile!)
                        : const AssetImage('asset/icon/user.png')
                              as ImageProvider,
                    child: _tempImageFile == null
                        ? const Icon(Icons.camera_alt, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                _buildProfileEditableItem(
                  icon: iconWidget('asset/icon/user.png'),
                  labelText: 'Username',
                  controller: userController,
                  readOnly: true,
                ),
                _buildProfileEditableItem(
                  icon: iconWidget('asset/icon/id-card.png'),
                  labelText: 'Full Name',
                  controller: nameController,
                ),
                _buildProfileEditableItem(
                  icon: iconWidget('asset/icon/phone.png'),
                  labelText: 'Phone',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                _buildProfileEditableItem(
                  icon: iconWidget('asset/icon/gmail.png'),
                  labelText: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Profile updated (mock)!')),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 🔹 CHANGE PASSWORD DIALOG
  // ----------------------------------------------------------------------
  Future<void> _showChangePasswordAlert(BuildContext context) async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Old password'),
            ),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              if (newPassController.text == confirmController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Password changed!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Passwords do not match!')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 🔹 HANDLE MENU ACTIONS
  // ----------------------------------------------------------------------
  void _onSelected(BuildContext context, ProfileMenuAction result) {
    if (result == ProfileMenuAction.profile) {
      _showProfileAlert(context);
    } else if (result == ProfileMenuAction.changepassword) {
      _showChangePasswordAlert(context);
    } else if (result == ProfileMenuAction.logout) {
      // ✅ logout: กลับหน้า login และล้าง stack ทั้งหมด
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // ----------------------------------------------------------------------
  // 🔹 BUILD POPUP MENU
  // ----------------------------------------------------------------------
  List<PopupMenuEntry<ProfileMenuAction>> _buildItems() => [
    PopupMenuItem(
      enabled: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userData?['name'] ?? 'Guest',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            (userData?['role'] ?? 'student').toString().toUpperCase(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ),
    const PopupMenuDivider(),
    PopupMenuItem(
      value: ProfileMenuAction.profile,
      child: Row(
        children: const [
          Icon(Icons.person, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text('Profile'),
        ],
      ),
    ),
    PopupMenuItem(
      value: ProfileMenuAction.changepassword,
      child: Row(
        children: const [
          Icon(Icons.lock, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text('Change Password'),
        ],
      ),
    ),
    const PopupMenuDivider(),
    PopupMenuItem(
      value: ProfileMenuAction.logout,
      child: Row(
        children: const [
          Icon(Icons.logout, color: Colors.redAccent),
          SizedBox(width: 8),
          Text('Logout'),
        ],
      ),
    ),
  ];

  // ----------------------------------------------------------------------
  // 🔹 WIDGET BUILD
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProfileMenuAction>(
      onSelected: (result) => _onSelected(context, result),
      itemBuilder: (context) => _buildItems(),
      icon: const Icon(Icons.more_horiz, color: Colors.white, size: 36),
      color: Colors.white,
      elevation: 10,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
