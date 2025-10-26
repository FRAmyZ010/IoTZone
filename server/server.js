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


app.get('/', (req, res) => {
  res.send('Server is running!');
});



const PORT = 3000;
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});
