import 'package:flutter/foundation.dart';

/// Status paket yang mungkin
enum PackageStatus {
  draft,
  menunggu_anggota,
  aktif,
  selesai,
}

/// [Package] model untuk representasi paket patungan.
///
/// Model ini menyimpan informasi tentang paket patungan seperti nama,
/// deskripsi, total harga, durasi, target anggota, dan status.
class Package {
  /// ID unik paket
  final String id;
  
  /// ID pembuat paket
  final String creatorId;
  
  /// Nama paket
  final String name;
  
  /// Deskripsi paket (opsional)
  final String? description;
  
  /// Total harga paket
  final double totalHarga;
  
  /// Durasi paket dalam bulan
  final int durasiBulan;
  
  /// Target jumlah anggota
  final int targetAnggota;
  
  /// Status paket saat ini
  final PackageStatus status;
  
  /// Waktu pembuatan paket
  final DateTime createdAt;
  
  /// Waktu aktivasi paket (null jika belum aktif)
  final DateTime? activatedAt;
  
  /// Waktu penyelesaian paket (null jika belum selesai)
  final DateTime? finishedAt;

  /// Constructor untuk Package
  Package({
    required this.id,
    required this.creatorId,
    required this.name,
    this.description,
    required this.totalHarga,
    required this.durasiBulan,
    required this.targetAnggota,
    required this.status,
    required this.createdAt,
    this.activatedAt,
    this.finishedAt,
  });

  /// Factory constructor untuk membuat Package dari JSON
  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalHarga: (json['total_harga'] as num).toDouble(),
      durasiBulan: json['durasi_bulan'] as int,
      targetAnggota: json['target_anggota'] as int,
      status: _stringToPackageStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'] as String)
          : null,
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'] as String)
          : null,
    );
  }

  /// Konversi Package ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'name': name,
      'description': description,
      'total_harga': totalHarga,
      'durasi_bulan': durasiBulan,
      'target_anggota': targetAnggota,
      'status': _packageStatusToString(status),
      'created_at': createdAt.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
    };
  }

  /// Konversi Package ke JSON untuk insert/update ke Supabase
  /// Tidak menyertakan id jika createNew=true
  Map<String, dynamic> toSupabaseJson({bool createNew = false}) {
    final json = {
      'creator_id': creatorId,
      'name': name,
      'description': description,
      'total_harga': totalHarga,
      'durasi_bulan': durasiBulan,
      'target_anggota': targetAnggota,
      'status': _packageStatusToString(status),
    };

    if (!createNew) {
      json['id'] = id;
    }

    return json;
  }

  /// Membuat salinan Package dengan nilai yang diperbarui
  Package copyWith({
    String? id,
    String? creatorId,
    String? name,
    String? description,
    double? totalHarga,
    int? durasiBulan,
    int? targetAnggota,
    PackageStatus? status,
    DateTime? createdAt,
    DateTime? activatedAt,
    DateTime? finishedAt,
  }) {
    return Package(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      totalHarga: totalHarga ?? this.totalHarga,
      durasiBulan: durasiBulan ?? this.durasiBulan,
      targetAnggota: targetAnggota ?? this.targetAnggota,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  /// Konversi string status ke enum PackageStatus
  static PackageStatus _stringToPackageStatus(String status) {
    switch (status) {
      case 'draft':
        return PackageStatus.draft;
      case 'menunggu_anggota':
        return PackageStatus.menunggu_anggota;
      case 'aktif':
        return PackageStatus.aktif;
      case 'selesai':
        return PackageStatus.selesai;
      default:
        return PackageStatus.draft;
    }
  }

  /// Konversi enum PackageStatus ke string
  static String _packageStatusToString(PackageStatus status) {
    switch (status) {
      case PackageStatus.draft:
        return 'draft';
      case PackageStatus.menunggu_anggota:
        return 'menunggu_anggota';
      case PackageStatus.aktif:
        return 'aktif';
      case PackageStatus.selesai:
        return 'selesai';
    }
  }

  /// Menghitung cicilan per anggota per bulan
  double get cicilanPerBulan {
    return totalHarga / (durasiBulan * targetAnggota);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Package &&
        other.id == id &&
        other.creatorId == creatorId &&
        other.name == name &&
        other.description == description &&
        other.totalHarga == totalHarga &&
        other.durasiBulan == durasiBulan &&
        other.targetAnggota == targetAnggota &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        creatorId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        totalHarga.hashCode ^
        durasiBulan.hashCode ^
        targetAnggota.hashCode ^
        status.hashCode;
  }
}