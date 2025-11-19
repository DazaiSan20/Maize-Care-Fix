import 'package:maizecare_frontend/data/models/api_response.dart';
import 'package:maizecare_frontend/data/models/soil_sensor.dart';
import 'package:maizecare_frontend/data/services/api_service.dart';

class SoilSensorRepository {
  final ApiService _apiService;

  SoilSensorRepository({required ApiService apiService})
      : _apiService = apiService;

  Future<ApiResponse> getLatestSensorData() async {
    try {
      final response = await _apiService.get('/soil-sensors/latest');
      if (response.success && response.data != null) {
        final soilSensor = SoilSensor.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse(
          success: true,
          message: response.message,
          data: soilSensor,
        );
      }
      return ApiResponse(
        success: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to fetch sensor data',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse> getAllSensorData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService
          .get('/soil-sensors?page=$page&limit=$limit');
      if (response.success && response.data != null) {
        final List<dynamic> dataList = (response.data as List<dynamic>?) ?? [];
        final List<SoilSensor> sensors = dataList
            .map((item) => SoilSensor.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          message: response.message.isNotEmpty ? response.message : 'Data fetched successfully',
          data: sensors,
        );
      }
      return ApiResponse(
        success: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to fetch sensor data',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse> getSensorDataByPlant(
    String plantId, {
    int days = 7,
  }) async {
    try {
      final response = await _apiService
          .get('/soil-sensors/plant/$plantId?days=$days');
      if (response.success && response.data != null) {
        final List<dynamic> dataList = (response.data as List<dynamic>?) ?? [];
        final List<SoilSensor> sensors = dataList
            .map((item) => SoilSensor.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          message: response.message.isNotEmpty ? response.message : 'Data fetched successfully',
          data: sensors,
        );
      }
      return ApiResponse(
        success: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to fetch sensor data',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse> recordSensorData({
    String? plantId,
    required int humidity,
    double? temperature,
    String? sensorId,
    String? location,
  }) async {
    try {
      if (humidity < 0 || humidity > 100) {
        return ApiResponse(
          success: false,
          message: 'Humidity must be between 0 and 100',
        );
      }

      final body = {
        'humidity': humidity,
        if (plantId != null) 'plantId': plantId,
        if (temperature != null) 'temperature': temperature,
        if (sensorId != null) 'sensorId': sensorId,
        if (location != null) 'location': location,
      };
      final response = await _apiService.post('/soil-sensors', body);
      if (response.success && response.data != null) {
        final soilSensor = SoilSensor.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse(
          success: true,
          message: response.message.isNotEmpty ? response.message : 'Data recorded successfully',
          data: soilSensor,
        );
      }
      return ApiResponse(
        success: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to record sensor data',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse> updateSensorData(
    String id, {
    int? humidity,
    double? temperature,
    String? location,
  }) async {
    try {
      final body = {
        if (humidity != null) 'humidity': humidity,
        if (temperature != null) 'temperature': temperature,
        if (location != null) 'location': location,
      };
      final response = await _apiService.put('/soil-sensors/$id', body);
      if (response.success && response.data != null) {
        final soilSensor = SoilSensor.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse(
          success: true,
          message: response.message.isNotEmpty ? response.message : 'Data updated successfully',
          data: soilSensor,
        );
      }
      return ApiResponse(
        success: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to update sensor data',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse> deleteSensorData(String id) async {
    try {
      final response = await _apiService.delete('/soil-sensors/$id');
      if (response.success) {
        return ApiResponse(
          success: true,
          message: response.message.isNotEmpty ? response.message : 'Data deleted successfully',
        );
      }
      return ApiResponse(
        success: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to delete sensor data',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }
}
