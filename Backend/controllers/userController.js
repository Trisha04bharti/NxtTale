
const User = require('../models/User');

// GET /api/user/me
exports.getMe = async (req, res) => {
  const user = await User.findById(req.user.id).select('-password');
  res.json(user);
};

// PUT /api/user/profile
exports.updateProfile = async (req, res) => {
  const { birthdate, profilePhoto } = req.body;
  const user = await User.findByIdAndUpdate(
    req.user.id,
    { birthdate, profilePhoto },
    { new: true }
  ).select('-password');
  res.json(user);
};