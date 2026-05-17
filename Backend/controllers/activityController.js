const UserActivity = require('../models/UserActivity');

// POST /api/activity/track
exports.trackActivity = async (req, res) => {
  const { bookId, googleBookId, timeSpent, searchQuery, categories, authors, action } = req.body;
  try {
    const existing = await UserActivity.findOne({ userId: req.user.id, bookId });
    if (existing) {
      existing.timeSpent += timeSpent || 0;
      await existing.save();
      return res.json(existing);
    }
    const activity = await UserActivity.create({
      userId: req.user.id,
      bookId, googleBookId,
      timeSpent: timeSpent || 0,
      searchQuery, categories, authors,
      action: action || 'view'
    });
    res.json(activity);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/activity/my
exports.getMyActivity = async (req, res) => {
  try {
    const activities = await UserActivity.find({ userId: req.user.id })
      .populate('bookId')
      .sort({ timeSpent: -1 })
      .limit(20);
    res.json(activities);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};