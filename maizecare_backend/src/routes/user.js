const express = require('express');
const router = express.Router();
const userCtrl = require('../controllers/userController');
const auth = require('../middlewares/auth');

router.get('/:id', auth, userCtrl.getProfile);
router.put('/:id', auth, userCtrl.updateProfile);

module.exports = router;
