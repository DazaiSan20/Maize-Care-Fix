const express = require('express');
const router = express.Router();
const notifCtrl = require('../controllers/notificationController');
const auth = require('../middlewares/auth');

router.get('/', auth, notifCtrl.list);
router.post('/:id/read', auth, notifCtrl.markRead);

module.exports = router;
