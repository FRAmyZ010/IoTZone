// server.js
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// ✅ 1. ตั้งค่าการเชื่อมต่อฐานข้อมูล
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',           // หรือใส่ user ที่คุณตั้งไว้
  password: '',           // ถ้ามีรหัสผ่านให้ใส่
  database: 'project_iotzone_db',
});

// ✅ ตรวจสอบการเชื่อมต่อ
db.connect((err) => {
  if (err) {
    console.error('❌ Database connection failed:', err);
  } else {
    console.log('✅ Connected to MySQL database');
  }
});

// ✅ 2. สร้าง API ดึงข้อมูลประวัติ (History)
app.get('/api/history/:studentId', (req, res) => {
  const studentId = req.params.studentId;
  console.log('📩 API called: /api/history/' + studentId);

  const sql = `
    SELECT 
      a.asset_name AS name,
      CASE 
        WHEN h.status = 3 THEN 'Rejected'
        WHEN h.status = 4 THEN 'Returned'
        ELSE 'Pending'
      END AS status,
      h.borrow_date AS borrowDate,
      h.return_date AS returnDate,
      h.reason,
      a.img AS image -- ✅ ใช้คอลัมน์ img จากฐานข้อมูล
    FROM history h
    JOIN asset a ON h.asset_id = a.id
    WHERE h.borrower_id = ?
      AND (h.status = 3 OR h.status = 4)
    ORDER BY h.borrow_date DESC;
  `;

  db.query(sql, [studentId], (err, results) => {
    if (err) {
      console.error('❌ Error fetching history:', err);
      res.status(500).json({ error: 'Database query failed', details: err });
    } else {
      console.log('✅ Query success, rows:', results.length);
      res.json(results);
    }
  });
});


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server is running on http://localhost:${PORT}`);
});
