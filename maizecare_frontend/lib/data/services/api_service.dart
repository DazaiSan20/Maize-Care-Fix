import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

class ApiService {
  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  // Backend URL - use 192.168.0.84 for physical device on local network
  // For Android emulator, use http://10.0.2.2:5000
  final String baseUrl;

  // Shared auth token (set after login)
  static String? _authToken;

  // Backend URL - use 192.168.0.85 for WiFi network (both phone and laptop)
  // Physical device IP: 192.168.0.85 (WiFi)
  // Emulator IP: 10.0.2.2
  ApiService._internal({String? baseUrl}) : baseUrl = baseUrl ?? 'http://172.16.103.117:5000/api/v1';

  factory ApiService({String? baseUrl}) {
    if (baseUrl != null) {
      return ApiService._internal(baseUrl: baseUrl);
    }
    return _instance;
  }

  static ApiService get instance => _instance;

  // ✅ GETTER untuk auth token
  static String? getAuthToken() {
    return _authToken;
  }

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers([Map<String, String>? extra]) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  // Instance methods
  Future<ApiResponse> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri, headers: _headers());
    return _fromHttpResponse(res);
  }

  Future<ApiResponse> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(uri, body: jsonEncode(body), headers: _headers());
    return _fromHttpResponse(res);
  }

  Future<ApiResponse> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.put(uri, body: jsonEncode(body), headers: _headers());
    return _fromHttpResponse(res);
  }

  Future<ApiResponse> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.delete(uri, headers: _headers());
    return _fromHttpResponse(res);
  }

  // Static convenience methods
  static Future<ApiResponse> staticGet(String path) => _instance.get(path);
  static Future<ApiResponse> staticPost(String path, Map<String, dynamic> body) => _instance.post(path, body);
  static Future<ApiResponse> staticPut(String path, Map<String, dynamic> body) => _instance.put(path, body);
  static Future<ApiResponse> staticDelete(String path) => _instance.delete(path);

  ApiResponse _fromHttpResponse(http.Response res) {
    try {
      final jsonBody = jsonDecode(res.body);
      return ApiResponse.fromJson(jsonBody);
    } catch (e) {
      return ApiResponse(success: false, message: 'Invalid response from server: ${res.statusCode}');
    }
  }
}