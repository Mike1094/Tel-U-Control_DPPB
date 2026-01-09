/// Traffic Update (Laporan Kemacetan) model
class TrafficUpdate {
  final int? id;
  final String location;
  final String status; // 'lancar', 'padat', 'macet'
  final String? description;
  final String? image;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrafficUpdate({
    this.id,
    required this.location,
    required this.status,
    this.description,
    this.image,
    this.userId,
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

  factory TrafficUpdate.fromJson(Map<String, dynamic> json) {
    return TrafficUpdate(
      id: _parseInt(json['id']),
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? 'lancar',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
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
