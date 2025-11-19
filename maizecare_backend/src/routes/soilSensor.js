const express = require('express');
const router = express.Router();
const soilSensorController = require('../controllers/soilSensorController');
const auth = require('../middlewares/auth');

// Semua endpoint memerlukan authentikasi
router.use(auth);

// GET /api/v1/soil-sensors/latest - Dapatkan data sensor terbaru
router.get('/latest', soilSensorController.getLatestSensorData);

// GET /api/v1/soil-sensors - Dapatkan semua data sensor dengan pagination
router.get('/', soilSensorController.getAllSensorData);

// GET /api/v1/soil-sensors/plant/:plantId - Dapatkan data sensor untuk plant tertentu
router.get('/plant/:plantId', soilSensorController.getSensorDataByPlant);

// POST /api/v1/soil-sensors - Catat data sensor baru
router.post('/', soilSensorController.recordSensorData);

// PUT /api/v1/soil-sensors/:id - Update data sensor
router.put('/:id', soilSensorController.updateSensorData);

// DELETE /api/v1/soil-sensors/:id - Hapus data sensor
router.delete('/:id', soilSensorController.deleteSensorData);

module.exports = router;
