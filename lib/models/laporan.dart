/// Laporan Kerusakan Fasilitas model
class Laporan {
  final int? id;
  final String judul;
  final String lokasi;
  final String deskripsi;
  final String? foto;
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
    this.foto,
    this.status,
    this.feedback,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Safe int parsing - handles both int and String from JSON
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory Laporan.fromJson(Map<String, dynamic> json) {
    return Laporan(
      id: _parseInt(json['id']),
      // Laravel uses English field names: title, description, location, image
      judul: json['title']?.toString() ?? json['judul']?.toString() ?? '',
      lokasi: json['location']?.toString() ?? json['lokasi']?.toString() ?? '',
      deskripsi: json['description']?.toString() ?? json['deskripsi']?.toString() ?? '',
      foto: json['image']?.toString() ?? json['foto']?.toString(),
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
      if (foto != null) 'foto': foto,
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
      foto: foto ?? this.foto,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
