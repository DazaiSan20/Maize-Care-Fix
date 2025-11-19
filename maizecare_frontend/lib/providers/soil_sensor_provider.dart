import 'package:flutter/material.dart';
import 'package:maizecare_frontend/data/models/soil_sensor.dart';
import 'package:maizecare_frontend/data/repositories/soil_sensor_repository.dart';
import 'package:maizecare_frontend/data/services/api_service.dart';

class SoilSensorProvider with ChangeNotifier {
  final SoilSensorRepository _repository = SoilSensorRepository(
    apiService: ApiService(),
  );

  SoilSensor? _latestSensorData;
  List<SoilSensor> _sensorDataHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  SoilSensor? get latestSensorData => _latestSensorData;
  List<SoilSensor> get sensorDataHistory => _sensorDataHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch latest sensor data
  Future<void> fetchLatestSensorData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _repository.getLatestSensorData();
    if (response.success) {
      _latestSensorData = response.data as SoilSensor?;
      _error = null;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch all sensor data with pagination
  Future<void> fetchAllSensorData({
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _repository.getAllSensorData(
      page: page,
      limit: limit,
    );
    if (response.success) {
      _sensorDataHistory = response.data as List<SoilSensor>? ?? [];
      _error = null;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch sensor data for specific plant
  Future<void> fetchSensorDataByPlant(
    String plantId, {
    int days = 7,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _repository.getSensorDataByPlant(
      plantId,
      days: days,
    );
    if (response.success) {
      _sensorDataHistory = response.data as List<SoilSensor>? ?? [];
      _error = null;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Record new sensor data
  Future<bool> recordSensorData({
    String? plantId,
    required int humidity,
    double? temperature,
    String? sensorId,
    String? location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _repository.recordSensorData(
      plantId: plantId,
      humidity: humidity,
      temperature: temperature,
      sensorId: sensorId,
      location: location,
    );

    if (response.success) {
      _latestSensorData = response.data as SoilSensor?;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update sensor data
  Future<bool> updateSensorData(
    String id, {
    int? humidity,
    double? temperature,
    String? location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _repository.updateSensorData(
      id,
      humidity: humidity,
      temperature: temperature,
      location: location,
    );

    if (response.success) {
      _latestSensorData = response.data as SoilSensor?;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete sensor data
  Future<bool> deleteSensorData(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _repository.deleteSensorData(id);

    if (response.success) {
      _sensorDataHistory.removeWhere((item) => item.id == id);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
