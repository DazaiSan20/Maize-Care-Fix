const mongoose = require('mongoose');
const { Schema } = mongoose;

const diseaseSchema = new Schema({
  name: { type: String, required: true },
  severity: { type: String, enum: ['low', 'medium', 'high'], default: 'medium' },
  detectedAt: { type: Date, default: Date.now },
  imagePath: String,
  confidence: Number,
  userId: { type: Schema.Types.ObjectId, ref: 'User' },
  plantId: { type: Schema.Types.ObjectId, ref: 'Plant' },
}, { timestamps: true });

module.exports = mongoose.model('Disease', diseaseSchema);