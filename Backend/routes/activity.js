const router = require('express').Router();
const auth   = require('../middleware/auth');
const { trackActivity, getMyActivity } = require('../controllers/activityController');

router.post('/track', auth, trackActivity);
router.get('/my',     auth, getMyActivity);

module.exports = router;