// วิธีรันเซิร์ฟ: nodemon --watch server.js

const express = require('express');
const db = require('./db.js');
const bcrypt = require('bcrypt');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

const app = express();
const PORT = 3000;

// ✅ Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ ให้เข้าถึงโฟลเดอร์ uploads ได้
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ------------------ Multer: สำหรับ Upload รูปภาพ ------------------
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // เก็บไฟล์ในโฟลเดอร์ uploads
  },
  filename: function (req, file, cb) {
    const uniqueName = Date.now() + '-' + file.originalname;
    cb(null, uniqueName);
  },
});
const upload = multer({ storage });

// 📸 API Upload รูปภาพ
app.post('/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }
  console.log('📸 Uploaded:', req.file.filename);
  res.json({
    message: 'Upload successful',
    filename: req.file.filename,
    filePath: `/uploads/${req.file.filename}`,
  });
});

// ------------------ Register ------------------
app.post('/register', (req, res) => {
  const { username, password, name, phone, email } = req.body;

  if (!username || !password || !name || !phone || !email) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  bcrypt.hash(password, 10, (err, hash) => {
    if (err) {
      console.error('Error hashing password:', err);
      return res.status(500).json({ message: 'Internal server error' });
    }

    const sql =
      'INSERT INTO user (username, password, name, phone, email) VALUES (?, ?, ?, ?, ?)';
    db.query(sql, [username, hash, name, phone, email], (err, result) => {
      if (err) {
        if (err.code === 'ER_DUP_ENTRY') {
          return res.status(409).json({ message: 'Username already exists' });
        }
        console.error('Database error:', err);
        return res.status(500).json({ message: 'Internal server error' });
      }

      res.status(201).json({
        message: 'User registered successfully',
        userId: result.insertId,
        username: username,
      });
    });
  });
});

// ------------------ Get All Assets ------------------
app.get('/assets', (req, res) => {
  const sql = 'SELECT * FROM asset';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('❌ Database error:', err);
      return res.status(500).json({ message: 'Internal server error' });
    }

    try {
      const formatted = results.map((row) => {
        let imgPath = row.img || 'no_image.png';

        // ✅ Normalize path ให้ตรงรูปแบบ
        if (imgPath.startsWith('/uploads/') || imgPath.startsWith('uploads/')) {
          imgPath = imgPath.startsWith('/')
            ? imgPath
            : '/' + imgPath; // ให้เป็น /uploads/filename.png
        } else if (imgPath.startsWith('asset/img/')) {
          // ใช้ตามที่มีได้เลย
          imgPath = imgPath;
        } else if (!imgPath.includes('/')) {
          // กรณีเป็นแค่ชื่อไฟล์ เช่น "Resistor.png"
          imgPath = `asset/img/${imgPath}`;
        } else {
          // fallback
          imgPath = 'asset/img/no_image.png';
        }

        return {
          id: row.id,
          name: row.asset_name || 'Unknown',
          description: row.description || '',
          type: row.type || 'Unknown',
          status: mapStatus(row.status ?? 0),
          image: imgPath,
          statusColorValue: getColor(row.status ?? 0),
        };
      });

      res.json(formatted);
    } catch (err) {
      console.error('❌ Format error:', err);
      res.status(500).json({ message: 'Format error' });
    }
  });
});

// 🔹 แปลงสถานะตัวเลขเป็นข้อความ
function mapStatus(code) {
  switch (Number(code)) {
    case 1:
      return 'Available';
    case 2:
      return 'Disabled';
    case 3:
      return 'Pending';
    case 4:
      return 'Borrowed';
    default:
      return 'Unknown';
  }
}

// 🔹 กำหนดสีสถานะ
function getColor(code) {
  switch (Number(code)) {
    case 1:
      return 0xFF00FF00; // เขียว
    case 2:
      return 0xFFFF0000; // แดง
    case 3:
      return 0xFFFFA500; // ส้ม
    case 4:
      return 0xFF808080; // เทา
    default:
      return 0xFF000000;
  }
}

// ------------------ CRUD: Asset ------------------

// ➕ เพิ่มข้อมูลใหม่
app.post('/assets', (req, res) => {
  const { name, type, description, status, image } = req.body;
  const sql = `INSERT INTO asset (asset_name, type, description, status, img)
               VALUES (?, ?, ?, ?, ?)`;
  db.query(sql, [name, type, description, status, image], (err, result) => {
    if (err)
      return res.status(500).json({ message: 'Insert failed', error: err });
    res.json({ id: result.insertId, message: 'Asset added successfully' });
  });
});

// ✏️ แก้ไขข้อมูล
app.put('/assets/:id', (req, res) => {
  const { id } = req.params;
  const { name, type, description, status, image } = req.body;
  const sql = `UPDATE asset 
               SET asset_name=?, type=?, description=?, status=?, img=? 
               WHERE id=?`;
  db.query(sql, [name, type, description, status, image, id], (err) => {
    if (err)
      return res.status(500).json({ message: 'Update failed', error: err });
    res.json({ message: 'Asset updated successfully' });
  });
});

// 🗑️ ลบข้อมูล
app.delete('/assets/:id', (req, res) => {
  const { id } = req.params;
  db.query('DELETE FROM asset WHERE id=?', [id], (err) => {
    if (err)
      return res.status(500).json({ message: 'Delete failed', error: err });
    res.json({ message: 'Asset deleted successfully' });
  });
});

// 🔄 เปลี่ยนสถานะ
app.patch('/assets/:id/status', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  console.log(`🟢 Update status of ID ${id} → ${status}`);

  db.query('UPDATE asset SET status=? WHERE id=?', [status, id], (err) => {
    if (err) {
      console.error('❌ Error:', err);
      return res
        .status(500)
        .json({ message: 'Status update failed', error: err });
    }
    res.json({ message: `Status updated to ${status}` });
  });
});

// ------------------ Root ------------------
app.get('/', (req, res) => {
  res.send('🚀 Server is running and ready to use!');
});

// ------------------ Start Server ------------------
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});
