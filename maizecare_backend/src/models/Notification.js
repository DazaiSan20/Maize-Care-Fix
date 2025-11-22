const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    // ✅ FIXED: Accept both Firebase UID (string) dan MongoDB ObjectId
    user: {
      type: mongoose.Schema.Types.Mixed, // Allow string (Firebase UID) and ObjectId
      required: true,
      index: true
    },
    title: {
      type: String,
      required: true,
      trim: true
    },
    content: {
      type: String,
      required: true
    },
    type: {
      type: String,
      enum: ['success', 'warning', 'danger', 'info'],
      default: 'info'
    },
    isRead: {
      type: Boolean,
      default: false,
      index: true
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {}
    }
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// ✅ Index untuk query yang sering digunakan (penting untuk performance)
notificationSchema.index({ user: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ user: 1, createdAt: -1 });

// Virtual untuk mendapatkan waktu relatif
notificationSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diff = now - this.createdAt;
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);
  
  if (days > 0) return `${days} hari yang lalu`;
  if (hours > 0) return `${hours} jam yang lalu`;
  if (minutes > 0) return `${minutes} menit yang lalu`;
  return 'Baru saja';
});

module.exports = mongoose.model('Notification', notificationSchema);