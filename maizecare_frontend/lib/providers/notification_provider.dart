import 'package:flutter/foundation.dart';
import '../data/repositories/notification_repository.dart';
import '../data/models/notification_model.dart';
import '../data/models/api_response.dart';

class NotificationProvider with ChangeNotifier {
	final NotificationRepository _repo = NotificationRepository();

	List<NotificationModel> _notifications = [];
	bool _isLoading = false;
	String? _error;

	List<NotificationModel> get notifications => _notifications;
	bool get isLoading => _isLoading;
	String? get error => _error;

	Future<void> fetchNotifications() async {
		_isLoading = true;
		_error = null;
		notifyListeners();

		try {
			final ApiResponse res = await _repo.list();
			if (res.success) {
				final payload = res.data;
				List items = [];
				if (payload is Map && payload['notifications'] != null) items = List.from(payload['notifications']);
				else if (payload is List) items = payload;

				_notifications = items.map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e))).toList();
			} else {
				_error = res.message;
			}
		} catch (e) {
			_error = e.toString();
		} finally {
			_isLoading = false;
			notifyListeners();
		}
	}

	Future<ApiResponse> markRead(String id) async {
		_isLoading = true;
		notifyListeners();
		try {
			final res = await _repo.markRead(id);
			if (res.success) await fetchNotifications();
			return res;
		} finally {
			_isLoading = false;
			notifyListeners();
		}
	}
}

