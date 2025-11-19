const express = require('express');
const router = express.Router();
const plantCtrl = require('../controllers/plantController');
const auth = require('../middlewares/auth');

router.post('/', auth, plantCtrl.create);
router.get('/', auth, plantCtrl.list);
router.get('/:id', auth, plantCtrl.get);
router.put('/:id', auth, plantCtrl.update);
router.delete('/:id', auth, plantCtrl.remove);

module.exports = router;
