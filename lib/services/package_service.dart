import 'package:flutter/foundation.dart';
import 'package:papa/app/app.locator.dart';
import 'package:papa/models/invitation.dart';
import 'package:papa/models/package.dart';
import 'package:papa/models/package_member.dart';
import 'package:papa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [PackageService] mengelola operasi CRUD untuk paket patungan.
///
/// Service ini menyediakan fungsi untuk membuat, membaca, memperbarui, dan menghapus
/// paket patungan serta mengelola undangan dan anggota paket.
class PackageService {
  final _supabaseService = locator<SupabaseService>();
  
  /// Mendapatkan referensi ke tabel packages
  PostgrestFilterBuilder get _packagesTable => 
      _supabaseService.client!.from('packages');
  
  /// Mendapatkan referensi ke tabel invitations
  PostgrestFilterBuilder get _invitationsTable => 
      _supabaseService.client!.from('invitations');
  
  /// Mendapatkan referensi ke tabel package_members
  PostgrestFilterBuilder get _packageMembersTable => 
      _supabaseService.client!.from('package_members');

  /// Membuat paket baru
  ///
  /// Returns ID paket yang baru dibuat
  Future<String> createPackage(Package package) async {
    try {
      final response = await _packagesTable
          .insert(package.toSupabaseJson(createNew: true))
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating package: $e');
      rethrow;
    }
  }

  /// Mendapatkan paket berdasarkan ID
  Future<Package?> getPackageById(String id) async {
    try {
      final response = await _packagesTable
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Package.fromJson(response);
    } catch (e) {
      debugPrint('Error getting package by ID: $e');
      rethrow;
    }
  }

  /// Mendapatkan semua paket yang dibuat oleh pengguna tertentu
  Future<List<Package>> getPackagesByCreator(String creatorId) async {
    try {
      final response = await _packagesTable
          .select()
          .eq('creator_id', creatorId)
          .order('created_at', ascending: false);
      
      return response.map((json) => Package.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting packages by creator: $e');
      rethrow;
    }
  }

  /// Mendapatkan semua paket yang diikuti oleh pengguna tertentu
  Future<List<Package>> getPackagesByMember(String userId) async {
    try {
      final response = await _packageMembersTable
          .select('package_id')
          .eq('user_id', userId);
      
      final packageIds = response.map((json) => json['package_id'] as String).toList();
      
      if (packageIds.isEmpty) return [];
      
      final packages = await _packagesTable
          .select()
          .inFilter('id', packageIds)
          .order('created_at', ascending: false);
      
      return packages.map((json) => Package.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting packages by member: $e');
      rethrow;
    }
  }

  /// Memperbarui paket yang sudah ada
  Future<void> updatePackage(Package package) async {
    try {
      await _packagesTable
          .update(package.toSupabaseJson())
          .eq('id', package.id);
    } catch (e) {
      debugPrint('Error updating package: $e');
      rethrow;
    }
  }

  /// Menghapus paket berdasarkan ID
  ///
  /// Hanya paket dengan status 'draft' yang dapat dihapus
  Future<void> deletePackage(String id) async {
    try {
      final package = await getPackageById(id);
      
      if (package == null) {
        throw Exception('Package not found');
      }
      
      if (package.status != PackageStatus.draft) {
        throw Exception('Only draft packages can be deleted');
      }
      
      await _packagesTable.delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting package: $e');
      rethrow;
    }
  }

  /// Membuat kode undangan untuk paket
  ///
  /// Returns kode undangan yang dibuat
  Future<String> createInvitation(String packageId, String createdById) async {
    try {
      // Generate kode undangan unik (6 karakter alfanumerik)
      final code = _generateInviteCode();
      
      final invitation = Invitation(
        id: '', // ID akan dibuat oleh Supabase
        packageId: packageId,
        code: code,
        createdById: createdById,
        expiresAt: DateTime.now().add(const Duration(days: 7)), // Berlaku 7 hari
        createdAt: DateTime.now(),
      );
      
      await _invitationsTable.insert(invitation.toSupabaseJson(createNew: true));
      
      return code;
    } catch (e) {
      debugPrint('Error creating invitation: $e');
      rethrow;
    }
  }

  /// Mendapatkan undangan berdasarkan kode
  Future<Invitation?> getInvitationByCode(String code) async {
    try {
      final response = await _invitationsTable
          .select()
          .eq('code', code)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Invitation.fromJson(response);
    } catch (e) {
      debugPrint('Error getting invitation by code: $e');
      rethrow;
    }
  }

  /// Bergabung dengan paket menggunakan kode undangan
  Future<void> joinPackageByCode(String code, String userId) async {
    try {
      final invitation = await getInvitationByCode(code);
      
      if (invitation == null) {
        throw Exception('Invalid invitation code');
      }
      
      if (invitation.isExpired) {
        throw Exception('Invitation code has expired');
      }
      
      // Periksa apakah pengguna sudah menjadi anggota
      final existingMember = await _packageMembersTable
          .select()
          .eq('package_id', invitation.packageId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingMember != null) {
        throw Exception('You are already a member of this package');
      }
      
      // Periksa apakah paket sudah aktif
      final package = await getPackageById(invitation.packageId);
      
      if (package == null) {
        throw Exception('Package not found');
      }
      
      if (package.status == PackageStatus.aktif || package.status == PackageStatus.selesai) {
        throw Exception('This package is already active or completed');
      }
      
      // Tambahkan pengguna sebagai anggota
      final member = PackageMember(
        id: '', // ID akan dibuat oleh Supabase
        packageId: invitation.packageId,
        userId: userId,
        joinedAt: DateTime.now(),
        role: MemberRole.member,
        totalBayar: 0,
      );
      
      await _packageMembersTable.insert(member.toSupabaseJson(createNew: true));
    } catch (e) {
      debugPrint('Error joining package: $e');
      rethrow;
    }
  }

  /// Mendapatkan semua anggota paket
  Future<List<PackageMember>> getPackageMembers(String packageId) async {
    try {
      final response = await _packageMembersTable
          .select()
          .eq('package_id', packageId)
          .order('joined_at');
      
      return response.map((json) => PackageMember.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting package members: $e');
      rethrow;
    }
  }

  /// Menghitung jumlah anggota paket saat ini
  Future<int> countPackageMembers(String packageId) async {
    try {
      final response = await _packageMembersTable
          .select('id')
          .eq('package_id', packageId);
      
      return response.length;
    } catch (e) {
      debugPrint('Error counting package members: $e');
      rethrow;
    }
  }

  /// Menghasilkan kode undangan acak
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Menghindari karakter yang membingungkan
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    final code = StringBuffer();
    
    var temp = random;
    for (var i = 0; i < 6; i++) {
      code.write(chars[temp % chars.length]);
      temp ~/= chars.length;
      if (temp == 0) temp = (random + i) % 1000000;
    }
    
    return code.toString();
  }
}