// server.js
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',          
  password: '',           
  database: 'project_iotzone_db',
});

db.connect((err) => {
  if (err) {
    console.error('❌ Database connection failed:', err);
  } else {
    console.log('✅ Connected to MySQL database');
  }
});
// API Request Status (Student)
app.get('/api/request-status/:studentId', (req, res) => {
  const studentId = req.params.studentId;
  console.log('📩 API called: /api/request-status/' + studentId);

  const sql = `
    SELECT 
      a.asset_name AS name,
      CASE 
        WHEN h.status = 1 THEN 'Pending'
        WHEN h.status = 2 THEN 'Borrowed'
        ELSE 'Other'
      END AS status,
      h.borrow_date AS borrowDate,
      h.return_date AS returnDate,
      a.img AS image
    FROM history h
    JOIN asset a ON h.asset_id = a.id
    WHERE h.borrower_id = ?
      AND (h.status = 1 OR h.status = 2)
    ORDER BY h.borrow_date DESC;
  `;

  db.query(sql, [studentId], (err, results) => {
    if (err) {
      console.error('❌ Error fetching request status:', err);
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