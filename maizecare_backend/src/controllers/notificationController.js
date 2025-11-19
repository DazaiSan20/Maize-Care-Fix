const Notification = require('../models/Notification');
const { success, error, notFound } = require('../utils/response');

exports.list = async (req, res) => {
  try {
    const notifs = await Notification.find().populate('user', 'name email').sort({ createdAt: -1 });
    return success(res, { notifications: notifs });
  } catch (err) {
    return error(res, err.message);
  }
};

exports.markRead = async (req, res) => {
  try {
    const notif = await Notification.findByIdAndUpdate(req.params.id, { isRead: true }, { new: true });
    if (!notif) return notFound(res, 'Notification not found');
    return success(res, { notification: notif }, 'Marked as read');
  } catch (err) {
    return error(res, err.message);
  }
};
