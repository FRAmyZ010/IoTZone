
// วิธีรันเซิร์ฟ: nodemon --watch server.js

const express = require('express');
const db = require('./db.js');
const bcrypt = require('bcrypt');
const cors = require('cors');
const multer = require('multer');
const path = require('path'); const argon2 = require('@node-rs/argon2');

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


// =================== API Staff History ===================
app.get('/api/staff-history/:staffId', (req, res) => {
  const staffId = req.params.staffId;
  console.log('📩 API called: /api/staff-history/' + staffId);

  const sql = `
    SELECT 
      a.asset_name AS name,
      CASE 
        WHEN h.status = 3 THEN 'Rejected'
        WHEN h.status = 4 THEN 'Returned'
      END AS status,
      h.borrow_date AS borrowDate,
      h.return_date AS returnDate,
      h.reason,
      a.img AS image,
      u.name AS borrowedBy,
      s.name AS receivedBy,
      l.name AS approvedBy
    FROM history h
    JOIN asset a ON h.asset_id = a.id
    JOIN user u ON h.borrower_id = u.id
    LEFT JOIN user s ON h.receiver_id = s.id       
    LEFT JOIN user l ON h.approver_id = l.id       
    WHERE h.status IN (3,4)
    ORDER BY h.borrow_date DESC;
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('❌ Error fetching staff history:', err);
      return res.status(500).json({ error: 'Database query failed', details: err });
    }

    console.log(`✅ Staff History Found: ${results.length} rows`);
    res.json(results);
  });
});

// =================== API Lender History ===================
app.get('/api/lender-history/:lenderId', (req, res) => {
  const lenderId = req.params.lenderId;
  console.log('📩 API called: /api/lender-history/' + lenderId);

  const sql = `
    SELECT
      a.asset_name AS name,
      CASE
        WHEN h.status = '2' THEN 'Approved'
        WHEN h.status = '3' THEN 'Rejected'
      END AS status,
      h.borrow_date AS borrowDate,
      h.return_date AS returnDate,
      h.reason,
      a.img AS image,
      u.name AS borrowedBy
    FROM history h
    JOIN asset a ON h.asset_id = a.id
    JOIN user u ON h.borrower_id = u.id
    WHERE h.approver_id = ?
      AND (h.status = '2' OR h.status = '3')
    ORDER BY h.borrow_date DESC;
  `;

  db.query(sql, [lenderId], (err, results) => {
    if (err) {
      console.error('❌ Error fetching lender history:', err);
      return res.status(500).json({ error: 'Database query failed', details: err });
    }

    console.log(`✅ Lender History Found: ${results.length} rows`);
    res.json(results);
  });
});


// ==================== API Student History ===================
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




// ================== API Request Status =================

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
// 🔄 เปลี่ยนสถานะ
app.patch('/assets/:id/status', async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  console.log(`🟢 Update status of ID ${id} → ${status}`);

  try {
    // 🛑 ถ้าจะเปลี่ยนเป็น Disabled (2)
    if (Number(status) === 2) {
      // ตรวจสอบก่อนว่าสินทรัพย์นี้มีการจองหรือยืมอยู่ไหม
      const [rows] = await db.promise().query(
        `SELECT * FROM history 
         WHERE asset_id = ? 
         AND status IN (1, 2)  -- Pending หรือ Borrowed
         LIMIT 1`,
        [id]
      );

      if (rows.length > 0) {
        return res.status(400).json({
          message:
            "❌ Cannot disable this asset because it is currently borrowed or pending approval.",
        });
      }
    }

    // ✅ ถ้าไม่มีการจอง → อนุญาตให้เปลี่ยนสถานะ
    await db.promise().query('UPDATE asset SET status = ? WHERE id = ?', [
      status,
      id,
    ]);

    res.json({ message: `✅ Status updated to ${status}` });
  } catch (err) {
    console.error('❌ Error:', err);
    res.status(500).json({ message: 'Status update failed', error: err });
  }
});

// ------------------ Borrow Asset ------------------
app.post('/api/borrow', async (req, res) => {
  const { asset_id, borrower_id } = req.body;

  try {
    // ✅ 1. รีเซ็ตสินทรัพย์ที่เคยคืนแล้ว (history.status = 4) แต่ asset ยังไม่กลับเป็น Available
    await db.promise().query(`
      UPDATE asset a
      JOIN history h ON a.id = h.asset_id
      SET a.status = 1
      WHERE h.status = 4 AND a.status != 1
    `);

    // ✅ 2. ตรวจว่าสินทรัพย์นี้ถูกยืมหรือรออนุมัติอยู่ไหม
    const [rows] = await db.promise().query(
      `SELECT * FROM history 
       WHERE asset_id = ? 
       AND status IN (1, 2)  -- 1=Pending, 2=Approved
       LIMIT 1`,
      [asset_id]
    );

    if (rows.length > 0) {
      return res.status(400).json({
        message:
          'This asset is already borrowed or waiting for approval. Please try again later.',
      });
    }

    // ✅ 3. ตรวจว่าผู้ใช้มีรายการยืมที่ยังไม่คืนอยู่ไหม (Pending / Approved เท่านั้น)
    const [checkUser] = await db.promise().query(
      `SELECT * FROM history 
       WHERE borrower_id = ? 
       AND status IN (1, 2)`, // ❗ ไม่รวม Returned (4)
      [borrower_id]
    );

    if (checkUser.length > 0) {
      return res.status(400).json({
        message:
          'You already have a pending or active borrow request. Please wait until it is approved or returned.',
      });
    }

    // ✅ 4. ถ้ายังไม่มีการยืม → สร้าง record ใหม่ใน history
    await db.promise().query(
      `INSERT INTO history (asset_id, borrower_id, status, borrow_date, return_date)
   VALUES (?, ?, 1, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY))`,
      [asset_id, borrower_id]
    );

    // ✅ 5. เปลี่ยนสถานะสินทรัพย์เป็น Pending (3)
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
    // 🔹 ดึงข้อมูลที่อยู่ระหว่างยืม (status = 1, 2 เท่านั้น)
    const [rows] = await db.promise().query(
      `SELECT * FROM history 
       WHERE borrower_id = ? 
       AND status IN (1, 2)
       LIMIT 1`,
      [userId]
    );

    if (rows.length > 0) {
      // 🟡 มีรายการที่อยู่ระหว่างยืม
      return res.json({
        hasActiveRequest: true,
        message:
          'You already have a borrow request pending or active. Please wait for approval or return the asset first.',
      });
    } else {
      // 🟢 ไม่มีรายการที่อยู่ระหว่างยืม → ยืมใหม่ได้
      return res.json({
        hasActiveRequest: false,
        message: 'You can borrow a new asset.',
      });
    }
  } catch (err) {
    console.error('❌ Check borrow status error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});
// ------------------ Check if asset is being borrowed or pending ------------------
app.get('/api/check-asset-usage/:assetId', async (req, res) => {
  const { assetId } = req.params;
  try {
    const [rows] = await db.promise().query(
      `SELECT * FROM history 
       WHERE asset_id = ? 
       AND status IN (1, 2)  -- Pending หรือ Borrowed
       LIMIT 1`,
      [assetId]
    );

    if (rows.length > 0) {
      return res.json({ inUse: true, message: 'Asset is currently in use or pending approval' });
    }
    res.json({ inUse: false });
  } catch (err) {
    console.error('❌ check-asset-usage error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});
// ------------------ Update Borrow Status ------------------
app.put('/api/history/:id/status', async (req, res) => {
  const { id } = req.params;
  const { status, reason } = req.body;
  

  try {
    // ✅ ดึง asset_id จาก history
    const [historyRows] = await db.promise().query(
      `SELECT asset_id FROM history WHERE id = ?`,
      [id]
    );

    if (historyRows.length === 0) {
      return res.status(404).json({ message: 'History record not found' });
    }

    const assetId = historyRows[0].asset_id;
    console.log(`🟢 API Triggered: Update history ${id} → status ${status}`);

    // ✅ อัปเดตสถานะใน history
    await db.promise().query(
      `UPDATE history SET status = ? WHERE id = ?`,
      [status, id]
    );

    // ✅ Logic เชื่อมโยงกับ asset
    switch (Number(status)) {
      case 1: // Pending (รออนุมัติ)
        await db.promise().query(
          `UPDATE asset SET status = 3 WHERE id = ?`,
          [assetId],
          
        );
        break;

      case 2: // Approved (อนุมัติแล้ว → กำลังถูกยืม)
        await db.promise().query(
          `UPDATE asset SET status = 4 WHERE id = ?`,
          [assetId],
          
        );
         db.query('UPDATE history SET approver_id = 3 WHERE id = ?',[id]);
        break;

      case 3: // Rejected (ถูกปฏิเสธ)
        await db.promise().query(
          `UPDATE asset SET status = 1 WHERE id = ?`,
          [assetId]
        );
        db.query('UPDATE history SET approver_id = 3, reason = ? WHERE id = ?',[reason,id]);
        break; // ✅ ต้องมี break ตรงนี้!

      case 4: // Returned (คืนแล้ว)
        await db.promise().query(
          `UPDATE asset SET status = 1 WHERE id = ?`,
          [assetId]
        );
        db.query('UPDATE history SET approver_id = 3, approver_id = 2 WHERE id = ?',[id]);
        break; // ✅ ต้องมี break ตรงนี้ด้วย!

      case 5: // Expired (หมดอายุ)
        await db.promise().query(
          `UPDATE asset SET status = 1 WHERE id = ?`,
          [assetId]
        );
        break;

      default:
        console.warn(`⚠️ Unknown status: ${status}`);
    }


    res.json({ message: 'History and asset status updated successfully' });
  } catch (err) {
    console.error('❌ Update history status error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// =================== API Get All Pending Borrow Requests ===================
app.get('/borrow_requests', (req, res) => {
console.log('📩 API called: /borrow_requests (Pending)');

const sql = `
SELECT
h.id,
a.asset_name AS name,
u.name AS borrowerName,
h.borrow_date AS borrowDate,
h.reason AS reason,
h.return_date AS returnDate,a.img AS img ,
h.status
FROM history h
JOIN asset a ON h.asset_id = a.id
JOIN user u ON h.borrower_id = u.id
WHERE h.status = '1'
ORDER BY h.id ASC;
`;

db.query(sql, (err, results) => {
if (err) {
console.error('❌ Error fetching pending requests:', err);
return res.status(500).json({ error: 'Database query failed', details: err });
}

 console.log(`✅ Pending Requests Found: ${results.length} rows`);
res.json(results); // ส่งรายการกลับไปให้ Flutter
});
});

// =================== API Approve Request ===================
app.post('/borrow_requests/:id/approve', async (req, res) => {
  const historyId = req.params.id;
  const approverId = 3; // ❗ สมมติว่าเป็น ID ของผู้ดูแลที่ทำการอนุมัติ

  try {
    // 1. อัปเดตสถานะใน history เป็น Approved (2)
    await db.promise().query(
      `UPDATE history SET status = 2, approver_id = ? WHERE id = ?`,
      [approverId, historyId]
    );

    // 2. ดึง asset_id
    const [historyRows] = await db.promise().query(
      `SELECT asset_id FROM history WHERE id = ?`,
      [historyId]
    );
    if (historyRows.length === 0) {
      return res.status(404).json({ message: 'History record not found' });
    }
    const assetId = historyRows[0].asset_id;

    // 3. อัปเดตสถานะ asset เป็น Borrowed (4)
    await db.promise().query(
      `UPDATE asset SET status = 4 WHERE id = ?`,
      [assetId]
    );

    console.log(`✅ Request ${historyId} Approved.`);
    res.status(200).json({ message: 'Approved successfully' });
  } catch (err) {
    console.error('❌ Approve error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// =================== API Reject Request ===================
app.post('/borrow_requests/:id/reject', async (req, res) => {
  const historyId = req.params.id;
  const { approverId, reason } = req.body; // ✅ ดึง approverId และ reason จาก Request Body

  // ❗ ตรวจสอบ approverId ที่ถูกส่งมาจาก client (หรือใช้ค่าคงที่หากยังไม่ได้จัดการ Session)
  // const approverId = approverIdFromSession || 3; 

  try {
    // 1. อัปเดตสถานะใน history เป็น Rejected (3)
    // ✅ เพิ่มการอัปเดตคอลัมน์ reason ลงในตาราง history
    await db.promise().query(
      `UPDATE history SET status = 3, approver_id = ?, reason = ? WHERE id = ?`,
      [approverId, reason, historyId]
    );

    // 2. ดึง asset_id
    const [historyRows] = await db.promise().query(
      `SELECT asset_id FROM history WHERE id = ?`,
      [historyId]
    );
    if (historyRows.length === 0) {
      return res.status(404).json({ message: 'History record not found' });
    }
    const assetId = historyRows[0].asset_id;

    // 3. อัปเดตสถานะ asset กลับเป็น Available (1)
    await db.promise().query(
      `UPDATE asset SET status = 1 WHERE id = ?`,
      [assetId]
    );

    console.log(`❌ Request ${historyId} Rejected. Reason: ${reason}`);
    res.status(200).json({ message: 'Rejected successfully' });
  } catch (err) {
    console.error('❌ Reject error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.get("/api/dashboard-summary", async (req, res) => {
  try {
    // ✅ Query นับจำนวนแต่ละสถานะ
    const [rows] = await db.promise().query(`
      SELECT 
        SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS available,
        SUM(CASE WHEN status = 3 THEN 1 ELSE 0 END) AS pending,
        SUM(CASE WHEN status = 4 THEN 1 ELSE 0 END) AS borrowed,
        SUM(CASE WHEN status = 2 THEN 1 ELSE 0 END) AS disabled
      FROM asset
    `);

    const result = rows[0];
    console.log("📊 Dashboard summary:", result);

    res.json({
      available: result.available || 0,
      pending: result.pending || 0,
      borrowed: result.borrowed || 0,
      disabled: result.disabled || 0,
    });
  } catch (err) {
    console.error("❌ Dashboard summary error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.get('/show/return-asset', (req, res) => {
  // SQL Query:
  // 1. ดึงข้อมูลจาก history (h) ที่มี status = '2' (รอรับคืน) และกำหนดวันคืนเป็นวันนี้
  // 2. LEFT JOIN กับ asset (a) เพื่อดึง asset_name และ img
  // 3. LEFT JOIN กับ user (ub) เพื่อดึงชื่อผู้ยืม (borrower_name)
  // 4. LEFT JOIN กับ user (ua) เพื่อดึงชื่อผู้อนุมัติ (approver_name)
  const sql = `
    SELECT
      h.*,
      a.asset_name,
      a.img,
      ub.name AS borrower_name,
      ua.name AS approver_name
    
    FROM
      history h
    LEFT JOIN
      asset a ON h.asset_id = a.id
    LEFT JOIN
      user ub ON h.borrower_id = ub.id  -- JOIN สำหรับ Borrower
    LEFT JOIN
      user ua ON h.approver_id = ua.id  -- JOIN ใหม่สำหรับ Approver
    WHERE
      h.status = '2'
      AND DATE(h.return_date) = DATE(NOW());
  `;

  db.query(sql, (err, result) => {
    if (err) {
      console.error('Error fetching return assets with JOIN:', err);
      return res.status(500).json({ message: "Error database failure" });
    }
    // ผลลัพธ์ที่ได้จะมีฟิลด์: h.*, asset_name, img, borrower_name, และ approver_name
    res.status(200).json(result);
  });
});

app.put('/accept/return_asset/:id/:asset_id/:receiver_id', (req, res) => {
  const id = req.params.id; // ID ของ history
  const asset_id = req.params.asset_id;
  // 🎉 ดึง receiver_id จาก Params
  const receiver_id = req.params.receiver_id; 

  // SQL เพื่ออัปเดต history: status = '4' (คืนเรียบร้อย) และตั้งค่า receiver_id
  const updtHist = "UPDATE history SET status = '4', receiver_id = ? WHERE id = ?";
  
  // SQL เพื่ออัปเดต asset: status = 1 (พร้อมใช้งาน)
  const updtAsset = "UPDATE asset SET status = 1 WHERE id = ?";

  // 1. อัปเดต History ก่อน (status และ receiver_id)
  db.query(updtHist, [receiver_id, id], (err, result) => { 
    if (err) {
      console.error("Error updating history status/receiver_id:", err);
      // ส่ง Response Error กลับไปทันที
      return res.status(500).json({ 
        message: "Error updating history status/receiver_id", 
        error: err 
      });
    }

    // 2. ถ้า History อัปเดตสำเร็จ ให้ดำเนินการอัปเดต Asset ต่อ
    console.log("History status and receiver_id updated successfully. Proceeding to update asset status.");
    
    db.query(updtAsset, [asset_id], (err2, result2) => {
      if (err2) {
        console.error("Error updating asset status | Get Return Asset system:", err2);
        // ส่ง Response Error กลับไปทันที
        return res.status(500).json({ 
          message: "Error updating asset status | Get Return Asset system", 
          error: err2 
        });
      }

      // 3. ถ้าทุกอย่างสำเร็จ ให้ส่ง Response Success เพียงครั้งเดียว
      console.log("Asset return successfully accepted and asset status updated.");
      return res.status(200).json({ 
        message: "Asset return successfully accepted and asset status updated.",
        history_update: result,
        asset_update: result2
      });
    });
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


