const mongoose = require('mongoose');

const cacheSchema = new mongoose.Schema({
  userId:          { type: mongoose.Schema.Types.ObjectId, unique: true },
  recommendations: Array,
  reason:          String,
  updatedAt:       { type: Date, default: Date.now }
});

module.exports = mongoose.model('RecommendCache', cacheSchema);