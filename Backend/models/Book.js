
const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  googleBookId: { type: String, unique: true },
  title:        { type: String, required: true },
  authors:      [String],
  description:  String,
  coverImage:   String,
  publishedDate:String,
  pageCount:    Number,
  categories:   [String],
  averageRating:Number,
}, { timestamps: true });

module.exports = mongoose.model('Book', bookSchema);