import 'package:flutter/material.dart';

// อาจจะอยู่ในไฟล์ Widgets/user_profile_menu.dart
enum ProfileMenuAction { profile, changepassword, logout }

class UserProfileMenu extends StatelessWidget {
  const UserProfileMenu({super.key});

  Future<void> _showProfileAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // อนุญาตให้ปิด Alert เมื่อแตะนอกกล่อง
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('asset/icon/user.png', width: 30, height: 30),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FilledButton(onPressed: () {}, child: Text('Confirm')),
          ],
        );
      },
    );
  }

  // ฟังก์ชันจัดการเมื่อผู้ใช้เลือกรายการ
  void _onSelected(BuildContext context, ProfileMenuAction result) {
    // ใช้ ScaffoldMessenger เพื่อแสดงข้อความตอบรับ
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text("Selected: ${result.toString().split('.').last}"),
    //     duration: const Duration(seconds: 1),
    //   ),
    // );

    // TODO: ใส่ Logic สำหรับการทำงานจริงที่นี่
    if (result == ProfileMenuAction.profile) {
      // ตัวอย่าง: ไปที่หน้า Profile
      // Navigator.pushNamed(context, '/profile');
      _showProfileAlert(context);
    } else if (result == ProfileMenuAction.changepassword) {
      // ตัวอย่าง: ไปที่หน้า Settings
    } else if (result == ProfileMenuAction.logout) {
      // ตัวอย่าง: ทำการ Log-out
    }
  }

  // ฟังก์ชันสร้างรายการเมนูพร้อมไอคอน
  List<PopupMenuEntry<ProfileMenuAction>> _buildItems() {
    return <PopupMenuEntry<ProfileMenuAction>>[
      PopupMenuItem<ProfileMenuAction>(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.more_horiz, // ใช้ไอคอนสามจุดแนวนอนตามโค้ดเดิมของคุณ
              color: Colors.black,
              size: 48,
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProfileMenuAction>(
      onSelected: (result) => _onSelected(context, result),
      itemBuilder: (context) => _buildItems(),
      icon: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: const Icon(
          Icons.more_horiz, // ใช้ไอคอนสามจุดแนวนอนตามโค้ดเดิมของคุณ
          color: Colors.white,
          size: 48,
        ),
      ),
      padding: EdgeInsets.zero,
      offset: const Offset(10, 0), // เลื่อนเมนูลงมาเล็กน้อย
      color: Colors
          .white, // ทำให้พื้นหลัง Pop-up เป็นสีขาวชัดเจน (ค่าเริ่มต้นอยู่แล้ว)
      elevation: 8, // เพิ่มเงาเล็กน้อย
    );
  }
}
