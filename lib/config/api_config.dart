/// API Configuration for Tel-U Control Flutter App
class ApiConfig {
  // Production URL - Server dosen (dengan prefix v1)
  static const String baseUrl = 'https://teluhub.sisteminformasikotacerdas.id/api/v1';
  
  // Localhost for development (uncomment if needed)
  // static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  
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
