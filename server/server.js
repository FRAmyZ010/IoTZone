
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
    image: user.image, // ✅ เพิ่มบรรทัดนี้
  },
});
  } catch (err) {
    console.error("❌ Login error:", err);
    res.status(500).json({ message: "Internal server error" });
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
// ------------------ Borrow Asset ------------------
app.post('/api/borrow', async (req, res) => {
  const { asset_id, borrower_id } = req.body;

  try {
    // ✅ ตรวจว่าสินทรัพย์นี้ถูกยืมหรือรออนุมัติอยู่ไหม
    const [rows] = await db.promise().query(
      `SELECT * FROM history 
       WHERE asset_id = ? 
       AND status IN (1, 2, 4) 
       LIMIT 1`,
      [asset_id]
    );

    if (rows.length > 0) {
      return res.status(400).json({
        message:
          'This asset is already borrowed or waiting for approval. Please try again later.',
      });
    }

    // ✅ ตรวจว่านักศึกษายืมครบ 1 ชิ้นแล้วในวันนี้หรือยัง
    const [checkUser] = await db.promise().query(
      `SELECT * FROM history 
       WHERE borrower_id = ? 
       AND DATE(borrow_date) = CURDATE()
       AND status IN (1, 2, 4)`,
      [borrower_id]
    );

    if (checkUser.length > 0) {
      return res.status(400).json({
        message:
          'You already have a pending or active borrow request. Please wait until it is approved or returned.',
      });
    }

    // ✅ ถ้ายังไม่มีการยืม → insert record ใหม่ใน history
    await db.promise().query(
      `INSERT INTO history (asset_id, borrower_id, status, borrow_date)
       VALUES (?, ?, 1, NOW())`,
      [asset_id, borrower_id]
    );

    // ✅ เปลี่ยนสถานะสินทรัพย์เป็น Pending (status = 3)
    await db.promise().query(`UPDATE asset SET status = 3 WHERE id = ?`, [asset_id]);

    res.json({ message: 'Borrow request submitted successfully!' });
  } catch (err) {
    console.error('❌ Borrow error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});
// ------------------ Check if user already borrowed ------------------
app.get('/api/check-borrow-status/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const [rows] = await db.promise().query(
      `SELECT * FROM history 
       WHERE borrower_id = ? 
       AND status IN (1, 2, 4)
       LIMIT 1`,
      [userId]
    );

    if (rows.length > 0) {
      return res.json({
        hasActiveRequest: true,
        message:
          'You already have a borrow request pending or active. Please wait for approval or return the asset first.',
      });
    } else {
      return res.json({
        hasActiveRequest: false,
        message: 'You can borrow a new asset.',
      });
    }
  });
});
app.get('/api/check-borrow-status/:userId', async (req, res) => {
  const { userId } = req.params;
  const [rows] = await db.promise().query(
    'SELECT * FROM history WHERE borrower_id = ? AND status IN (1,2,4)', 
    [userId]
  );

  if (rows.length > 0) {
    return res.json({ hasActiveRequest: true, message: "You already have an active or pending borrow request." });
  } else {
    return res.json({ hasActiveRequest: false });
  }
});


// =================== API Edit Profile =======================

app.put('/api/edit-profile/:uid',(req,res)=>{
  const uid = req.params.uid;
  const {name,phone,email,image} = req.body;

  console.log('📩 API called: /api/edit-profile/' + uid);

  const sql = "UPDATE user SET name = ?, phone = ?, email = ?, image = ? WHERE id = ?"

  db.query(sql,[name,phone,email,image,uid],(err,result)=>{
    if(err){
      console.error('❌ Error fetching User ID:',err);
      return res.status(500).json({error:'Database query failed',details:err});

    }else{
      console.log('✅ Query success, rows:',result.length);
      res.json(result);
    }
  })
  
})

// ------------------ Root ------------------
app.get('/', (req, res) => {
  res.send('🚀 Server is running and ready to use!');
});

// ------------------ Start Server ------------------
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});
