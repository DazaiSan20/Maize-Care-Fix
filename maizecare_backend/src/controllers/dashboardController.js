const Plant = require('../models/Plant');
const Disease = require('../models/Disease');
const Humidity = require('../models/Humidity');
const { success, error } = require('../utils/response');

// Function untuk GET /api/v1/dashboard
exports.stats = async (req, res) => {
  try {
    console.log('🔥 Dashboard stats requested');
    
    const totalPlants = await Plant.countDocuments();
    const totalDiseases = await Disease.countDocuments();
    const healthyPlants = totalPlants - totalDiseases;
    
    // Ambil humidity terbaru
    const latestHumidity = await Humidity.findOne().sort({ recordedAt: -1 });
    
    // Get user name (jika ada auth)
    const userName = req.user?.name || req.user?.email || 'Owner';
    
    const responseData = {
      user_name: userName,
      total_plants: totalPlants,
      healthy_plants: healthyPlants > 0 ? healthyPlants : 0,
      sick_plants: totalDiseases,
      humidity: latestHumidity?.value || 0, // ← PERBAIKAN: pakai 'value' bukan 'humidity'
      plants: totalPlants,
      diseases: totalDiseases,
      latestHumidity: latestHumidity
    };
    
    console.log('✅ Dashboard response:', responseData);
    return success(res, responseData);
    
  } catch (err) {
    console.error('❌ Dashboard error:', err);
    return error(res, err.message);
  }
};

// Function untuk POST /api/v1/dashboard/seed
exports.seedData = async (req, res) => {
  try {
    console.log('🌱 Seeding database...');

    // Clear existing data
    await Plant.deleteMany({});
    await Disease.deleteMany({});
    await Humidity.deleteMany({});
    console.log('🗑️  Cleared old data');

    // Insert dummy plants
    const plants = await Plant.insertMany([
      { 
        name: 'Jagung A', 
        location: 'Blok 1', 
        status: 'healthy', 
        plantedAt: new Date('2025-01-01') 
      },
      { 
        name: 'Jagung B', 
        location: 'Blok 1', 
        status: 'healthy', 
        plantedAt: new Date('2025-01-05') 
      },
      { 
        name: 'Jagung C', 
        location: 'Blok 2', 
        status: 'healthy', 
        plantedAt: new Date('2025-01-10') 
      },
      { 
        name: 'Jagung D', 
        location: 'Blok 2', 
        status: 'sick', 
        plantedAt: new Date('2025-01-15') 
      },
      { 
        name: 'Jagung E', 
        location: 'Blok 3', 
        status: 'healthy', 
        plantedAt: new Date('2025-01-20') 
      },
    ]);
    console.log(`✅ Inserted ${plants.length} plants`);

    // Insert dummy disease
    const diseases = await Disease.insertMany([
      { 
        plantId: plants[3]._id, 
        name: 'Leaf Blight',
        severity: 'medium',
        detectedAt: new Date()
      }
    ]);
    console.log(`✅ Inserted ${diseases.length} diseases`);

    // Insert dummy humidity data (7 days)
    const humidityData = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      humidityData.push({
        value: 60 + Math.floor(Math.random() * 20), // ← PERBAIKAN: pakai 'value'
        recordedAt: date,
      });
    }
    const humidity = await Humidity.insertMany(humidityData);
    console.log(`✅ Inserted ${humidity.length} humidity records`);

    console.log('🎉 Database seeded successfully!');

    return success(res, {
      message: 'Database seeded successfully!',
      plants: plants.length,
      diseases: diseases.length,
      humidity: humidity.length
    });

  } catch (err) {
    console.error('❌ Seed error:', err);
    return error(res, err.message, 500);
  }
};