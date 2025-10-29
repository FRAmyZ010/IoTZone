class AppConfig {
  // 🔹 เก็บค่า IP หลักของ Server
  static const String serverIP = 'ให้ทุกคน ใส่ IP ของตัวเอง';
  // วิธีการดู IP 
  // 1. เปิด Terminal ใน vscode หรือ Command prompt ก็ได้
  // 2. พิมพ์ ipconfig
  // 3. มองหาตัวเลข IP ที่อยู่หลัง IPv4 Address

  // (ถ้ามี API หลายอันสามารถเพิ่มได้)
  static String get baseUrl => 'http://$serverIP:3000';
}
