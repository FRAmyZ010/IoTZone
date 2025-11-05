import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iot_zone/Page/Login/login_page.dart';
import 'package:path/path.dart' as path;
import 'package:iot_zone/Page/AppConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ***************************************************************
// ** WIDGETS จำลอง: หน้าจอ Login (สำหรับ Logout) **
// ***************************************************************

// ***************************************************************
// ** WIDGETS หลัก: UserProfileMenu **
// ***************************************************************

enum ProfileMenuAction { profile, changepassword, logout, meatball }

class UserProfileMenu extends StatelessWidget {
  UserProfileMenu({super.key});

  String url = AppConfig.baseUrl;
  String uid = '1';

  final ImagePicker _picker = ImagePicker();

  // ----------------------------------------------------------------------
  // ** WIDGET HELPER: สร้างรายการข้อมูลโปรไฟล์ที่แก้ไขได้ (TextFormField) **
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
          SizedBox(width: 20, height: 20, child: icon),
          const SizedBox(width: 12),
          // ช่องป้อนข้อมูล (TextFormField โค้งมน)
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
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
    String initialUsername = 'Doi,za007'; // column: user
    String initialFullName = 'Parinthon Somphakdee'; // column: name
    String initialPhone = '0xx-xxxxxxx'; // column: phone
    String initialEmail = 'doiza007@gmai.com'; // column: email
    // *****************************************************************

    File? _tempImageFile;
    String? _tempFileName;

    // Mock icons (เพื่อให้คล้ายกับรูปที่แนบมา)
    // NOTE: เปลี่ยนเป็น AssetImage ที่ถูกต้องของคุณ หรือใช้ Icon() แทน
    Widget userIcon = Image.asset('asset/icon/user.png', width: 5, height: 5);
    Widget nameIcon = Image.asset(
      'asset/icon/id-card.png',
      width: 5,
      height: 5,
    );
    Widget phoneIcon = Image.asset('asset/icon/phone.png', width: 5, height: 5);
    Widget emailIcon = Image.asset('asset/icon/gmail.png', width: 5, height: 5);

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
                          title: const Text('Gallery'),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _alertPickImage(ImageSource.gallery);
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
                        Image.asset(
                          'asset/icon/user.png',
                          width: 25,
                          height: 25,
                        ),
                        // Header
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Profile',
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
                // ปุ่ม CONFIRM
                FilledButton(
                  onPressed: () async {
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
                      try {
                        Uri uri = Uri.parse('$url/api/edit-profile/$uid');
                        Map updateProfile = {
                          'name': newFullName.trim(),
                          'phone': newPhone.trim(),
                          'email': newEmail.trim(),
                        };

                        http.Response response = await http
                            .put(
                              uri,
                              body: jsonEncode(updateProfile),
                              headers: {'Content-Type': 'application/json'},
                            )
                            .timeout(const Duration(seconds: 10));

                        if (response.statusCode == 200) {
                          debugPrint('Edit profile success!!');
                        } else {
                          debugPrint('Edit profile failed');
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                      }
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
                // ปุ่มยกเลิก (Cancel) - สีแดง
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
  // 2. ฟังก์ชันแสดง AlertDialog Change Password
  // ----------------------------------------------------------------------

  Future<void> _showChangePasswordAlert(BuildContext context) async {
    // สร้าง Controllers สำหรับการจัดการข้อความ
    final TextEditingController oldPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // Icon ตามภาพที่แนบมา
    // NOTE: เปลี่ยนเป็น AssetImage ที่ถูกต้องของคุณ หรือใช้ Icon() แทน
    Widget lockIcon = Image.asset(
      'asset/icon/padlock.png',
      width: 30,
      height: 30,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // ใช้ StatefulBuilder เพื่อจัดการ State ภายใน Alert
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // ************ WIDGET HELPER: buildPasswordField ภายใน State ************
            // เพื่อให้สามารถเข้าถึง Controller อื่นๆ ได้ในการทำ Validation
            Widget buildPasswordField({
              required TextEditingController controller,
              required String labelText,
            }) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0,
                ),
                child: TextFormField(
                  controller: controller,
                  obscureText: true,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(
                    // Textfield ที่โค้งมนและมีพื้นหลังสีเทาอ่อน
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    labelText: labelText,
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                        color: Colors.black12,
                        width: 1.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the $labelText.';
                    }
                    // ตรวจสอบความถูกต้องของ Confirm Password
                    if (labelText == 'Confirm new password' &&
                        newPassController.text != confirmPassController.text) {
                      return 'New password and confirm password do not match.';
                    }
                    return null;
                  },
                ),
              );
            }
            // *******************************************************************

            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),

              // **ส่วน Content หลัก**
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350.0),
                child: SingleChildScrollView(
                  child: Padding(
                    // ปรับ Padding ด้านข้างให้น้อยลงเพื่อให้ปุ่มดู 'กว้าง' ขึ้น
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Header Icon
                          lockIcon,

                          // Header Text
                          const Padding(
                            padding: EdgeInsets.only(bottom: 25, top: 8),
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),

                          // ช่องป้อน Current Password
                          buildPasswordField(
                            controller: oldPassController,
                            labelText: 'Current password',
                          ),

                          // ช่องป้อน New Password
                          buildPasswordField(
                            controller: newPassController,
                            labelText: 'New password',
                          ),

                          // ช่องป้อน Confirm New Password
                          buildPasswordField(
                            controller: confirmPassController,
                            labelText: 'Confirm new password',
                          ),

                          const SizedBox(height: 30),
                          // ปุ่ม CONFIRM
                          SizedBox(
                            width: 140, // ทำให้ปุ่มกว้างเต็มพื้นที่ตาม Padding
                            height: 55,
                            child: FilledButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Logic การบันทึกรหัสผ่าน
                                  final String oldPass = oldPassController.text;
                                  final String newPass = newPassController.text;

                                  debugPrint('Old Password: $oldPass');
                                  debugPrint('New Password: $newPass');

                                  // TODO:
                                  // 1. ใส่ Logic ตรวจสอบ Old Password
                                  // 2. ใส่ Logic อัปเดต New Password ใน Database

                                  Navigator.of(context).pop();
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF37E451),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 2,
                              ),
                              child: const Text('CONFIRM'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: const [], // ไม่มี actions ด้านล่าง
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // 3. ฟังก์ชันจัดการเมื่อผู้ใช้เลือกรายการ (แก้ไข Logic Log-out)
  // ----------------------------------------------------------------------
  void _onSelected(BuildContext context, ProfileMenuAction result) {
    if (result == ProfileMenuAction.profile) {
      _showProfileAlert(context);
    } else if (result == ProfileMenuAction.meatball) {
    } else if (result == ProfileMenuAction.changepassword) {
      _showChangePasswordAlert(context);
    } else if (result == ProfileMenuAction.logout) {
      // ** Logic Log-out: นำทางไปหน้า Login และล้าง Stack **
      debugPrint('User is logging out...');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false, // ล้างทุกหน้า
      );
    }
  }

  // ----------------------------------------------------------------------
  // 4. ฟังก์ชันสร้างรายการเมนูพร้อมไอคอน
  // ----------------------------------------------------------------------
  List<PopupMenuEntry<ProfileMenuAction>> _buildItems() {
    // NOTE: เปลี่ยนเป็น AssetImage ที่ถูกต้องของคุณ หรือใช้ Icon() แทน
    return <PopupMenuEntry<ProfileMenuAction>>[
      const PopupMenuItem<ProfileMenuAction>(
        // รายการว่างด้านบน
        value: ProfileMenuAction.meatball,
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
            const SizedBox(width: 8),
            const Text('Profile'),
          ],
        ),
      ),
      PopupMenuItem<ProfileMenuAction>(
        value: ProfileMenuAction.changepassword,
        child: Row(
          children: [
            Image.asset('asset/icon/padlock.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('Change password'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<ProfileMenuAction>(
        value: ProfileMenuAction.logout,
        child: Row(
          children: [
            Image.asset('asset/icon/switch.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('Log-out'),
          ],
        ),
      ),
    ];
  }

  // ----------------------------------------------------------------------
  // 5. Widget build
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProfileMenuAction>(
      onSelected: (result) => _onSelected(context, result),
      itemBuilder: (context) => _buildItems(),
      icon: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Icon(Icons.more_horiz, color: Colors.white, size: 48),
      ),
      padding: EdgeInsets.zero,
      offset: const Offset(10, 0),
      color: Colors.white,
      elevation: 8,
    );
  }
}

// ***************************************************************
// ** ตัวอย่างการเรียกใช้ (ถ้าคุณต้องการทดสอบ Widget นี้ในแอป) **
// ***************************************************************

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Menu Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main App Screen'),
        backgroundColor: Colors.blueGrey,
        actions: [
          UserProfileMenu(),
        ],
      ),
      body: const Center(
        child: Text('Click the menu button (···) to see the options.'),
      ),
    );
  }
}
*/
