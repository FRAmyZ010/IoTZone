# Mobile App Project

โปรเจกต์นี้ประกอบด้วย **Flutter frontend** (`iot_zone/`) และ **Node.js + MySQL backend** (`server/`) สำหรับระบบ IoT Zone

---

## โครงสร้างโปรเจกต์

```
iot_project/
│
├── iot_zone/      # Flutter frontend
└── server/        # Node.js backend
```

---

## 1. Clone โปรเจกต์

```bash
git clone <URL ของ GitHub>
cd iot_project
```

---

## 2. Backend (Node.js + MySQL)

### 2.1 ติดตั้ง dependencies
```bash
cd server
npm install
```

Dependencies สำคัญ:
- `express` → เว็บเซิร์ฟเวอร์
- `mysql2` → เชื่อม MySQL
- `bcrypt` → เข้ารหัสรหัสผ่าน
- `nodemon` → รีสตาร์ท server อัตโนมัติเวลาแก้ไฟล์



### 2.2 สร้างฐานข้อมูล MySQL
```sql
CREATE DATABASE iot_zone;
```

### 2.4 รัน backend
```bash
# รันแบบ dev ด้วย nodemon
npm run dev

# รันปกติ
npm start
```

Server จะรันที่ `http://localhost:3000`

---

## 3. Frontend (Flutter)

### 3.1 ติดตั้ง dependencies
```bash
cd ../iot_zone
flutter pub get
```

### 3.2 แก้ไขค่า API URL
ในไฟล์ config หรือ service ของ Flutter ให้ตั้งค่า URL ของ backend:
```dart
const String apiUrl = "http://localhost:3000";
```
> ⚠ หากรันบนมือถือ ให้ใช้ IP ของเครื่องแทน `localhost`

### 3.3 รันแอป
```bash
flutter run
```

---

## 4. Tips & Best Practices

1. ใช้ `.gitignore` สำหรับ `node_modules/` และ `build/` 
2. Flutter จะเรียก API ผ่าน HTTP ไม่เชื่อม MySQL โดยตรง