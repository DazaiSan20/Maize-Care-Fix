const Disease = require('../models/Disease');
const { success, error } = require('../utils/response');
const fs = require('fs');
const path = require('path');

// ================================================
// PREDICT DISEASE
// ================================================
exports.predict = async (req, res) => {
  try {
    console.log('🔍 /predict called');

    if (!req.user) {
      console.log("❌ req.user undefined");
      return error(res, 'User not authenticated', 401);
    }

    if (!req.file) {
      console.log("❌ No file uploaded");
      return error(res, 'No image file uploaded', 400);
    }

    console.log('📁 File uploaded:', req.file.filename);

    // Dummy model simulate prediction
    const predictions = [
      {
        disease: 'Healthy',
        confidence: 0.92,
        description: 'Daun jagung sehat.',
        recommendations: [
          'Lanjutkan perawatan rutin',
          'Monitor kelembaban tanah',
          'Berikan nutrisi secara teratur'
        ]
      },
      {
        disease: 'Common Rust',
        confidence: 0.85,
        description: 'Terdeteksi gejala Common Rust.',
        recommendations: [
          'Aplikasikan fungisida',
          'Tingkatkan sirkulasi udara',
          'Buang daun yang terinfeksi'
        ]
      },
      {
        disease: 'Gray Leaf Spot',
        confidence: 0.78,
        description: 'Terdeteksi Gray Leaf Spot.',
        recommendations: [
          'Gunakan varietas tahan penyakit',
          'Rotasi tanaman',
          'Aplikasikan fungisida preventif'
        ]
      },
      {
        disease: 'Northern Leaf Blight',
        confidence: 0.88,
        description: 'Northern Leaf Blight terdeteksi.',
        recommendations: [
          'Aplikasikan fungisida sistemik',
          'Tingkatkan drainase',
          'Kurangi kelembaban'
        ]
      }
    ];

    // Pick random prediction
    const prediction = predictions[Math.floor(Math.random() * predictions.length)];

    // Save to MongoDB
    const diseaseRecord = await Disease.create({
      name: prediction.disease,
      severity: prediction.confidence > 0.8 ? 'high' : 'medium',
      detectedAt: new Date(),
      imagePath: req.file.path,
      confidence: prediction.confidence,
      userId: req.user._id,
    });

    console.log('✅ Prediction saved:', diseaseRecord._id);

    return success(
      res,
      {
        disease: prediction.disease,
        confidence: prediction.confidence,
        description: prediction.description,
        recommendations: prediction.recommendations,
        diseaseId: diseaseRecord._id,
        imageUrl: `/uploads/${req.file.filename}`
      },
      'Prediction successful',
      201
    );

  } catch (err) {
    console.error('❌ Prediction error:', err);

    // Delete uploaded image safely
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }

    return error(res, 'Prediction failed: ' + err.message, 500);
  }
};

// ================================================
// LIST DISEASES
// ================================================
exports.list = async (req, res) => {
  try {
    if (!req.user) {
      return error(res, 'User not authenticated', 401);
    }

    const diseases = await Disease.find({ userId: req.user._id })
      .sort({ detectedAt: -1 })
      .limit(20);

    return success(res, diseases);
  } catch (err) {
    console.error('❌ List error:', err);
    return error(res, 'Failed to load disease history', 500);
  }
};

// ================================================
// DISEASE DETAIL
// ================================================
exports.detail = async (req, res) => {
  try {
    if (!req.user) {
      return error(res, 'User not authenticated', 401);
    }

    const disease = await Disease.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!disease) {
      return error(res, 'Disease not found', 404);
    }

    return success(res, disease);
  } catch (err) {
    console.error('❌ Detail error:', err);
    return error(res, 'Failed to fetch disease detail', 500);
  }
};