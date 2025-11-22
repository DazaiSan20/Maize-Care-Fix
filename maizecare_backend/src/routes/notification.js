const express = require('express');
const router = express.Router();
const notifCtrl = require('../controllers/notificationController');
const auth = require('../middlewares/auth');

// ⚠️ PENTING: Urutan route matters! Route yang lebih spesifik harus di atas

// ========================================
// GET ENDPOINTS
// ========================================

// Get unread count (harus SEBELUM GET /)
router.get('/unread-count', auth, notifCtrl.getUnreadCount);

// Get all notifications for logged in user
router.get('/', auth, notifCtrl.list);

// ========================================
// POST ENDPOINTS
// ========================================

// Mark all notifications as read (harus SEBELUM POST /:id/read)
router.post('/read-all', auth, notifCtrl.markAllRead);

// Mark single notification as read
router.post('/:id/read', auth, notifCtrl.markRead);

// ✅ NEW: Create test notification (for testing/debugging)
router.post('/test', auth, notifCtrl.createTest);

// ========================================
// DELETE ENDPOINTS
// ========================================

// Delete all notifications (harus SEBELUM DELETE /:id)
router.delete('/all', auth, notifCtrl.deleteAll);

// Delete single notification
router.delete('/:id', auth, notifCtrl.deleteOne);
router.post('/seed/dummy', auth, notifCtrl.seedDummyData);
router.get('/stats', auth, notifCtrl.getStats);
router.delete('/clear/all', auth, notifCtrl.clearAll);

module.exports = router;