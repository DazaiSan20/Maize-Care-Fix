const admin = require('../services/firebaseService');

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.header('authorization') || req.header('Authorization');

    // ===== Firebase Bearer Token =====
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const idToken = authHeader.split(' ')[1];
      try {
        const decoded = await admin.auth().verifyIdToken(idToken);
        
        // ✅ Set multiple properties untuk compatibility dengan controller
        // Controller expect: req.user._id ATAU req.user.id
        req.userId = decoded.uid; // Firebase UID string
        req.user = {
          _id: decoded.uid,      // ✅ Controller gunakan ini
          id: decoded.uid,       // ✅ Controller gunakan ini juga
          uid: decoded.uid,      // ✅ For reference
          email: decoded.email,
          name: decoded.name || decoded.email?.split('@')[0],
          ...decoded
        };
        
        console.log('✅ Firebase auth success:', {
          uid: req.user._id,
          email: req.user.email
        });
        return next();
      } catch (err) {
        console.error('❌ Firebase token verification failed:', err.message);
        return res.status(401).json({ 
          success: false, 
          message: 'Invalid or expired token',
          statusCode: 401
        });
      }
    }

    // ===== Development fallback (x-user-id) =====
    const userId = req.header('x-user-id');
    if (userId) {
      req.userId = userId;
      req.user = { 
        _id: userId,           // ✅ Controller compatible
        id: userId,            // ✅ Controller compatible
        uid: userId,
        email: `dev_${userId}@test.com`,
        name: `Dev User ${userId}`
      };
      console.log('⚠️ Dev mode with x-user-id:', userId);
      return next();
    }

    console.error('❌ No authorization provided');
    return res.status(401).json({ 
      success: false, 
      message: 'User not authenticated',
      statusCode: 401
    });
  } catch (err) {
    console.error('❌ Auth middleware error:', err);
    return res.status(500).json({
      success: false,
      message: 'Authentication failed',
      statusCode: 500
    });
  }
};