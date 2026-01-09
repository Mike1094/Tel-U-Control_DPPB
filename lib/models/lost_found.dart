/// Lost & Found item model
class LostFound {
  final int? id;
  final String jenis; // 'hilang' or 'ditemukan'
  final String namaBarang;
  final String lokasi;
  final String deskripsi;
  final String? foto;
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
    this.foto,
    this.status,
    this.userId,
    this.linkedLostId,
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

  factory LostFound.fromJson(Map<String, dynamic> json) {
    return LostFound(
      id: _parseInt(json['id']),
      jenis: json['jenis']?.toString() ?? 'hilang',
      // Laravel uses 'nama_barang'
      namaBarang: json['nama_barang']?.toString() ?? json['nama']?.toString() ?? '',
      // Laravel uses 'lokasi_ditemukan'
      lokasi: json['lokasi_ditemukan']?.toString() ?? json['lokasi']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      foto: json['foto']?.toString(),
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
      if (foto != null) 'foto': foto,
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
      foto: foto ?? this.foto,
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
