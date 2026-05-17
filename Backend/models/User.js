
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firstName:   { type: String, required: true },
  lastName:    { type: String, required: true },
  username:    { type: String, required: true, unique: true },
  email:       { type: String, required: true, unique: true },
  password:    { type: String, required: true },
  birthdate:   { type: Date },
  profilePhoto:{ type: String }, // URL or base64
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);