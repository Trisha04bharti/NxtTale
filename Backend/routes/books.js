const router = require('express').Router();
const { getFeed, searchBooks } = require('../controllers/bookController');
const auth = require('../middleware/auth');

router.get('/feed',   auth, getFeed);
router.get('/search', auth, searchBooks);

module.exports = router;