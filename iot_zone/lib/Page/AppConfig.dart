class AppConfig {
  // 🔹 เก็บค่า IP หลักของ Server
  static const String serverIP = '172.27.8.96';

  // (ถ้ามี API หลายอันสามารถเพิ่มได้)
  static String get baseUrl => 'http://$serverIP:3000';
}
