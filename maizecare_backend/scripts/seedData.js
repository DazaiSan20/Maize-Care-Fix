require('dotenv').config();
const mongoose = require('mongoose');
const Plant = require('../models/Plant');
const Disease = require('../models/Disease');
const Humidity = require('../models/Humidity');

const seedData = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('📦 Connected to MongoDB');

    // Clear existing data (optional - hapus jika tidak mau clear data lama)
    await Plant.deleteMany({});
    await Disease.deleteMany({});
    await Humidity.deleteMany({});
    console.log('🗑️  Cleared existing data');

    // Insert dummy plants
    const plants = await Plant.insertMany([
      { name: 'Jagung A', location: 'Blok 1', status: 'healthy', plantedAt: new Date('2025-01-01') },
      { name: 'Jagung B', location: 'Blok 1', status: 'healthy', plantedAt: new Date('2025-01-05') },
      { name: 'Jagung C', location: 'Blok 2', status: 'healthy', plantedAt: new Date('2025-01-10') },
      { name: 'Jagung D', location: 'Blok 2', status: 'sick', plantedAt: new Date('2025-01-15') },
      { name: 'Jagung E', location: 'Blok 3', status: 'healthy', plantedAt: new Date('2025-01-20') },
    ]);
    console.log('✅ Inserted', plants.length, 'plants');

    // Insert dummy diseases
    const diseases = await Disease.insertMany([
      { 
        plantId: plants[3]._id, // Jagung D yang sakit
        name: 'Leaf Blight',
        severity: 'medium',
        detectedAt: new Date()
      },
    ]);
    console.log('✅ Inserted', diseases.length, 'diseases');

    // Insert dummy humidity data (7 hari terakhir)
    const humidityData = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      humidityData.push({
        value: 60 + Math.floor(Math.random() * 20), // Random 60-80%
        recordedAt: date,
      });
    }
    const humidity = await Humidity.insertMany(humidityData);
    console.log('✅ Inserted', humidity.length, 'humidity records');

    console.log('🎉 Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
};

seedData();