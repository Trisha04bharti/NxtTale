const router  = require('express').Router();
const auth    = require('../middleware/auth');
const { getMe, updateProfile } = require('../controllers/userController');

router.get('/me',      auth, getMe);
router.put('/profile', auth, updateProfile);

module.exports = router;
