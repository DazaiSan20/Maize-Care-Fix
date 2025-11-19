require('dotenv').config();
const express = require('express');
const cors = require('cors');
const logger = require('./utils/logger');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');
const plantRoutes = require('./routes/plant');
const diseaseRoutes = require('./routes/disease');
const notificationRoutes = require('./routes/notification');
const dashboardRoutes = require('./routes/dashboard');
const soilSensorRoutes = require('./routes/soilSensor');
const errorHandler = require('./middlewares/errorHandler');

const app = express();

// Middlewares
app.use(cors({
  origin: true,
  methods: ['GET','POST','PUT','DELETE','OPTIONS'],
  allowedHeaders: ['Content-Type','Authorization','x-user-id'],
  exposedHeaders: ['Authorization'],
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API prefix
const apiPrefix = `/api/${process.env.API_VERSION || 'v1'}`;
app.use(`${apiPrefix}/auth`, authRoutes);
app.use(`${apiPrefix}/users`, userRoutes);
app.use(`${apiPrefix}/plants`, plantRoutes);
app.use(`${apiPrefix}/diseases`, diseaseRoutes);
app.use(`${apiPrefix}/notifications`, notificationRoutes);
app.use(`${apiPrefix}/dashboard`, dashboardRoutes);
app.use(`${apiPrefix}/soil-sensors`, soilSensorRoutes);

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));
// Static files (uploads)
app.use('/uploads', express.static('uploads'));
// Error handler (should be last)
app.use(errorHandler);

module.exports = app;
