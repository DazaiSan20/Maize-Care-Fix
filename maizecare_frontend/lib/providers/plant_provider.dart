import 'package:flutter/foundation.dart';
import '../data/repositories/plant_repository.dart';
import '../data/models/plant_model.dart';
import '../data/models/api_response.dart';

class PlantProvider with ChangeNotifier {
	final PlantRepository _repo = PlantRepository();

	List<PlantModel> _plants = [];
	bool _isLoading = false;
	String? _error;

	List<PlantModel> get plants => _plants;
	bool get isLoading => _isLoading;
	String? get error => _error;

	Future<void> fetchPlants() async {
		_isLoading = true;
		_error = null;
		notifyListeners();

		try {
			final ApiResponse res = await _repo.list();
			if (res.success) {
				final payload = res.data;
				List items = [];
				if (payload is Map && payload['plants'] != null) items = List.from(payload['plants']);
				else if (payload is List) items = payload;

				_plants = items.map((e) => PlantModel.fromJson(Map<String, dynamic>.from(e))).toList();
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

	Future<ApiResponse> createPlant(Map<String, dynamic> payload) async {
		_isLoading = true;
		notifyListeners();
		try {
			final res = await _repo.create(payload);
			if (res.success) await fetchPlants();
			return res;
		} finally {
			_isLoading = false;
			notifyListeners();
		}
	}

	Future<ApiResponse> updatePlant(String id, Map<String, dynamic> payload) async {
		_isLoading = true;
		notifyListeners();
		try {
			final res = await _repo.update(id, payload);
			if (res.success) await fetchPlants();
			return res;
		} finally {
			_isLoading = false;
			notifyListeners();
		}
	}

	Future<ApiResponse> deletePlant(String id) async {
		_isLoading = true;
		notifyListeners();
		try {
			final res = await _repo.delete(id);
			if (res.success) await fetchPlants();
			return res;
		} finally {
			_isLoading = false;
			notifyListeners();
		}
	}
}

