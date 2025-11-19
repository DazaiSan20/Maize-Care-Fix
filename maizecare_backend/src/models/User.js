const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  uid: { type: String, unique: true, sparse: true }, // Firebase UID
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String }, // Only for local auth (optional)
  photoURL: { type: String, default: null },
  role: { type: String, default: 'user', enum: ['user', 'admin', 'farmer'] },
  phone: { type: String, default: null },
  location: { type: String, default: null },
  bio: { type: String, default: null },
  isActive: { type: Boolean, default: true },
  lastLogin: { type: Date, default: null },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

// Update updatedAt before saving
UserSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('User', UserSchema);
