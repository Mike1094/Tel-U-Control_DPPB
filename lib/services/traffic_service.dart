import '../config/api_config.dart';
import '../models/traffic_update.dart';
import 'api_service.dart';

/// Service for Traffic Update (Laporan Kemacetan) operations
class TrafficService {
  /// Get latest traffic updates - Public endpoint
  static Future<Map<String, dynamic>> getLatestSummary() async {
    final response = await ApiService.get(ApiConfig.trafficLatest, withAuth: false);
    
    // API returns: { success: true, data: { latest: [...], summary_24h: {...} } }
    final data = response['data'];
    
    List<TrafficUpdate> latest = [];
    if (data['latest'] is List) {
      latest = (data['latest'] as List).map((json) => TrafficUpdate.fromJson(json)).toList();
    }
    
    Map<String, dynamic> summary = data['summary_24h'] ?? {};
    
    return {
      'latest': latest,
      'summary': summary,
    };
  }
  
  /// Get all traffic updates (requires auth)
  static Future<List<TrafficUpdate>> getAll() async {
    final response = await ApiService.get(ApiConfig.traffic);
    
    // Handle paginated response
    dynamic rawData = response['data'];
    
    List<dynamic> dataList;
    if (rawData is Map) {
      dataList = rawData['data'] ?? [];
    } else if (rawData is List) {
      dataList = rawData;
    } else {
      dataList = [];
    }
    
    return dataList.map((json) => TrafficUpdate.fromJson(json)).toList();
  }
}
