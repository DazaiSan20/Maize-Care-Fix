const express = require('express');
const router = express.Router();
const dashCtrl = require('../controllers/dashboardController');
const auth = require('../middlewares/auth');

router.get('/', auth, dashCtrl.stats);
router.post('/seed', dashCtrl.seedData);
module.exports = router;
