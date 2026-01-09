import '../config/api_config.dart';
import '../models/laporan.dart';
import 'api_service.dart';

/// Service for Laporan Kerusakan Fasilitas CRUD operations
class LaporanService {
  /// Get all laporan
  static Future<List<Laporan>> getAll() async {
    final response = await ApiService.get(ApiConfig.reports);
    
    // Handle paginated response from Laravel
    // Laravel returns: { success: true, data: { data: [...], current_page: 1, ... } }
    dynamic rawData = response['data'];
    
    List<dynamic> dataList;
    if (rawData is Map) {
      // Paginated response - get the 'data' array inside
      dataList = rawData['data'] ?? [];
    } else if (rawData is List) {
      // Direct list response
      dataList = rawData;
    } else {
      dataList = [];
    }
    
    return dataList.map((json) => Laporan.fromJson(json)).toList();
  }
  
  /// Get single laporan by ID
  static Future<Laporan> getById(int id) async {
    final response = await ApiService.get('${ApiConfig.reports}/$id');
    
    final data = response['data'] ?? response;
    return Laporan.fromJson(data);
  }
  
  /// Create new laporan
  static Future<Laporan> create(Laporan laporan) async {
    final response = await ApiService.post(
      ApiConfig.reports,
      laporan.toJson(),
    );
    
    final data = response['data'] ?? response;
    return Laporan.fromJson(data);
  }
  
  /// Update existing laporan
  static Future<Laporan> update(int id, Laporan laporan) async {
    final response = await ApiService.put(
      '${ApiConfig.reports}/$id',
      laporan.toJson(),
    );
    
    final data = response['data'] ?? response;
    return Laporan.fromJson(data);
  }
  
  /// Delete laporan
  static Future<void> delete(int id) async {
    await ApiService.delete('${ApiConfig.reports}/$id');
  }
}
