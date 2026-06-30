import 'package:shared_preferences/shared_preferences.dart';

/// API Configuration for Tel-U Control Flutter App
/// Supports dynamic base URL that can be changed at runtime
class ApiConfig {
  static const String _baseUrlKey = 'api_base_url';
  
  // Default URLs for quick selection
  static const String defaultProductionUrl = 'https://teluhub.sisteminformasikotacerdas.id/api/v1';
  static const String defaultLocalUrl = 'http://192.168.0.100/tubes/public/api/v1';
  
  // Cached base URL
  static String? _cachedBaseUrl;
  
  /// Get the current base URL (uses cache for performance)
  static String get baseUrl {
    return _cachedBaseUrl ?? defaultLocalUrl;
  }
  
  /// Initialize the API config - call this at app startup
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedBaseUrl = prefs.getString(_baseUrlKey) ?? defaultLocalUrl;
  }
  
  /// Get the stored base URL from preferences
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_baseUrlKey) ?? defaultLocalUrl;
    _cachedBaseUrl = url;
    return url;
  }
  
  /// Set a new base URL
  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
    _cachedBaseUrl = url;
  }
  
  /// Check if a custom URL has been set
  static Future<bool> hasCustomUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_baseUrlKey);
  }
  
  /// Reset to default URL
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
    _cachedBaseUrl = defaultLocalUrl;
  }
  
  /// Check if currently using production server
  static bool isProductionServer() {
    return baseUrl.contains('teluhub.sisteminformasikotacerdas.id');
  }
  
  /// Get the storage base URL for images
  /// Production: uses the image path directly (already full URL from server)
  /// Local: constructs full URL from base URL + storage path
  static String? getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    // If it's already a full URL, return as-is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    if (isProductionServer()) {
      // Production server: construct URL manually
      // Remove /api/v1 from base URL and add /storage/
      final baseWithoutApi = baseUrl.replaceAll('/api/v1', '');
      return '$baseWithoutApi/storage/$imagePath';
    } else {
      // Local server: construct URL from base URL
      // Remove /api/v1 from base URL and add /storage/
      final baseWithoutApi = baseUrl.replaceAll('/api/v1', '');
      return '$baseWithoutApi/storage/$imagePath';
    }
  }
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/auth/logout';
  static const String user = '/auth/me';
  
  // Laporan Kerusakan Fasilitas
  static const String reports = '/reports';
  
  // Lost & Found
  static const String lostFound = '/lost-found';
  
  // Gates (Status Pintu Gerbang) - Public
  static const String gates = '/gates';
  
  // Traffic (Kemacetan)
  static const String traffic = '/traffic';
  static const String trafficLatest = '/traffic/latest';
}
