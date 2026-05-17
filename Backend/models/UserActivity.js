
const mongoose = require('mongoose');

const userActivitySchema = new mongoose.Schema({
  userId:        { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  bookId:        { type: mongoose.Schema.Types.ObjectId, ref: 'Book', required: true },
  googleBookId:  String,
  timeSpent:     { type: Number, default: 0 }, // seconds
  searchQuery:   String,
  categories:    [String],
  authors:       [String],
  action:        { type: String, enum: ['view', 'search', 'bookmark'], default: 'view' },
}, { timestamps: true });

module.exports = mongoose.model('UserActivity', userActivitySchema);