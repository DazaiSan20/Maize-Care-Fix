const Plant = require('../models/Plant');
const { success, error, notFound } = require('../utils/response');

exports.create = async (req, res) => {
  try {
    const payload = req.body;
    const plant = new Plant(payload);
    await plant.save();
    return success(res, { plant }, 'Plant created', 201);
  } catch (err) {
    return error(res, err.message);
  }
};

exports.list = async (req, res) => {
  try {
    const plants = await Plant.find().populate('owner', 'name email');
    return success(res, { plants });
  } catch (err) {
    return error(res, err.message);
  }
};

exports.get = async (req, res) => {
  try {
    const plant = await Plant.findById(req.params.id);
    if (!plant) return notFound(res, 'Plant not found');
    return success(res, { plant });
  } catch (err) {
    return error(res, err.message);
  }
};

exports.update = async (req, res) => {
  try {
    const plant = await Plant.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!plant) return notFound(res, 'Plant not found');
    return success(res, { plant }, 'Updated');
  } catch (err) {
    return error(res, err.message);
  }
};

exports.remove = async (req, res) => {
  try {
    const plant = await Plant.findByIdAndDelete(req.params.id);
    if (!plant) return notFound(res, 'Plant not found');
    return success(res, {}, 'Deleted');
  } catch (err) {
    return error(res, err.message);
  }
};
