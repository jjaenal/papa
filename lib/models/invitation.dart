/// [Invitation] model untuk representasi kode undangan paket.
///
/// Model ini menyimpan informasi tentang kode undangan untuk bergabung
/// dengan paket patungan tertentu.
class Invitation {
  /// ID unik undangan
  final String id;
  
  /// ID paket yang terkait dengan undangan
  final String packageId;
  
  /// Kode undangan yang digunakan untuk bergabung
  final String code;
  
  /// ID pengguna yang membuat undangan
  final String createdById;
  
  /// Waktu kedaluwarsa undangan (opsional)
  final DateTime? expiresAt;
  
  /// Waktu pembuatan undangan
  final DateTime createdAt;

  /// Constructor untuk Invitation
  Invitation({
    required this.id,
    required this.packageId,
    required this.code,
    required this.createdById,
    this.expiresAt,
    required this.createdAt,
  });

  /// Factory constructor untuk membuat Invitation dari JSON
  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      packageId: json['package_id'] as String,
      code: json['code'] as String,
      createdById: json['created_by'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Konversi Invitation ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'code': code,
      'created_by': createdById,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Konversi Invitation ke JSON untuk insert/update ke Supabase
  /// Tidak menyertakan id jika createNew=true
  Map<String, dynamic> toSupabaseJson({bool createNew = false}) {
    final json = {
      'package_id': packageId,
      'code': code,
      'created_by': createdById,
      'expires_at': expiresAt?.toIso8601String(),
    };

    if (!createNew) {
      json['id'] = id;
    }

    return json;
  }

  /// Membuat salinan Invitation dengan nilai yang diperbarui
  Invitation copyWith({
    String? id,
    String? packageId,
    String? code,
    String? createdById,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return Invitation(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      code: code ?? this.code,
      createdById: createdById ?? this.createdById,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Memeriksa apakah undangan sudah kedaluwarsa
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Invitation &&
        other.id == id &&
        other.packageId == packageId &&
        other.code == code &&
        other.createdById == createdById;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        packageId.hashCode ^
        code.hashCode ^
        createdById.hashCode;
  }
}