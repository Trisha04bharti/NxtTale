
const UserActivity    = require('../models/UserActivity');
const { userCache }   = require('./cache');              // ← from shared file

exports.trackActivity = async (req, res) => {
  const { bookId, googleBookId, timeSpent, searchQuery, categories, authors, action } = req.body;
  try {
    const activity = await UserActivity.findOneAndUpdate(
      { userId: req.user.id, bookId },
      {
        $inc: { timeSpent: timeSpent || 0 },
        $set: {
          googleBookId,
          searchQuery,
          categories,
          authors,
          action:    action || 'view',
          updatedAt: new Date()
        }
      },
      { upsert: true, returnDocument: 'after' }
    );

    userCache.delete(req.user.id);                       // ← bust cache
    console.log(`🗑️  Cache cleared for user ${req.user.id}`);

    res.json(activity);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getMyActivity = async (req, res) => {
  try {
    const activities = await UserActivity.find({ userId: req.user.id })
      .populate('bookId')
      .sort({ updatedAt: -1 })
      .limit(20)
      .lean();
    res.json(activities);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};