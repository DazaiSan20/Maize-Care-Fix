const mongoose = require('mongoose');

const HumiditySchema = new mongoose.Schema({
  plant: { type: mongoose.Schema.Types.ObjectId, ref: 'Plant' },
  value: { type: Number, required: true },
  recordedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Humidity', HumiditySchema);
