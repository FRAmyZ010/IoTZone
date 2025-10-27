import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

// อาจจะอยู่ในไฟล์ Widgets/user_profile_menu.dart
enum ProfileMenuAction { profile, changepassword, logout }

class UserProfileMenu extends StatelessWidget {
  UserProfileMenu({super.key});

  // ตัวแปรและ Instance ของ ImagePicker
  final ImagePicker _picker = ImagePicker();

  // ----------------------------------------------------------------------
  // **NEW WIDGET: สร้างรายการข้อมูลโปรไฟล์ที่แก้ไขได้ (TextFormField)**
  // ----------------------------------------------------------------------
  Widget _buildProfileEditableItem({
    required Widget icon,
    required String labelText,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ไอคอน (อยู่ด้านซ้ายมือ)
          SizedBox(width: 40, height: 40, child: icon),
          const SizedBox(width: 12),
          // ช่องป้อนข้อมูล (TextFormField โค้งมน)
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                labelText: labelText,
                labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                // ปรับแต่งขอบเขตให้โค้งมนและมีพื้นหลัง
                filled: true,
                fillColor: Colors.grey.shade100, // สีพื้นหลังอ่อน ๆ
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide.none, // ลบเส้นขอบออกเพื่อให้ดูเรียบตามภาพ
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ), // เส้นขอบเมื่อโฟกัส
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 1. ฟังก์ชันแสดง AlertDialog Profile (มีการจัดการ State ภายใน)
  // ----------------------------------------------------------------------
  Future<void> _showProfileAlert(BuildContext context) async {
    // Mock Data (จำลองข้อมูลที่ได้จากการ Get จาก DB/Session)
    // *****************************************************************
    const String initialUsername = 'Doi,za007'; // column: user
    const String initialFullName = 'Parinthon Somphakdee'; // column: name
    const String initialPhone = '0xx-xxxxxxx'; // column: phone
    const String initialEmail = 'doiza007@gmai.com'; // column: email
    // *****************************************************************

    File? _tempImageFile;
    String? _tempFileName;

    // Mock icons (เพื่อให้คล้ายกับรูปที่แนบมา)
    Widget userIcon = Image.asset('asset/icon/user.png', width: 10, height: 10);
    Widget nameIcon = Image.asset(
      'asset/icon/id-card.png',
      width: 10,
      height: 10,
    );
    Widget phoneIcon = Image.asset(
      'asset/icon/phone.png',
      width: 10,
      height: 10,
    );
    Widget emailIcon = Image.asset(
      'asset/icon/gmail.png',
      width: 10,
      height: 10,
    );

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // **ใช้ StatefulBuilder เพื่อให้ UI ภายใน AlertDialog เปลี่ยนแปลงได้**
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // **ตัวแปร Controllers (ต้องสร้างใน builder เพื่อจัดการ State)**
            final TextEditingController userController = TextEditingController(
              text: initialUsername,
            );
            final TextEditingController nameController = TextEditingController(
              text: initialFullName,
            );
            final TextEditingController phoneController = TextEditingController(
              text: initialPhone,
            );
            final TextEditingController emailController = TextEditingController(
              text: initialEmail,
            );

            // --- ฟังก์ชัน 1: เลือกรูปภาพและอัปเดต State (รวมการเก็บชื่อไฟล์) ---
            Future<void> _alertPickImage(ImageSource source) async {
              try {
                final pickedFile = await _picker.pickImage(
                  source: source,
                  imageQuality: 70,
                );
                if (pickedFile != null) {
                  setState(() {
                    _tempImageFile = File(pickedFile.path);
                    // **ดึงชื่อไฟล์ (basename) จาก Path และเก็บไว้**
                    _tempFileName = path.basename(pickedFile.path);
                  });
                }
              } catch (e) {
                debugPrint('Failed to pick image: $e');
              }
            }

            // --- ฟังก์ชัน 2: แสดงตัวเลือก Camera/Gallery (เหมือนเดิม) ---
            void _alertShowChoiceDialog() {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext sheetContext) {
                  return SafeArea(
                    child: Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('เลือกจากแกลเลอรี (Disk)'),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _alertPickImage(ImageSource.gallery);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('ถ่ายรูปด้วยกล้อง'),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _alertPickImage(ImageSource.camera);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            // --------------------------------------------------

            return AlertDialog(
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Form(
                    // ใช้ Form เพื่อจัดการการตรวจสอบข้อมูล
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        // **ส่วนแสดงรูปภาพและปุ่มเลือก**
                        GestureDetector(
                          onTap: _alertShowChoiceDialog,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _tempImageFile == null
                                ? null
                                : FileImage(_tempImageFile!) as ImageProvider,
                            child: _tempImageFile == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _tempFileName != null
                              ? 'Selected: $_tempFileName'
                              : 'Tap to change image',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // **รายการข้อมูลโปรไฟล์ที่แก้ไขได้ (ตามภาพ)**
                        _buildProfileEditableItem(
                          icon: userIcon,
                          labelText: 'Username',
                          controller: userController,
                          readOnly: true, // column: user
                        ),
                        _buildProfileEditableItem(
                          icon: nameIcon,
                          labelText: 'Full Name',
                          controller: nameController, // column: name
                        ),
                        _buildProfileEditableItem(
                          icon: phoneIcon,
                          labelText: 'Phone',
                          controller: phoneController,
                          keyboardType: TextInputType.phone, // column: phone
                        ),
                        _buildProfileEditableItem(
                          icon: emailIcon,
                          labelText: 'Email',
                          controller: emailController,
                          keyboardType:
                              TextInputType.emailAddress, // column: email
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                // ปุ่มยกเลิก (Cancel) - สีแดง
                FilledButton(
                  onPressed: () {
                    // **Logic การบันทึกข้อมูล**
                    if (_formKey.currentState!.validate()) {
                      // 1. ดึงข้อมูลใหม่จาก Controller (ใช้สำหรับ UPDATE DB)
                      final String newUsername = userController.text;
                      final String newFullName = nameController.text;
                      final String newPhone = phoneController.text;
                      final String newEmail = emailController.text;

                      debugPrint('New Username: $newUsername (user)');
                      debugPrint('New Full Name: $newFullName (name)');

                      if (_tempImageFile != null) {
                        debugPrint('New Image Path: ${_tempImageFile!.path}');
                        debugPrint('New Image File Name: $_tempFileName (img)');
                      }

                      // TODO:
                      // 1. ใส่ Logic อัปโหลดรูป (ถ้ามี) (_tempImageFile, _tempFileName -> column: img)
                      // 2. ใส่ Logic Update ข้อมูลใน Database (ใช้ newUsername, newFullName, newPhone, newEmail, _tempFileName)

                      // ปิด Alert
                      Navigator.of(context).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF37E451),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Confirm'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2147),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // 4. ฟังก์ชันจัดการเมื่อผู้ใช้เลือกรายการ (เหมือนเดิม)
  // ----------------------------------------------------------------------
  void _onSelected(BuildContext context, ProfileMenuAction result) {
    if (result == ProfileMenuAction.profile) {
      _showProfileAlert(context);
    } else if (result == ProfileMenuAction.changepassword) {
      // Logic เปลี่ยนรหัสผ่าน
    } else if (result == ProfileMenuAction.logout) {
      // Logic Log-out
    }
  }

  // ----------------------------------------------------------------------
  // 5. ฟังก์ชันสร้างรายการเมนูพร้อมไอคอน (เหมือนเดิม)
  // ----------------------------------------------------------------------
  List<PopupMenuEntry<ProfileMenuAction>> _buildItems() {
    return <PopupMenuEntry<ProfileMenuAction>>[
      PopupMenuItem<ProfileMenuAction>(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Icon(Icons.more_horiz, color: Colors.black, size: 48)],
        ),
      ),
      PopupMenuItem<ProfileMenuAction>(
        value: ProfileMenuAction.profile,
        child: Row(
          children: [
            Image.asset('asset/icon/user.png', width: 24, height: 24),
            SizedBox(width: 8),
            Text('Profile'),
          ],
        ),
      ),
      PopupMenuItem<ProfileMenuAction>(
        value: ProfileMenuAction.changepassword,
        child: Row(
          children: [
            Image.asset('asset/icon/padlock.png', width: 24, height: 24),
            SizedBox(width: 8),
            Text('Change password'),
          ],
        ),
      ),
      PopupMenuDivider(),
      PopupMenuItem<ProfileMenuAction>(
        value: ProfileMenuAction.logout,
        child: Row(
          children: [
            Image.asset('asset/icon/switch.png', width: 24, height: 24),
            SizedBox(width: 8),
            Text('Log-out'),
          ],
        ),
      ),
    ];
  }

  // ----------------------------------------------------------------------
  // 6. Widget build (เหมือนเดิม)
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProfileMenuAction>(
      onSelected: (result) => _onSelected(context, result),
      itemBuilder: (context) => _buildItems(),
      icon: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: const Icon(Icons.more_horiz, color: Colors.white, size: 48),
      ),
      padding: EdgeInsets.zero,
      offset: const Offset(10, 0),
      color: Colors.white,
      elevation: 8,
    );
  }
}
