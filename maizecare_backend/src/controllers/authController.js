const User = require('../models/User');
const { success, error } = require('../utils/response');
const admin = require('../services/firebaseService');
const logger = require('../utils/logger');

/**
 * Register: Create user in Firebase and sync to MongoDB
 * Expected body: { email, password, name }
 * Returns: { user, token }
 */
exports.register = async (req, res) => {
  try {
    const { email, password, name } = req.body;
    
    if (!email || !password || !name) {
      return error(res, 'Email, password, and name are required', 400);
    }

    // Check if user already exists in MongoDB
    let existingUser = await User.findOne({ email });
    if (existingUser) {
      return error(res, 'Email already registered', 400);
    }

    // Create user in Firebase
    const firebaseUser = await admin.auth().createUser({
      email,
      password,
      displayName: name,
    });

    // Create user in MongoDB
    const newUser = new User({
      uid: firebaseUser.uid,
      email,
      name,
      photoURL: firebaseUser.photoURL || null,
    });
    await newUser.save();

    // Generate ID token
    const token = await admin.auth().createCustomToken(firebaseUser.uid);

    logger.info(`✅ User registered: ${email}`);
    return success(res, { user: newUser, token }, 'User registered successfully', 201);
  } catch (err) {
    logger.error(`❌ Register error: ${err.message}`);
    return error(res, err.message, 400);
  }
};

/**
 * Login: Verify Firebase token and return user
 * Expected body: { idToken } (from Firebase Client)
 * Or header: Authorization: Bearer <idToken>
 * Returns: { user }
 */
exports.login = async (req, res) => {
  try {
    let idToken = req.body.idToken;
    
    // Alternative: get from Authorization header
    if (!idToken && req.headers.authorization) {
      idToken = req.headers.authorization.replace('Bearer ', '');
    }

    if (!idToken) {
      logger.warn('❌ Login error: No ID token provided');
      return error(res, 'ID token required', 400);
    }

    logger.info(`🔍 Verifying token...`);
    // Verify Firebase token
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;
    logger.info(`✅ Token verified for UID: ${uid}`);

    // Find or create user in MongoDB
    let user = await User.findOne({ uid });
    
    if (!user) {
      // First time login - create user in MongoDB
      logger.info(`👤 New user detected, creating in MongoDB...`);
      const firebaseUser = await admin.auth().getUser(uid);
      user = new User({
        uid,
        email: firebaseUser.email,
        name: firebaseUser.displayName || firebaseUser.email.split('@')[0],
        photoURL: firebaseUser.photoURL || null,
      });
      await user.save();
      logger.info(`✅ New user created: ${firebaseUser.email}`);
    } else {
      logger.info(`✅ Existing user found: ${user.email}`);
    }

    return success(res, { user }, 'Logged in successfully');
  } catch (err) {
    logger.error(`❌ Login error: ${err.message}`);
    return error(res, err.message, 401);
  }
};

/**
 * Get current user profile
 * Requires: Authorization header with Bearer token
 */
exports.getProfile = async (req, res) => {
  try {
    const userId = req.userId; // Set by auth middleware
    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    const user = await User.findById(userId);
    if (!user) {
      return error(res, 'User not found', 404);
    }

    return success(res, { user }, 'Profile retrieved');
  } catch (err) {
    logger.error(`❌ Get profile error: ${err.message}`);
    return error(res, err.message);
  }
};

/**
 * Update user profile
 */
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.userId;
    if (!userId) {
      return error(res, 'User not authenticated', 401);
    }

    const { name, photoURL } = req.body;
    
    const user = await User.findByIdAndUpdate(
      userId,
      { name, photoURL },
      { new: true, runValidators: true }
    );

    if (!user) {
      return error(res, 'User not found', 404);
    }

    logger.info(`✅ User profile updated: ${user.email}`);
    return success(res, { user }, 'Profile updated');
  } catch (err) {
    logger.error(`❌ Update profile error: ${err.message}`);
    return error(res, err.message);
  }
};
