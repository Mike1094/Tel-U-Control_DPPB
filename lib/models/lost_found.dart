import '../config/api_config.dart';

/// Lost & Found item model
class LostFound {
  final int? id;
  final String jenis; // 'hilang' or 'ditemukan'
  final String namaBarang;
  final String lokasi;
  final String deskripsi;
  final String? _rawFoto; // Raw path from API
  final String? status;
  final int? userId;
  final int? linkedLostId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LostFound({
    this.id,
    required this.jenis,
    required this.namaBarang,
    required this.lokasi,
    required this.deskripsi,
    String? foto,
    this.status,
    this.userId,
    this.linkedLostId,
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

  factory LostFound.fromJson(Map<String, dynamic> json) {
    // Get raw image path based on server type
    String? rawImagePath;
    
    if (ApiConfig.isProductionServer()) {
      // Production: use 'foto' field (raw path) and construct URL ourselves
      rawImagePath = json['foto']?.toString();
    } else {
      // Local: try foto_url first (full URL from accessor), fallback to foto
      rawImagePath = json['foto_url']?.toString() ?? json['foto']?.toString();
    }
    
    return LostFound(
      id: _parseInt(json['id']),
      jenis: json['jenis']?.toString() ?? 'hilang',
      // Laravel uses 'nama_barang'
      namaBarang: json['nama_barang']?.toString() ?? json['nama']?.toString() ?? '',
      // Laravel uses 'lokasi_ditemukan'
      lokasi: json['lokasi_ditemukan']?.toString() ?? json['lokasi']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      foto: rawImagePath,
      status: json['status']?.toString(),
      userId: _parseInt(json['user_id']),
      linkedLostId: _parseInt(json['linked_lost_id']),
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
      'jenis': jenis,
      'nama_barang': namaBarang,
      // Send as 'lokasi_ditemukan' as Laravel expects
      'lokasi_ditemukan': lokasi,
      'deskripsi': deskripsi,
      if (_rawFoto != null) 'foto': _rawFoto,
      if (status != null) 'status': status,
      if (linkedLostId != null) 'linked_lost_id': linkedLostId,
    };
  }

  LostFound copyWith({
    int? id,
    String? jenis,
    String? namaBarang,
    String? lokasi,
    String? deskripsi,
    String? foto,
    String? status,
    int? userId,
    int? linkedLostId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LostFound(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      namaBarang: namaBarang ?? this.namaBarang,
      lokasi: lokasi ?? this.lokasi,
      deskripsi: deskripsi ?? this.deskripsi,
      foto: foto ?? _rawFoto,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      linkedLostId: linkedLostId ?? this.linkedLostId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLost => jenis == 'hilang';
  bool get isFound => jenis == 'ditemukan';
}
