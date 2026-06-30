import '../config/api_config.dart';

/// Laporan Kerusakan Fasilitas model
class Laporan {
  final int? id;
  final String judul;
  final String lokasi;
  final String deskripsi;
  final String? _rawFoto; // Raw path from API
  final String? status;
  final String? feedback;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Laporan({
    this.id,
    required this.judul,
    required this.lokasi,
    required this.deskripsi,
    String? foto,
    this.status,
    this.feedback,
    this.userId,
    this.createdAt,
    this.updatedAt,
  }) : _rawFoto = foto;

  /// Get the full image URL based on current server configuration
  String? get foto {
    if (_rawFoto == null || _rawFoto.isEmpty) return null;
    
    // If it's already a full URL, return as-is
    if (_rawFoto.startsWith('http://') || _rawFoto.startsWith('https://')) {
      return _rawFoto;
    }
    
    // Use ApiConfig helper to construct the correct URL
    return ApiConfig.getImageUrl(_rawFoto);
  }
  
  /// Get raw foto path (for internal use)
  String? get rawFoto => _rawFoto;

  /// Safe int parsing - handles both int and String from JSON
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory Laporan.fromJson(Map<String, dynamic> json) {
    // Get raw image path - prioritize image_url if available (for local server with accessor)
    // Otherwise use image field
    String? rawImagePath;
    
    if (ApiConfig.isProductionServer()) {
      // Production: use 'image' field (raw path) and construct URL ourselves
      rawImagePath = json['image']?.toString();
    } else {
      // Local: try image_url first (full URL from accessor), fallback to image
      rawImagePath = json['image_url']?.toString() ?? json['image']?.toString();
    }
    
    return Laporan(
      id: _parseInt(json['id']),
      // Laravel uses English field names: title, description, location, image
      judul: json['title']?.toString() ?? json['judul']?.toString() ?? '',
      lokasi: json['location']?.toString() ?? json['lokasi']?.toString() ?? '',
      deskripsi: json['description']?.toString() ?? json['deskripsi']?.toString() ?? '',
      foto: rawImagePath,
      status: json['status']?.toString(),
      feedback: json['feedback']?.toString(),
      userId: _parseInt(json['user_id']),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      // Send with Indonesian field names as Laravel API expects
      'judul': judul,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      if (_rawFoto != null) 'foto': _rawFoto,
      if (status != null) 'status': status,
    };
  }

  Laporan copyWith({
    int? id,
    String? judul,
    String? lokasi,
    String? deskripsi,
    String? foto,
    String? status,
    String? feedback,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Laporan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      lokasi: lokasi ?? this.lokasi,
      deskripsi: deskripsi ?? this.deskripsi,
      foto: foto ?? _rawFoto,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
