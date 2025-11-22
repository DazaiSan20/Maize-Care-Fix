import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  // Backend URL
  // Physical device on WiFi: 192.168.0.85
  // Android emulator: 10.0.2.2
  // iOS simulator: localhost or your machine IP
  final String baseUrl;

  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Debug mode
  static const bool enableLogging = true;

  // Constructor
  ApiService._internal({String? baseUrl}) 
      : baseUrl = baseUrl ?? 'http://192.168.0.85:5000/api/v1';

  factory ApiService({String? baseUrl}) {
    if (baseUrl != null) {
      return ApiService._internal(baseUrl: baseUrl);
    }
    return _instance;
  }

  static ApiService get instance => _instance;

  // ==================== AUTH TOKEN MANAGEMENT ====================

  // Get Firebase auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check multiple possible keys
      String? token = prefs.getString('firebase_token') ?? 
                     prefs.getString('idToken') ??
                     prefs.getString('token') ?? 
                     prefs.getString('auth_token');
      
      if (enableLogging) {
        if (token != null && token.isNotEmpty) {
          print('✅ Token found: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
        } else {
          print('⚠️ No token found in storage');
        }
      }
      
      return token;
    } catch (e) {
      if (enableLogging) {
        print('❌ Error getting token: $e');
      }
      return null;
    }
  }

  // Set auth token (for immediate use without waiting for SharedPreferences)
  static String? _cachedToken;
  
  static void setAuthToken(String? token) {
    _cachedToken = token;
  }

  static String? getAuthToken() {
    return _cachedToken;
  }

  // ==================== HEADERS ====================

  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? extra,
    bool includeAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      // Try cached token first, then SharedPreferences
      String? token = _cachedToken ?? await _getAuthToken();
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (extra != null) {
      headers.addAll(extra);
    }

    return headers;
  }

  // ==================== ERROR HANDLING ====================

  ApiResponse _handleError(dynamic error, {int? statusCode}) {
    String message = 'Terjadi kesalahan';
    int code = statusCode ?? 500;

    if (error is SocketException) {
      message = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      code = 503;
    } else if (error is http.ClientException) {
      message = 'Koneksi ke server gagal';
      code = 503;
    } else if (error is FormatException) {
      message = 'Format data tidak valid';
      code = 422;
    } else if (error is TimeoutException) {
      message = 'Koneksi timeout. Server tidak merespon.';
      code = 408;
    } else {
      message = error.toString();
    }

    if (enableLogging) {
      print('❌ API Error ($code): $message');
    }

    return ApiResponse(
      success: false,
      message: message,
      statusCode: code,
    );
  }

  // Parse HTTP response to ApiResponse
  ApiResponse _parseResponse(http.Response response) {
    try {
      if (enableLogging) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Handle empty response
      if (response.body.isEmpty) {
        return ApiResponse(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: response.statusCode >= 200 && response.statusCode < 300
              ? 'Success'
              : 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final jsonData = json.decode(response.body);

      return ApiResponse(
        success: jsonData['success'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonData['message']?.toString(),
        data: jsonData['data'],
        statusCode: jsonData['statusCode'] ?? response.statusCode,
      );
    } catch (e) {
      if (enableLogging) {
        print('❌ Error parsing response: $e');
      }
      return ApiResponse(
        success: false,
        message: 'Error parsing response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  // ==================== HTTP METHODS ====================

  // GET request
  Future<ApiResponse> get(String path, {bool requiresAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _buildHeaders(includeAuth: requiresAuth);

      if (enableLogging) {
        print('GET: $uri');
        print('Headers: $headers');
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(timeoutDuration);

      return _parseResponse(response);
    } catch (e) {
      if (enableLogging) {
        print('❌ GET Error: $e');
      }
      return _handleError(e);
    }
  }

  // POST request
  Future<ApiResponse> post(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _buildHeaders(includeAuth: requiresAuth);

      if (enableLogging) {
        print('POST: $uri');
        print('Headers: $headers');
        print('Body: ${json.encode(body)}');
      }

      final response = await http
          .post(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      return _parseResponse(response);
    } catch (e) {
      if (enableLogging) {
        print('❌ POST Error: $e');
      }
      return _handleError(e);
    }
  }

  // PUT request
  Future<ApiResponse> put(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _buildHeaders(includeAuth: requiresAuth);

      if (enableLogging) {
        print('PUT: $uri');
        print('Headers: $headers');
        print('Body: ${json.encode(body)}');
      }

      final response = await http
          .put(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      return _parseResponse(response);
    } catch (e) {
      if (enableLogging) {
        print('❌ PUT Error: $e');
      }
      return _handleError(e);
    }
  }

  // PATCH request
  Future<ApiResponse> patch(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _buildHeaders(includeAuth: requiresAuth);

      if (enableLogging) {
        print('PATCH: $uri');
        print('Headers: $headers');
        print('Body: ${json.encode(body)}');
      }

      final response = await http
          .patch(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      return _parseResponse(response);
    } catch (e) {
      if (enableLogging) {
        print('❌ PATCH Error: $e');
      }
      return _handleError(e);
    }
  }

  // DELETE request
  Future<ApiResponse> delete(String path, {bool requiresAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _buildHeaders(includeAuth: requiresAuth);

      if (enableLogging) {
        print('DELETE: $uri');
        print('Headers: $headers');
      }

      final response = await http
          .delete(uri, headers: headers)
          .timeout(timeoutDuration);

      return _parseResponse(response);
    } catch (e) {
      if (enableLogging) {
        print('❌ DELETE Error: $e');
      }
      return _handleError(e);
    }
  }

  // ==================== STATIC CONVENIENCE METHODS ====================

  static Future<ApiResponse> staticGet(String path, {bool requiresAuth = true}) {
    return _instance.get(path, requiresAuth: requiresAuth);
  }

  static Future<ApiResponse> staticPost(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) {
    return _instance.post(path, body, requiresAuth: requiresAuth);
  }

  static Future<ApiResponse> staticPut(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) {
    return _instance.put(path, body, requiresAuth: requiresAuth);
  }

  static Future<ApiResponse> staticPatch(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) {
    return _instance.patch(path, body, requiresAuth: requiresAuth);
  }

  static Future<ApiResponse> staticDelete(String path, {bool requiresAuth = true}) {
    return _instance.delete(path, requiresAuth: requiresAuth);
  }

  // ==================== UTILITY METHODS ====================

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      final response = await get('/health', requiresAuth: false)
          .timeout(const Duration(seconds: 5));
      return response.success;
    } catch (e) {
      if (enableLogging) {
        print('❌ Connection test failed: $e');
      }
      return false;
    }
  }

  // Print current configuration
  static void printConfig() {
    print('=== ApiService Configuration ===');
    print('Base URL: ${_instance.baseUrl}');
    print('Timeout: ${timeoutDuration.inSeconds}s');
    print('Logging: $enableLogging');
    print('Cached Token: ${_cachedToken != null ? "Yes" : "No"}');
    print('===============================');
  }
}