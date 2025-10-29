/// Role anggota dalam paket
enum MemberRole {
  member,
  host,
}

/// [PackageMember] model untuk representasi anggota paket patungan.
///
/// Model ini menyimpan informasi tentang anggota yang bergabung dalam
/// paket patungan tertentu, termasuk peran dan total pembayaran.
class PackageMember {
  /// ID unik anggota paket
  final String id;
  
  /// ID paket yang terkait
  final String packageId;
  
  /// ID pengguna yang menjadi anggota
  final String userId;
  
  /// Waktu bergabung dengan paket
  final DateTime joinedAt;
  
  /// Peran anggota (host/member)
  final MemberRole role;
  
  /// Total yang sudah dibayar oleh anggota
  final double totalBayar;

  /// Constructor untuk PackageMember
  PackageMember({
    required this.id,
    required this.packageId,
    required this.userId,
    required this.joinedAt,
    required this.role,
    required this.totalBayar,
  });

  /// Factory constructor untuk membuat PackageMember dari JSON
  factory PackageMember.fromJson(Map<String, dynamic> json) {
    return PackageMember(
      id: json['id'] as String,
      packageId: json['package_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      role: _stringToMemberRole(json['role'] as String),
      totalBayar: (json['total_bayar'] as num).toDouble(),
    );
  }

  /// Konversi PackageMember ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
      'role': _memberRoleToString(role),
      'total_bayar': totalBayar,
    };
  }

  /// Konversi PackageMember ke JSON untuk insert/update ke Supabase
  /// Tidak menyertakan id jika createNew=true
  Map<String, dynamic> toSupabaseJson({bool createNew = false}) {
    final json = {
      'package_id': packageId,
      'user_id': userId,
      'role': _memberRoleToString(role),
      'total_bayar': totalBayar,
    };

    if (!createNew) {
      json['id'] = id;
    }

    return json;
  }

  /// Membuat salinan PackageMember dengan nilai yang diperbarui
  PackageMember copyWith({
    String? id,
    String? packageId,
    String? userId,
    DateTime? joinedAt,
    MemberRole? role,
    double? totalBayar,
  }) {
    return PackageMember(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      role: role ?? this.role,
      totalBayar: totalBayar ?? this.totalBayar,
    );
  }

  /// Konversi string role ke enum MemberRole
  static MemberRole _stringToMemberRole(String role) {
    switch (role) {
      case 'host':
        return MemberRole.host;
      case 'member':
      default:
        return MemberRole.member;
    }
  }

  /// Konversi enum MemberRole ke string
  static String _memberRoleToString(MemberRole role) {
    switch (role) {
      case MemberRole.host:
        return 'host';
      case MemberRole.member:
        return 'member';
    }
  }

  /// Memeriksa apakah anggota adalah host
  bool get isHost => role == MemberRole.host;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PackageMember &&
        other.id == id &&
        other.packageId == packageId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        packageId.hashCode ^
        userId.hashCode;
  }
}