// Stub ML service - integrates with python/ml models in ml_models/ if needed
const path = require('path');

exports.predictDisease = async (imagePath) => {
  // Placeholder - call an external service or execute Python script
  // For now return a dummy prediction
  return {
    label: 'healthy',
    confidence: 0.95,
  };
};
