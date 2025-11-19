const express = require('express');
const router = express.Router();
const diseaseCtrl = require('../controllers/diseaseController');
const auth = require('../middlewares/auth');
const upload = require('../middlewares/upload');

// ========================================
// FIXED ROUTE PREDICT - SUPPORT 'file' FIELD
// ========================================
// Middleware order:
// 1. auth → validate user is authenticated
// 2. upload.single('file') → Flutter mengirim field 'file'
// 3. diseaseCtrl.predict → process prediction
// ========================================
router.post(
  '/predict',
  auth,
  upload.single('file'),  // ✅ Changed from dynamic to fixed 'file'
  diseaseCtrl.predict
);

// ========================================
// GET ALL DISEASES
// ========================================
router.get('/', auth, diseaseCtrl.list);

// ========================================
// GET DISEASE DETAIL
// ========================================
router.get('/:id', auth, diseaseCtrl.detail);

module.exports = router;