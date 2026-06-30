import '../config/api_config.dart';

/// Traffic Update (Laporan Kemacetan) model
class TrafficUpdate {
  final int? id;
  final String location;
  final String status; // 'lancar', 'padat', 'macet'
  final String? description;
  final String? _rawImage; // Raw path from API
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrafficUpdate({
    this.id,
    required this.location,
    required this.status,
    this.description,
    String? image,
    this.userId,
    this.createdAt,
    this.updatedAt,
  }) : _rawImage = image;

  /// Get the full image URL based on current server configuration
  String? get image {
    if (_rawImage == null || _rawImage.isEmpty) return null;
    
    // If it's already a full URL, return as-is
    if (_rawImage.startsWith('http://') || _rawImage.startsWith('https://')) {
      return _rawImage;
    }
    
    // Use ApiConfig helper to construct the correct URL
    return ApiConfig.getImageUrl(_rawImage);
  }
  
  /// Get raw image path (for internal use)
  String? get rawImage => _rawImage;

  /// Safe int parsing
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory TrafficUpdate.fromJson(Map<String, dynamic> json) {
    // Get raw image path based on server type
    String? rawImagePath;
    
    if (ApiConfig.isProductionServer()) {
      // Production: use 'image' field (raw path) and construct URL ourselves
      rawImagePath = json['image']?.toString();
    } else {
      // Local: try image_url first (full URL from accessor), fallback to image
      rawImagePath = json['image_url']?.toString() ?? json['image']?.toString();
    }
    
    return TrafficUpdate(
      id: _parseInt(json['id']),
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? 'lancar',
      description: json['description']?.toString(),
      image: rawImagePath,
      userId: _parseInt(json['user_id']),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
    );
  }

  /// Get display status in Indonesian
  String get displayStatus {
    switch (status) {
      case 'lancar':
        return 'Lancar';
      case 'padat':
        return 'Padat';
      case 'macet':
        return 'Macet';
      default:
        return status;
    }
  }

  /// Get relative time string
  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
