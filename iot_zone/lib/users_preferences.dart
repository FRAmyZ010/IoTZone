import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _keyUserId = 'user_id';
  static const _keyRole = 'role';

  // บันทึกค่า
  static Future<void> saveUser(String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyRole, role);
  }

  // อ่านค่า UserId
  static Future<String?> getUserid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // อ่านค่า Role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  // ลบค่าตอน Logout
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
  }
}
