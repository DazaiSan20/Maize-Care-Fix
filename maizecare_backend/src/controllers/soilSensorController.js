const SoilSensor = require('../models/SoilSensor');
const response = require('../utils/response');
const logger = require('../utils/logger');

// Dapatkan data soil sensor terbaru
exports.getLatestSensorData = async (req, res) => {
  try {
    const { userId } = req;
    const data = await SoilSensor.findOne({ userId }).sort({ recordedAt: -1 });
    if (!data) {
      return response.notFound(res, 'Sensor data tidak ditemukan');
    }
    response.success(res, data, 'Sensor data berhasil diambil');
  } catch (error) {
    logger.error('Error getting sensor data:', error);
    response.error(res, error.message, 500);
  }
};

// Dapatkan semua data soil sensor dengan pagination
exports.getAllSensorData = async (req, res) => {
  try {
    const { userId } = req;
    const { page = 1, limit = 10 } = req.query;
    const skip = (page - 1) * limit;

    const total = await SoilSensor.countDocuments({ userId });
    const data = await SoilSensor.find({ userId })
      .sort({ recordedAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    response.success(res, {
      data,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit),
      },
    }, 'Data sensor berhasil diambil');
  } catch (error) {
    logger.error('Error getting all sensor data:', error);
    response.error(res, error.message, 500);
  }
};

// Dapatkan data soil sensor untuk plant tertentu
exports.getSensorDataByPlant = async (req, res) => {
  try {
    const { userId } = req;
    const { plantId } = req.params;
    const { days = 7 } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const data = await SoilSensor.find({
      userId,
      plantId,
      recordedAt: { $gte: startDate },
    }).sort({ recordedAt: 1 });

    response.success(res, data, 'Data sensor untuk plant berhasil diambil');
  } catch (error) {
    logger.error('Error getting sensor data by plant:', error);
    response.error(res, error.message, 500);
  }
};

// Catat data soil sensor baru
exports.recordSensorData = async (req, res) => {
  try {
    const { userId } = req;
    const { plantId, humidity, temperature, sensorId, location } = req.body;

    if (!humidity || humidity < 0 || humidity > 100) {
      return response.error(res, 'Kelembaban harus antara 0-100', 400);
    }

    const soilSensor = new SoilSensor({
      userId,
      plantId,
      humidity,
      temperature,
      sensorId,
      location,
    });

    await soilSensor.save();
    response.success(res, soilSensor, 'Data sensor berhasil disimpan', 201);
  } catch (error) {
    logger.error('Error recording sensor data:', error);
    response.error(res, error.message, 500);
  }
};

// Update data soil sensor
exports.updateSensorData = async (req, res) => {
  try {
    const { userId } = req;
    const { id } = req.params;
    const { humidity, temperature, location } = req.body;

    const soilSensor = await SoilSensor.findOne({ _id: id, userId });
    if (!soilSensor) {
      return response.notFound(res, 'Sensor data tidak ditemukan');
    }

    if (humidity !== undefined) {
      if (humidity < 0 || humidity > 100) {
        return response.error(res, 'Kelembaban harus antara 0-100', 400);
      }
      soilSensor.humidity = humidity;
    }
    if (temperature !== undefined) soilSensor.temperature = temperature;
    if (location !== undefined) soilSensor.location = location;
    soilSensor.updatedAt = new Date();

    await soilSensor.save();
    response.success(res, soilSensor, 'Data sensor berhasil diperbarui');
  } catch (error) {
    logger.error('Error updating sensor data:', error);
    response.error(res, error.message, 500);
  }
};

// Hapus data soil sensor
exports.deleteSensorData = async (req, res) => {
  try {
    const { userId } = req;
    const { id } = req.params;

    const soilSensor = await SoilSensor.findOneAndDelete({ _id: id, userId });
    if (!soilSensor) {
      return response.notFound(res, 'Sensor data tidak ditemukan');
    }

    response.success(res, null, 'Data sensor berhasil dihapus');
  } catch (error) {
    logger.error('Error deleting sensor data:', error);
    response.error(res, error.message, 500);
  }
};
