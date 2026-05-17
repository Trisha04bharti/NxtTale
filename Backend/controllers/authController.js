const User    = require('../models/User');
const bcrypt  = require('bcryptjs');
const jwt     = require('jsonwebtoken');

const generateToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });

// POST /api/auth/signup
exports.signup = async (req, res) => {
  const { firstName, lastName, username, email, password } = req.body;
  try {
    if (await User.findOne({ $or: [{ email }, { username }] }))
      return res.status(400).json({ message: 'Email or username already exists' });

    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({ firstName, lastName, username, email, password: hashed });

    res.status(201).json({
      token: generateToken(user._id),
      user: {
        _id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        username: user.username,
        email: user.email
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST /api/auth/login
exports.login = async (req, res) => {
  const { identifier, password } = req.body;
  try {
    const user = await User.findOne({
      $or: [{ email: identifier }, { username: identifier }]
    });

    if (!user || !(await bcrypt.compare(password, user.password)))
      return res.status(401).json({ message: 'Invalid credentials' });

    res.json({
      token: generateToken(user._id),
      user: {
        _id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        username: user.username,
        email: user.email,
        birthdate: user.birthdate,
        profilePhoto: user.profilePhoto
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};