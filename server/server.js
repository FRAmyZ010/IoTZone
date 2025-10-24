
const express = require('express');
const db = require('./db.js'); 
const bcrypt = require('bcrypt');

const app = express();


app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.get('/', (req, res) => {
  res.send('Server is running!');
});



const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
