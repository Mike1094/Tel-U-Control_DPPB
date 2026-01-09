import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// API Service for HTTP requests with authentication
class ApiService {
  static String? _token;
  
  /// Get stored token
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }
  
  /// Set token
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  /// Clear token on logout
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  /// Get headers with authentication
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  /// GET request
  static Future<dynamic> get(String endpoint, {bool withAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(withAuth: withAuth);
      
      final response = await http.get(uri, headers: headers)
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Tidak dapat terhubung ke server: ${e.message}');
    } on TimeoutException {
      throw Exception('Koneksi timeout, coba lagi');
    } on HandshakeException catch (e) {
      throw Exception('SSL Error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal terhubung: $e');
    }
  }
  
  /// POST request
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool withAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(withAuth: withAuth);
      
      final response = await http.post(
        uri, 
        headers: headers,
        body: jsonEncode(data),
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Tidak dapat terhubung ke server: ${e.message}');
    } on TimeoutException {
      throw Exception('Koneksi timeout, coba lagi');
    } on HandshakeException catch (e) {
      throw Exception('SSL Error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal terhubung: $e');
    }
  }
  
  /// PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data, {bool withAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(withAuth: withAuth);
      
      final response = await http.put(
        uri, 
        headers: headers,
        body: jsonEncode(data),
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Tidak dapat terhubung ke server: ${e.message}');
    } on TimeoutException {
      throw Exception('Koneksi timeout, coba lagi');
    } on HandshakeException catch (e) {
      throw Exception('SSL Error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal terhubung: $e');
    }
  }
  
  /// DELETE request
  static Future<dynamic> delete(String endpoint, {bool withAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(withAuth: withAuth);
      
      final response = await http.delete(uri, headers: headers)
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Tidak dapat terhubung ke server: ${e.message}');
    } on TimeoutException {
      throw Exception('Koneksi timeout, coba lagi');
    } on HandshakeException catch (e) {
      throw Exception('SSL Error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal terhubung: $e');
    }
  }
  
  /// POST with multipart (for file upload)
  static Future<dynamic> postMultipart(
    String endpoint, 
    Map<String, String> data, 
    {File? file, String fileField = 'foto'}
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final token = await getToken();
      
      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields.addAll(data);
      
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
      }
      
      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Tidak dapat terhubung ke server: ${e.message}');
    } on TimeoutException {
      throw Exception('Koneksi timeout, coba lagi');
    } on HandshakeException catch (e) {
      throw Exception('SSL Error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal terhubung: $e');
    }
  }
  
  /// Handle HTTP response
  static dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      throw Exception('Server error: ${response.statusCode} - ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      clearToken();
      throw Exception('Sesi telah berakhir, silakan login ulang');
    } else if (response.statusCode == 404) {
      throw Exception('API endpoint tidak ditemukan (404)');
    } else if (response.statusCode == 422) {
      // Validation error
      final errors = body['errors'];
      if (errors != null && errors is Map) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first);
        }
      }
      throw Exception(body['message'] ?? 'Validasi gagal');
    } else if (response.statusCode == 500) {
      throw Exception('Server error (500): ${body['message'] ?? 'Internal server error'}');
    } else {
      throw Exception(body['message'] ?? 'Error ${response.statusCode}');
    }
  }
}
