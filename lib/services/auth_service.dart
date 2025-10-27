import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app.locator.dart';
import 'supabase_service.dart';

/// [AuthService] mengelola autentikasi dan sesi pengguna.
///
/// Service ini menyediakan metode untuk login, logout, dan verifikasi sesi.
/// Menggunakan Supabase Auth sebagai backend.
///
/// Contoh:
/// ```dart
/// final authService = locator<AuthService>();
/// await authService.loginWithPhone('+6281234567890');
/// ```
class AuthService with ListenableServiceMixin {
  final _supabaseService = locator<SupabaseService>();
  
  // Reactive state
  final ReactiveValue<bool> _isAuthenticated = ReactiveValue<bool>(false);
  final ReactiveValue<User?> _currentUser = ReactiveValue<User?>(null);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);
  
  // Getters
  bool get isAuthenticated => _isAuthenticated.value;
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  
  // Constructor
  AuthService() {
    listenToReactiveValues([_isAuthenticated, _currentUser, _isLoading]);
    _initAuthState();
  }
  
  /// Inisialisasi state autentikasi dari sesi yang ada
  void _initAuthState() {
    try {
      final supabase = _supabaseService.client;
      if (supabase == null) return;
      
      // Set initial auth state
      final session = supabase.auth.currentSession;
      _currentUser.value = session?.user;
      _isAuthenticated.value = session != null;
      
      // Listen to auth state changes
      supabase.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        switch (event) {
          case AuthChangeEvent.signedIn:
          case AuthChangeEvent.tokenRefreshed:
          case AuthChangeEvent.userUpdated:
            _currentUser.value = session?.user;
            _isAuthenticated.value = true;
            break;
          case AuthChangeEvent.signedOut:
          case AuthChangeEvent.userDeleted:
            _currentUser.value = null;
            _isAuthenticated.value = false;
            break;
          default:
            break;
        }
      });
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
    }
  }
  
  /// Login dengan nomor telepon
  ///
  /// [phone] harus dalam format internasional (contoh: +6281234567890)
  /// Mengembalikan `true` jika OTP berhasil dikirim
  Future<bool> loginWithPhone(String phone) async {
    try {
      _isLoading.value = true;
      final supabase = _supabaseService.client;
      if (supabase == null) return false;
      
      await supabase.auth.signInWithOtp(
        phone: phone,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error login with phone: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Verifikasi OTP untuk login nomor telepon
  ///
  /// [phone] nomor telepon yang digunakan untuk login
  /// [otp] kode OTP yang diterima via SMS
  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      _isLoading.value = true;
      final supabase = _supabaseService.client;
      if (supabase == null) return false;
      
      final response = await supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );
      
      _currentUser.value = response.user;
      _isAuthenticated.value = response.user != null;
      
      return response.user != null;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Login dengan Google
  Future<bool> loginWithGoogle() async {
    try {
      _isLoading.value = true;
      final supabase = _supabaseService.client;
      if (supabase == null) return false;
      
      // Web dan mobile memiliki flow yang berbeda
      if (kIsWeb) {
        await supabase.auth.signInWithOAuth(
          Provider.google,
          redirectTo: Uri.base.origin,
        );
      } else {
        await supabase.auth.signInWithOAuth(Provider.google);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error login with Google: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      final supabase = _supabaseService.client;
      if (supabase == null) return;
      
      await supabase.auth.signOut();
      _currentUser.value = null;
      _isAuthenticated.value = false;
    } catch (e) {
      debugPrint('Error logging out: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}