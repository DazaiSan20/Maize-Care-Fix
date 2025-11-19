const admin = require('../services/firebaseService');

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.header('authorization') || req.header('Authorization');

    // ===== Firebase Bearer Token =====
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const idToken = authHeader.split(' ')[1];
      try {
        const decoded = await admin.auth().verifyIdToken(idToken);
        req.userId = decoded.uid;
        req.user = decoded;
        return next();
      } catch (err) {
        return res.status(401).json({ success: false, message: 'Invalid or expired token' });
      }
    }

    // ===== Development fallback (x-user-id) =====
    const userId = req.header('x-user-id');
    if (userId) {
      req.userId = userId;
      req.user = { uid: userId }; // <-- FIX PENTING
      return next();
    }

    return res.status(401).json({ success: false, message: 'Unauthorized: No token provided' });
  } catch (err) {
    next(err);
  }
};
