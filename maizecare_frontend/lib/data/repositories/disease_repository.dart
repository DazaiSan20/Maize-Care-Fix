import '../services/api_service.dart';
import '../models/api_response.dart';

class DiseaseRepository {
	final ApiService api = ApiService();

	Future<ApiResponse> list() async => await api.get('/diseases');

	Future<ApiResponse> get(String id) async => await api.get('/diseases/$id');
}
