const User = require('../models/User');
const { success, error, notFound } = require('../utils/response');

exports.getProfile = async (req, res) => {
  try {
    const userId = req.params.id || req.userId;
    const user = await User.findById(userId).select('-password');
    if (!user) return notFound(res, 'User not found');
    return success(res, { user });
  } catch (err) {
    return error(res, err.message);
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const userId = req.params.id || req.userId;
    const payload = req.body;
    const user = await User.findByIdAndUpdate(userId, payload, { new: true }).select('-password');
    if (!user) return notFound(res, 'User not found');
    return success(res, { user }, 'Profile updated');
  } catch (err) {
    return error(res, err.message);
  }
};
