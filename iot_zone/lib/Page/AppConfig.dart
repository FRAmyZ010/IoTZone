class AppConfig {
  // 🔹 เก็บค่า IP หลักของ Server
  static const String serverIP = '192.168.145.1';

  // (ถ้ามี API หลายอันสามารถเพิ่มได้)
  static String get baseUrl => 'http://$serverIP:3000';
}
