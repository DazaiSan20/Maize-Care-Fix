const express = require('express');
const router = express.Router();
const auth = require('../controllers/authController');
const authMiddleware = require('../middlewares/auth');

router.post('/register', auth.register);
router.post('/login', auth.login);
router.get('/profile', authMiddleware, auth.getProfile);
router.put('/profile', authMiddleware, auth.updateProfile);

module.exports = router;
