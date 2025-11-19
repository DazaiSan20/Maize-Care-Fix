const mongoose = require('mongoose');

const soilSensorSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  plantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Plant',
    required: false,
  },
  humidity: {
    type: Number,
    required: true,
    min: 0,
    max: 100,
  },
  temperature: {
    type: Number,
    required: false,
  },
  sensorId: {
    type: String,
    required: false,
  },
  location: {
    type: String,
    required: false,
  },
  recordedAt: {
    type: Date,
    default: Date.now,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('SoilSensor', soilSensorSchema);
