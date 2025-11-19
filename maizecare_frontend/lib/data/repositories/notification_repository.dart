import '../services/api_service.dart';
import '../models/api_response.dart';

class NotificationRepository {
	final ApiService api = ApiService();

	Future<ApiResponse> list() async => await api.get('/notifications');

	Future<ApiResponse> markRead(String id) async => await api.post('/notifications/$id/read', {});
}
