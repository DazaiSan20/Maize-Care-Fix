import 'package:flutter/foundation.dart';
import '../data/repositories/notification_repository.dart';
import '../data/models/notification_model.dart';
import '../data/models/api_response.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  // Fetch notifications dengan filter
  Future<void> fetchNotifications({String? filter}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ApiResponse res = await _repo.getNotifications(filter: filter);

      if (res.success) {
        final payload = res.data;
        List items = [];

        if (payload is Map && payload['notifications'] != null) {
          items = List.from(payload['notifications']);
        } else if (payload is List) {
          items = payload;
        }

        _notifications = items
            .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        // Update unread count
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      } else {
        // Check for authentication error using helper method or statusCode
        if (res.isUnauthorized || res.statusCode == 401) {
          _error = 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (res.isForbidden) {
          _error = 'Anda tidak memiliki akses ke fitur ini.';
        } else if (res.isServerError) {
          _error = 'Terjadi kesalahan di server. Silakan coba lagi nanti.';
        } else {
          _error = res.message ?? 'Gagal memuat notifikasi';
        }
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark single notification as read
  Future<bool> markAsRead(String id) async {
    try {
      final res = await _repo.markAsRead(id);

      if (res.success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _unreadCount = _notifications.where((n) => !n.isRead).length;
          notifyListeners();
        }
        return true;
      }
      
      // Handle auth error
      if (res.isUnauthorized) {
        _error = 'Sesi Anda telah berakhir. Silakan login kembali.';
        notifyListeners();
      }
      
      return false;
    } catch (e) {
      debugPrint('Error marking as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _repo.markAllAsRead();

      if (res.success) {
        // Update local state
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _unreadCount = 0;
        return true;
      }
      
      // Handle auth error
      if (res.isUnauthorized) {
        _error = 'Sesi Anda telah berakhir. Silakan login kembali.';
      }
      
      return false;
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete single notification
  Future<bool> deleteNotification(String id) async {
    try {
      final res = await _repo.deleteNotification(id);

      if (res.success) {
        _notifications.removeWhere((n) => n.id == id);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
        return true;
      }
      
      // Handle auth error
      if (res.isUnauthorized) {
        _error = 'Sesi Anda telah berakhir. Silakan login kembali.';
        notifyListeners();
      }
      
      return false;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  // Delete all notifications
  Future<bool> deleteAllNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _repo.deleteAllNotifications();

      if (res.success) {
        _notifications.clear();
        _unreadCount = 0;
        return true;
      }
      
      // Handle auth error
      if (res.isUnauthorized) {
        _error = 'Sesi Anda telah berakhir. Silakan login kembali.';
      }
      
      return false;
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get unread count from server
  Future<void> fetchUnreadCount() async {
    try {
      final res = await _repo.getUnreadCount();

      if (res.success && res.data != null) {
        _unreadCount = res.data['count'] ?? 0;
        notifyListeners();
      } else if (res.isUnauthorized) {
        _error = 'Sesi Anda telah berakhir. Silakan login kembali.';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}