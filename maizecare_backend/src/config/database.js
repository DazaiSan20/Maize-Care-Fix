const mongoose = require('mongoose');
const logger = require('../utils/logger');

const connectDB = async () => {
	const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/maizecare';
	try {
		await mongoose.connect(mongoUri);
		logger.info('✅ MongoDB connected');
	} catch (err) {
		logger.error(`❌ MongoDB connection error: ${err.message}`);
		process.exit(1);
	}
};

module.exports = connectDB;
