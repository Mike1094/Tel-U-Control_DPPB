/// User model for authentication
class User {
  final int id;
  final String name;
  final String email;
  final String? foto;
  final String? role;
  final String? subRole;
  final String? phone;
  final String? nimNip;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.foto,
    this.role,
    this.subRole,
    this.phone,
    this.nimNip,
    this.createdAt,
  });

  /// Safe int parsing - handles both int and String from JSON
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      foto: json['foto']?.toString() ?? json['profile_photo']?.toString(),
      role: json['role']?.toString(),
      subRole: json['sub_role']?.toString(),
      phone: json['phone']?.toString(),
      nimNip: json['nim_nip']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (foto != null) 'foto': foto,
      if (role != null) 'role': role,
      if (subRole != null) 'sub_role': subRole,
      if (phone != null) 'phone': phone,
      if (nimNip != null) 'nim_nip': nimNip,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isSatpam => role == 'satpam';
  bool get isCivitas => role == 'civitas';
}
