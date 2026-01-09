import '../config/api_config.dart';
import '../models/lost_found.dart';
import 'api_service.dart';

/// Service for Lost & Found CRUD operations
class LostFoundService {
  /// Get all lost & found items
  static Future<List<LostFound>> getAll({String? jenis}) async {
    String endpoint = ApiConfig.lostFound;
    if (jenis != null) {
      endpoint += '?jenis=$jenis';
    }
    
    final response = await ApiService.get(endpoint);
    
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
    
    return dataList.map((json) => LostFound.fromJson(json)).toList();
  }
  
  /// Get only lost items (barang hilang)
  static Future<List<LostFound>> getLostItems() async {
    return getAll(jenis: 'hilang');
  }
  
  /// Get only found items (barang temuan)
  static Future<List<LostFound>> getFoundItems() async {
    return getAll(jenis: 'ditemukan');
  }
  
  /// Get single item by ID
  static Future<LostFound> getById(int id) async {
    final response = await ApiService.get('${ApiConfig.lostFound}/$id');
    
    final data = response['data'] ?? response;
    return LostFound.fromJson(data);
  }
  
  /// Create new lost/found item
  static Future<LostFound> create(LostFound item) async {
    final response = await ApiService.post(
      ApiConfig.lostFound,
      item.toJson(),
    );
    
    final data = response['data'] ?? response;
    return LostFound.fromJson(data);
  }
  
  /// Update existing item
  static Future<LostFound> update(int id, LostFound item) async {
    final response = await ApiService.put(
      '${ApiConfig.lostFound}/$id',
      item.toJson(),
    );
    
    final data = response['data'] ?? response;
    return LostFound.fromJson(data);
  }
  
  /// Delete item
  static Future<void> delete(int id) async {
    await ApiService.delete('${ApiConfig.lostFound}/$id');
  }
}
