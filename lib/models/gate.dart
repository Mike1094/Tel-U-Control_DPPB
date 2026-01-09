/// Gate (Pintu Gerbang) model
class Gate {
  final int? id;
  final String namaGerbang;
  final String status; // 'open' or 'closed'
  final String? trafficStatus; // 'lancar', 'padat', 'macet'
  final String? cctvUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Gate({
    this.id,
    required this.namaGerbang,
    required this.status,
    this.trafficStatus,
    this.cctvUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Safe int parsing
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory Gate.fromJson(Map<String, dynamic> json) {
    return Gate(
      id: _parseInt(json['id']),
      namaGerbang: json['nama_gerbang']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      trafficStatus: json['traffic_status']?.toString(),
      cctvUrl: json['cctv_url']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
    );
  }

  /// Get display status (combines open/closed + traffic status)
  String get displayStatus {
    if (status == 'closed') return 'Tutup';
    switch (trafficStatus) {
      case 'lancar':
        return 'Lancar';
      case 'padat':
        return 'Padat';
      case 'macet':
        return 'Macet';
      default:
        return 'Lancar';
    }
  }

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';
}
