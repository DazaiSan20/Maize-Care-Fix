// Load environment variables
process.env.NODE_ENV = process.env.NODE_ENV || 'development';
process.env.PORT = process.env.PORT || 5000;
process.env.API_VERSION = process.env.API_VERSION || 'v1';
process.env.MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/maizecare';

// Initialize Firebase admin SDK early
require('./src/services/firebaseService');
const app = require('./src/app');
const connectDB = require('./src/config/database');
const logger = require('./src/utils/logger');

const PORT = process.env.PORT || 5000;

// Connect to MongoDB
connectDB();

// Start server on all interfaces (0.0.0.0) for network access
const server = app.listen(PORT, '0.0.0.0', () => {
  const os = require('os');
  const networkInterfaces = os.networkInterfaces();
  let ipAddresses = [];
  
  for (const name of Object.keys(networkInterfaces)) {
    for (const iface of networkInterfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        ipAddresses.push(iface.address);
      }
    }
  }
  
  logger.info(`🚀 Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
  logger.info(`📡 API available at http://localhost:${PORT}/api/${process.env.API_VERSION}`);
  logger.info(`🌐 Network IPs: ${ipAddresses.join(', ')}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  logger.error(`❌ Unhandled Rejection: ${err.message}`);
  server.close(() => process.exit(1));
});

// Handle SIGTERM
process.on('SIGTERM', () => {
  logger.info('👋 SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('💤 Process terminated');
  });
});

module.exports = server;