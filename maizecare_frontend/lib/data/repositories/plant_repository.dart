import '../services/api_service.dart';
import '../models/api_response.dart';

class PlantRepository {
	final ApiService api = ApiService();

	Future<ApiResponse> create(Map<String, dynamic> payload) async {
		return await api.post('/plants', payload);
	}

	Future<ApiResponse> list() async {
		return await api.get('/plants');
	}

	Future<ApiResponse> get(String id) async {
		return await api.get('/plants/$id');
	}

	Future<ApiResponse> update(String id, Map<String, dynamic> payload) async {
		return await api.put('/plants/$id', payload);
	}

	Future<ApiResponse> delete(String id) async {
		return await api.delete('/plants/$id');
	}
}

