import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  // Key ที่ใช้ในการเก็บข้อมูล
  static const String _keyUserId = 'userId';
  static const String _keyRole = 'role';

  // 1. บันทึกข้อมูล (ใช้ตอน Login สำเร็จ)
  static Future<void> saveUser(String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyRole, role);
  }

  // 2. ดึงค่า userID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // 3. ดึงค่า Role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  // 4. ลบข้อมูล (ใช้ตอน Logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
  }
}