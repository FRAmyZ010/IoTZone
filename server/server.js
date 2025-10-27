// วิธีรันเซิร์ฟ nodemon --watch server.js

const express = require('express');
const db = require('./db.js'); 
const bcrypt = require('bcrypt');

const app = express();


app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.post('/register',(req,res)=>{
  const {username, password, name, phone, email} = req.body;

  if(!username || !password){
    return res.status(400).json({message: 'Username and password are required'});
  }
  if(!name || !phone || !email){
    return res.status(400).json({message: 'Name, phone, and email are required'});
  }
  bcrypt.hash(password, 10, (err,hash)=>{
    if(err){
      console.error('Error hashing password:', err);
      return res.status(500).json({message: 'Internal server error'});
    }

    const sql = 'INSERT INTO user (username, password, name, phone, email ) VALUES (?, ?, ?, ?, ?)';
    db.query(sql,[username, hash, name, phone, email], (err,result)=>{
      if(err){
        if(err.code==='ER_DUP_ENTRY'){
          return  res.status(409).json({message: 'Username already exists'});
        }
        console.error('Database error:', err);
        return res.status(500).json({message: 'Internal server error'});
      }
      res.status(201).json({
        message:'User registered successfully',
        userId:result.insertId,
        username:username
      })
    })
  })
})
////////-------- Get all assets -----------////////
app.get('/assets', (req, res) => {
  const sql = 'SELECT * FROM asset';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('❌ Database error:', err);
      return res.status(500).json({ message: 'Internal server error' });
    }

    try {
      const formatted = results.map(row => ({
        id: row.id,
        name: row.asset_name || 'Unknown',
        description: row.description || '',
        type: row.type || 'Unknown',
        status: mapStatus(row.status ?? 0),
        image: `asset/img/${row.img || 'no_image.png'}`,
        statusColorValue: getColor(row.status ?? 0),
      }));

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
    case 1: return 'Available';
    case 2: return 'Disabled';
    case 3: return 'Pending';
    case 4: return 'Borrowed';
    default: return 'Unknown';
  }
}

// 🔹 กำหนดสีสถานะ
function getColor(code) {
  switch (Number(code)) {
    case 1: return 0xFF00FF00; // เขียว
    case 2: return 0xFFFF0000; // แดง
    case 3: return 0xFFFFA500; // ส้ม
    case 4: return 0xFF808080; // เทา
    default: return 0xFF000000;
  }
}


app.get('/', (req, res) => {
  res.send('Server is running!');
});



const PORT = 3000;
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});
