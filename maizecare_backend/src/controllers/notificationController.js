const Notification = require('../models/Notification');

// Helper response functions
const success = (res, data = null, message = 'Success', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    statusCode
  });
};

const error = (res, message = 'Internal Server Error', statusCode = 500) => {
  return res.status(statusCode).json({
    success: false,
    message,
    data: null,
    statusCode
  });
};

const notFound = (res, message = 'Not Found') => {
  return res.status(404).json({
    success: false,
    message,
    data: null,
    statusCode: 404
  });
};

// ✅ Helper: Get user ID dari berbagai format
const getUserId = (req) => {
  return req.user?._id || req.user?.id || req.user?.uid || req.userId;
};

// Get all notifications
exports.list = async (req, res) => {
  try {
    const { filter } = req.query;
    const userId = getUserId(req); // ✅ Use helper

    if (!userId) {
      console.log('❌ No user ID found in request');
      return error(res, 'User not authenticated', 401);
    }

    console.log('📢 Fetching notifications for user:', userId);
    
    let query = { user: userId };
    
    if (filter === 'unread') {
      query.isRead = false;
    } else if (filter === 'read') {
      query.isRead = true;
    }
    
    const notifs = await Notification.find(query)
      .sort({ createdAt: -1 })
      .lean();
    
    console.log(`📢 Found ${notifs.length} notifications`);
    
    return success(res, { notifications: notifs });
  } catch (err) {
    console.error('❌ Error fetching notifications:', err);
    return error(res, err.message, 500);
  }
};

// Mark single notification as read
exports.markRead = async (req, res) => {
  try {
    const userId = getUserId(req); // ✅ Use helper

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    console.log('📢 Marking notification as read:', {
      notifId: req.params.id,
      userId: userId
    });

    const notif = await Notification.findOneAndUpdate(
      { _id: req.params.id, user: userId },
      { isRead: true },
      { new: true }
    );
    
    if (!notif) {
      console.log('❌ Notification not found');
      return notFound(res, 'Notification not found');
    }
    
    console.log('✅ Notification marked as read');
    return success(res, { notification: notif }, 'Marked as read');
  } catch (err) {
    console.error('❌ Error marking notification as read:', err);
    return error(res, err.message, 500);
  }
};

// Mark all notifications as read
exports.markAllRead = async (req, res) => {
  try {
    const userId = getUserId(req); // ✅ Use helper

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    console.log('📢 Marking all notifications as read for user:', userId);
    
    const result = await Notification.updateMany(
      { user: userId, isRead: false },
      { isRead: true }
    );
    
    console.log(`✅ Updated ${result.modifiedCount} notifications`);
    
    return success(res, { 
      modifiedCount: result.modifiedCount 
    }, 'All notifications marked as read');
  } catch (err) {
    console.error('❌ Error marking all as read:', err);
    return error(res, err.message, 500);
  }
};

// Delete single notification
exports.deleteOne = async (req, res) => {
  try {
    const userId = getUserId(req); // ✅ Use helper

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    console.log('📢 Deleting notification:', {
      notifId: req.params.id,
      userId: userId
    });

    const notif = await Notification.findOneAndDelete({
      _id: req.params.id,
      user: userId
    });
    
    if (!notif) {
      console.log('❌ Notification not found');
      return notFound(res, 'Notification not found');
    }
    
    console.log('✅ Notification deleted');
    return success(res, null, 'Notification deleted');
  } catch (err) {
    console.error('❌ Error deleting notification:', err);
    return error(res, err.message, 500);
  }
};

// Delete all notifications
exports.deleteAll = async (req, res) => {
  try {
    const userId = getUserId(req); // ✅ Use helper

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    console.log('📢 Deleting all notifications for user:', userId);
    
    const result = await Notification.deleteMany({ user: userId });
    
    console.log(`✅ Deleted ${result.deletedCount} notifications`);
    
    return success(res, { 
      deletedCount: result.deletedCount 
    }, 'All notifications deleted');
  } catch (err) {
    console.error('❌ Error deleting all notifications:', err);
    return error(res, err.message, 500);
  }
};

// Get unread count
exports.getUnreadCount = async (req, res) => {
  try {
    const userId = getUserId(req); // ✅ Use helper

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    console.log('📢 Getting unread count for user:', userId);

    const count = await Notification.countDocuments({
      user: userId,
      isRead: false
    });
    
    console.log(`📢 Unread count: ${count}`);
    
    return success(res, { count });
  } catch (err) {
    console.error('❌ Error getting unread count:', err);
    return error(res, err.message, 500);
  }
};

// ✅ NEW: Create test notification (for testing)
exports.createTest = async (req, res) => {
  try {
    const userId = getUserId(req);

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    console.log('📢 Creating test notification for user:', userId);

    const notif = await Notification.create({
      user: userId,
      title: 'Test Notification',
      content: 'Ini adalah notifikasi test dari server. Berhasil terhubung ke backend!',
      type: 'info',
      isRead: false
    });

    console.log('✅ Test notification created:', notif._id);

    return success(res, { notification: notif }, 'Test notification created', 201);
  } catch (err) {
    console.error('❌ Error creating test notification:', err);
    return error(res, err.message, 500);
  }
};
const DUMMY_NOTIFICATIONS = [
  {
    title: 'Kelembaban Terlalu Tinggi',
    content: 'Kelembaban tanah mencapai 85%. Segera lakukan tindakan untuk mengurangi kelembaban.\n\nTanggal: 08 Nov 2025, 14:30\nSuhu: 28°C, Kelembaban tanah: 85%',
    type: 'warning',
    isRead: false,
  },
  {
    title: 'Penyakit Terdeteksi!',
    content: 'Penyakit daun jagung terdeteksi pada pemeriksaan terakhir.\n\nTanggal: 08 Nov 2025, 10:15\nPenyakit: Common Rust\nTingkat: Sedang',
    type: 'danger',
    isRead: false,
  },
  {
    title: 'Rekomendasi Perawatan',
    content: 'Tanaman kurang sehat. Disarankan untuk melakukan pemupukan dan penyiraman yang lebih teratur.',
    type: 'info',
    isRead: false,
  },
  {
    title: 'Pemeriksaan Berhasil',
    content: 'Pemeriksaan daun jagung telah selesai. Semua tanaman dalam kondisi sehat.',
    type: 'success',
    isRead: true,
  },
  {
    title: 'Suhu Melebihi Batas',
    content: 'Suhu udara mencapai 32°C. Ini melebihi batas ideal untuk pertumbuhan jagung (28-30°C).',
    type: 'warning',
    isRead: true,
  },
  {
    title: 'Nutrisi Tanah Rendah',
    content: 'Kadar nitrogen dalam tanah terdeteksi rendah. Lakukan pemupukan nitrogen dalam 3-5 hari ke depan.',
    type: 'warning',
    isRead: true,
  },
  {
    title: 'Penyiraman Berhasil',
    content: 'Penyiraman tanaman telah selesai dilakukan. Total air yang diberikan: 50mm.',
    type: 'success',
    isRead: true,
  },
  {
    title: 'Peringatan: Hama Terdeteksi',
    content: 'Hama penggerek batang (stem borer) terdeteksi di area tanaman. Segera ambil tindakan pengendalian.',
    type: 'danger',
    isRead: true,
  },
  {
    title: 'Jadwal Pemupukan',
    content: 'Jadwal pemupukan berkala sudah tiba. Direkomendasikan untuk melakukan pemupukan NPK minggu ini.',
    type: 'info',
    isRead: true,
  },
  {
    title: 'Monitoring Rutin',
    content: 'Waktu monitoring rutin telah tiba. Lakukan pemeriksaan tanaman dan catat kondisi terkini.',
    type: 'info',
    isRead: true,
  },
  {
    title: 'Kelembaban Optimal',
    content: 'Kondisi kelembaban tanah saat ini optimal (60-70%) untuk pertumbuhan jagung. Pertahankan kondisi ini.',
    type: 'success',
    isRead: false,
  },
  {
    title: 'Penyakit Terkontrol',
    content: 'Penyakit yang sebelumnya terdeteksi sudah terkontrol dengan baik setelah dilakukan penyemprotan fungisida.',
    type: 'success',
    isRead: false,
  },
];

// ================================================
// SEED DUMMY NOTIFICATIONS
// ================================================
exports.seedDummyData = async (req, res) => {
  try {
    const userId = getUserId(req);

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    console.log('🌱 Seeding dummy notifications for user:', userId);

    // Delete existing notifications for this user
    const deleteResult = await Notification.deleteMany({ user: userId });
    console.log(`🗑️ Deleted ${deleteResult.deletedCount} existing notifications`);

    // Create notifications with varied timestamps (1 hour apart, newest first)
    const notificationsToCreate = DUMMY_NOTIFICATIONS.map((notif, index) => ({
      ...notif,
      user: userId,
      createdAt: new Date(Date.now() - (index * 3600000)), // 1 hour apart
      updatedAt: new Date(Date.now() - (index * 3600000)),
    }));

    const created = await Notification.insertMany(notificationsToCreate);

    console.log(`✅ Created ${created.length} dummy notifications`);

    // Calculate statistics
    const stats = {
      total: created.length,
      byType: {},
      byRead: { read: 0, unread: 0 }
    };

    created.forEach((notif) => {
      stats.byType[notif.type] = (stats.byType[notif.type] || 0) + 1;
      stats.byRead[notif.isRead ? 'read' : 'unread']++;
    });

    return success(
      res,
      {
        notifications: created,
        stats
      },
      `✅ Successfully seeded ${created.length} dummy notifications!`,
      201
    );
  } catch (err) {
    console.error('❌ Error seeding dummy data:', err);
    return error(res, 'Failed to seed dummy data: ' + err.message, 500);
  }
};

// ================================================
// CLEAR ALL NOTIFICATIONS (DEVELOPMENT ONLY)
// ================================================
exports.clearAll = async (req, res) => {
  try {
    const userId = getUserId(req);

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    // Optional: Add check untuk hanya allow di development
    if (process.env.NODE_ENV === 'production') {
      return error(res, 'This endpoint is not available in production', 403);
    }

    console.log('🗑️ Clearing all notifications for user:', userId);

    const result = await Notification.deleteMany({ user: userId });

    console.log(`✅ Deleted ${result.deletedCount} notifications`);

    return success(
      res,
      { deletedCount: result.deletedCount },
      `Cleared ${result.deletedCount} notifications`
    );
  } catch (err) {
    console.error('❌ Error clearing notifications:', err);
    return error(res, 'Failed to clear notifications: ' + err.message, 500);
  }
};

// ================================================
// GET STATISTICS
// ================================================
exports.getStats = async (req, res) => {
  try {
    const userId = getUserId(req);

    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    console.log('📊 Getting notification stats for user:', userId);

    const total = await Notification.countDocuments({ user: userId });
    const unread = await Notification.countDocuments({ user: userId, isRead: false });
    const read = await Notification.countDocuments({ user: userId, isRead: true });

    const byType = {};
    const notifications = await Notification.find({ user: userId }).select('type');
    notifications.forEach((notif) => {
      byType[notif.type] = (byType[notif.type] || 0) + 1;
    });

    const stats = {
      total,
      read,
      unread,
      byType
    };

    console.log('📊 Stats:', stats);

    return success(res, stats);
  } catch (err) {
    console.error('❌ Error getting stats:', err);
    return error(res, 'Failed to get stats: ' + err.message, 500);
  }
};