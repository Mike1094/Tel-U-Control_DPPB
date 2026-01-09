import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'settings_service.dart';

/// Authentication service for login/logout
class AuthService {
  /// Login user with email and password
  static Future<User> login(String email, String password) async {
    final response = await ApiService.post(
      ApiConfig.login,
      {
        'email': email,
        'password': password,
      },
      withAuth: false,
    );
    
    // Laravel response format: { success: true, data: { user: {...}, token: "..." } }
    final data = response['data'];
    
    // Store token
    final token = data?['token'] ?? response['token'] ?? response['access_token'];
    if (token != null) {
      await ApiService.setToken(token);
    } else {
      throw Exception('Token tidak ditemukan dalam response');
    }
    
    // Enable auto-login by default after successful login
    await SettingsService.enableAutoLoginOnLogin();
    
    // Parse user data
    final userData = data?['user'] ?? response['user'];
    if (userData != null) {
      return User.fromJson(userData);
    }
    
    throw Exception('Data user tidak ditemukan');
  }
  
  /// Register new user
  static Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await ApiService.post(
      ApiConfig.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': 'civitas', // Default role for mobile app
      },
      withAuth: false,
    );
    
    // Laravel response format: { success: true, data: { user: {...}, token: "..." } }
    final data = response['data'];
    
    // Store token
    final token = data?['token'] ?? response['token'] ?? response['access_token'];
    if (token != null) {
      await ApiService.setToken(token);
    }
    
    // Parse user data
    final userData = data?['user'] ?? response['user'];
    if (userData != null) {
      return User.fromJson(userData);
    }
    
    throw Exception('Registrasi berhasil, silakan login');
  }
  
  /// Get current user info
  static Future<User> getCurrentUser() async {
    final response = await ApiService.get(ApiConfig.user);
    
    // Laravel response format: { success: true, data: {...} }
    final userData = response['data'] ?? response['user'] ?? response;
    return User.fromJson(userData);
  }
  
  /// Logout user
  static Future<void> logout() async {
    try {
      await ApiService.post(ApiConfig.logout, {});
    } catch (e) {
      // Ignore logout errors
    }
    await ApiService.clearToken();
  }
  
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}
