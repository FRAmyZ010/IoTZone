
// วิธีรันเซิร์ฟ: nodemon --watch server.js

const express = require('express');
const db = require('./db.js');
const bcrypt = require('bcrypt');
const cors = require('cors');
const multer = require('multer');
const path = require('path');const argon2 = require('@node-rs/argon2');

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

app.post('/register', async (req, res) => {
  const { username, password, name, phone, email, role = 'student' } = req.body;

  if (!username || !password || !name || !phone || !email) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const [rows] = await db.promise().query(
      'SELECT * FROM user WHERE username = ? OR email = ?',
      [username, email]
    );

    if (rows.length > 0)
      return res.status(409).json({ message: 'Username or email already exists' });

    const hash = await argon2.hash(password);

    await db.promise().query(
      'INSERT INTO user (username, password, name, phone, email, role) VALUES (?, ?, ?, ?, ?, ?)',
      [username, hash, name, phone, email, role]
    );

    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// ------------------ Login ------------------
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ message: 'Username and password are required' });
  }

  try {
    const [rows] = await db.promise().query("SELECT * FROM user WHERE username = ?", [username]);
    if (rows.length === 0) return res.status(404).json({ message: "User not found" });

    const user = rows[0];
    const storedHash = user.password;

    let isMatch = false;

    try {
      // ✅ ลองตรวจด้วย argon2 ก่อน
      isMatch = await argon2.verify(storedHash, password);
    } catch (err) {
      // ❗ ถ้าไม่ใช่ hash ของ argon2 → ลอง bcrypt อีกที
      try {
        isMatch = await bcrypt.compare(password, storedHash);
      } catch (err2) {
        console.error("⚠️ bcrypt error:", err2);
      }
    }

    if (!isMatch) {
      return res.status(401).json({ message: "Invalid password" });
    }

    // ✅ ถ้า password ถูกต้อง
    res.status(200).json({
      message: 'Login successful',
      user: {
        id: user.id,
        username: user.username,
        name: user.name,
        role: user.role,
        email: user.email,
        phone: user.phone,
      },
    });

  } catch (err) {
    console.error("❌ Login error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});
// ------------------ Change  password ------------------
app.put("/api/change-password/:id", async (req, res) => {
  const { id } = req.params;
  const { oldPassword, newPassword } = req.body;

  try {
    const [rows] = await db.promise().query("SELECT password FROM user WHERE id = ?", [id]);
    if (rows.length === 0) return res.status(404).json({ message: "User not found" });

    const user = rows[0];
    const storedHash = user.password;
    let isMatch = false;

    try {
      // ✅ ลอง verify ด้วย argon2 ก่อน
      isMatch = await argon2.verify(storedHash, oldPassword);
    } catch {
      // ถ้า error → ลอง bcrypt อีกที
      isMatch = await bcrypt.compare(oldPassword, storedHash);
    }

    if (!isMatch) {
      return res.status(401).json({ message: "Incorrect current password" });
    }

    const newHash = await argon2.hash(newPassword);
    await db.promise().query("UPDATE user SET password = ? WHERE id = ?", [newHash, id]);

    res.json({ message: "Password updated successfully" });
  } catch (err) {
    console.error("❌ Change password error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});

// ------------------ Update Profile ------------------
app.put("/api/update-profile/:id", upload.single("image"), async (req, res) => {
  try {
    const userId = req.params.id;
    const { username, name, phone, email } = req.body;

    let imagePath = null;
    if (req.file) {
      imagePath = `/uploads/${req.file.filename}`;
    }

    const sql = `
      UPDATE user 
      SET username = ?, name = ?, phone = ?, email = ?, image = COALESCE(?, image)
      WHERE id = ?
    `;

    // ✅ ใช้ db.query() แทน con.query()
    db.query(sql, [username, name, phone, email, imagePath, userId], (err) => {
      if (err) {
        console.error("❌ Database update failed:", err);
        return res.status(500).json({ message: "Database update failed" });
      }

      // ✅ ดึงข้อมูล user ใหม่กลับไปให้ Flutter
      db.query("SELECT * FROM user WHERE id = ?", [userId], (err, result) => {
        if (err) {
          console.error("❌ Fetch failed:", err);
          return res.status(500).json({ message: "Fetch failed" });
        }

        console.log("✅ Updated user:", result[0]);
        res.json(result[0]); // ✅ ส่งข้อมูล user ล่าสุดกลับไป Flutter
      });
    });
  } catch (err) {
    console.error("❌ Unexpected error:", err);
    res.status(500).json({ message: "Server error" });
  }
});



// ---------------- get user -------------------
app.get('/api/get-user/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const [rows] = await db.promise().query('SELECT * FROM user WHERE id = ?', [id]);
    if (rows.length === 0)
      return res.status(404).json({ message: 'User not found' });

    res.json({ user: rows[0] });
  } catch (err) {
    console.error('❌ Get user error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
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
  name: row.asset_name || 'Unknown', // ✅ key ชื่อ name
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
      return 'Disabled';
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
      return 0xFFFF0000;
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
