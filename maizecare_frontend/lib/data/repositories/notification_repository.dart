import '../services/api_service.dart';
import '../models/api_response.dart';

class NotificationRepository {
  final ApiService _api = ApiService();

  // Get notifications dengan filter optional
  Future<ApiResponse> getNotifications({String? filter}) async {
    try {
      String endpoint = '/notifications';
      if (filter != null && filter.isNotEmpty && filter != 'all') {
        endpoint += '?filter=$filter';
      }
      return await _api.get(endpoint);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Mark single notification as read
  Future<ApiResponse> markAsRead(String id) async {
    try {
      return await _api.post('/notifications/$id/read', {});
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Mark all notifications as read
  Future<ApiResponse> markAllAsRead() async {
    try {
      return await _api.post('/notifications/read-all', {});
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Delete single notification
  Future<ApiResponse> deleteNotification(String id) async {
    try {
      return await _api.delete('/notifications/$id');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Delete all notifications
  Future<ApiResponse> deleteAllNotifications() async {
    try {
      return await _api.delete('/notifications/all');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Get unread count
  Future<ApiResponse> getUnreadCount() async {
    try {
      return await _api.get('/notifications/unread-count');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }
}