import '../config/api_config.dart';
import '../models/gate.dart';
import 'api_service.dart';

/// Service for Gate (Pintu Gerbang) operations
class GateService {
  /// Get all gates - Public endpoint (no auth needed)
  static Future<List<Gate>> getAll() async {
    final response = await ApiService.get(ApiConfig.gates, withAuth: false);
    
    // API returns: { success: true, data: [...] }
    dynamic rawData = response['data'];
    
    List<dynamic> dataList;
    if (rawData is List) {
      dataList = rawData;
    } else {
      dataList = [];
    }
    
    return dataList.map((json) => Gate.fromJson(json)).toList();
  }
  
  /// Get gates summary with statistics
  static Future<Map<String, dynamic>> getSummary() async {
    final response = await ApiService.get('${ApiConfig.gates}/summary', withAuth: false);
    
    // API returns: { success: true, data: { gates: [...], summary: {...} } }
    final data = response['data'];
    
    List<Gate> gates = [];
    if (data['gates'] is List) {
      gates = (data['gates'] as List).map((json) => Gate.fromJson(json)).toList();
    }
    
    Map<String, dynamic> summary = data['summary'] ?? {};
    
    return {
      'gates': gates,
      'summary': summary,
    };
  }
}
