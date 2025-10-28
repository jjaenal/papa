import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _kLocalSessionKey = 'local_session_active';
  static const _kLocalPhoneKey = 'local_phone';
  static const _kLocalOtpKey = 'local_otp';
  static const _kLocalOtpExpiresKey = 'local_otp_expires';

  // Reactive state
  final ReactiveValue<bool> _isAuthenticated = ReactiveValue<bool>(false);
  final ReactiveValue<User?> _currentUser = ReactiveValue<User?>(null);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);
  final ReactiveValue<String?> _lastError = ReactiveValue<String?>(null);

  // Getters
  bool get isAuthenticated => _isAuthenticated.value;
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String? get lastError => _lastError.value;

  // Constructor
  AuthService() {
    listenToReactiveValues([_isAuthenticated, _currentUser, _isLoading]);
    _initAuthState();
  }

  /// Inisialisasi state autentikasi dari sesi yang ada
  void _initAuthState() {
    try {
      final supabase = _supabaseService.client;
      if (supabase != null) {
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
      }
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
    }

    // Cek sesi lokal jika tidak ada sesi Supabase
    _restoreLocalSession();
  }

  /// Restore sesi lokal dari SharedPreferences jika tersedia
  Future<void> _restoreLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localActive = prefs.getBool(_kLocalSessionKey) ?? false;
      if (localActive) {
        _isAuthenticated.value = true;
        // currentUser tetap null untuk sesi lokal
      }
    } catch (e) {
      debugPrint('Error restoring local session: $e');
    }
  }

  /// Login dengan nomor telepon
  ///
  /// [phone] harus dalam format internasional (contoh: +6281234567890)
  /// Mengembalikan `true` jika OTP berhasil dikirim
  Future<bool> loginWithPhone(String phone) async {
    try {
      _isLoading.value = true;
      _lastError.value = null;
      final supabase = _supabaseService.client;
      debugPrint(
          'loginWithPhone supabase is ${supabase == null ? 'null' : 'not null'}');
      if (supabase == null) {
        _lastError.value = 'Supabase client tidak tersedia';
        debugPrint('loginWithPhone early return false due to null client');
        return false;
      }

      await supabase.auth.signInWithOtp(
        phone: phone,
      );

      return true;
    } catch (e) {
      debugPrint('Error login with phone: $e');
      _lastError.value = 'Gagal login dengan telepon: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Login lokal dengan generate OTP dan simpan ke SharedPreferences
  /// Mengembalikan true jika OTP berhasil dibuat dan disimpan
  Future<bool> loginWithPhoneLocal(String phone) async {
    try {
      _isLoading.value = true;
      _lastError.value = null;
      // Validasi sederhana format nomor
      if (!phone.startsWith('+')) {
        _lastError.value =
            "Nomor telepon invalid. Gunakan format internasional (mis. '+628...')";
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      // Generate OTP 6 digit
      final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
          .toString()
          .substring(0, 6);
      // Expire dalam 5 menit
      final expires =
          DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;

      await prefs.setString(_kLocalPhoneKey, phone);
      await prefs.setString(_kLocalOtpKey, otp);
      await prefs.setInt(_kLocalOtpExpiresKey, expires);

      // Untuk demo, print OTP ke console
      debugPrint('LOCAL OTP (demo): $otp');

      return true;
    } catch (e) {
      debugPrint('Error local login with phone: $e');
      _lastError.value = 'Gagal login lokal: ${e.toString()}';
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
      _lastError.value = null;
      final supabase = _supabaseService.client;
      if (supabase == null) {
        _lastError.value = 'Supabase client tidak tersedia';
        return false;
      }

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
      _lastError.value = 'Verifikasi OTP gagal: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Verifikasi OTP lokal dari SharedPreferences
  /// Jika valid, set isAuthenticated dan simpan sesi lokal aktif
  Future<bool> verifyOtpLocal(String phone, String otp) async {
    try {
      _isLoading.value = true;
      _lastError.value = null;
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString(_kLocalPhoneKey);
      final savedOtp = prefs.getString(_kLocalOtpKey);
      final expires = prefs.getInt(_kLocalOtpExpiresKey) ?? 0;

      final notExpired = DateTime.now().millisecondsSinceEpoch < expires;
      final valid = savedPhone == phone && savedOtp == otp && notExpired;

      if (valid) {
        _isAuthenticated.value = true;
        // Simpan flag sesi lokal aktif
        await prefs.setBool(_kLocalSessionKey, true);
        return true;
      }
      _lastError.value = 'Kode OTP tidak valid atau sudah kadaluarsa';
      return false;
    } catch (e) {
      debugPrint('Error verifying local OTP: $e');
      _lastError.value = 'Verifikasi OTP lokal gagal: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Login dengan Google
  Future<bool> loginWithGoogle() async {
    try {
      _isLoading.value = true;
      _lastError.value = null;
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
      _lastError.value = 'Gagal login Google: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      _lastError.value = null;
      final supabase = _supabaseService.client;
      if (supabase != null) {
        await supabase.auth.signOut();
      }

      // Bersihkan sesi lokal
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_kLocalSessionKey);
        await prefs.remove(_kLocalPhoneKey);
        await prefs.remove(_kLocalOtpKey);
        await prefs.remove(_kLocalOtpExpiresKey);
      } catch (_) {}

      _currentUser.value = null;
      _isAuthenticated.value = false;
    } catch (e) {
      debugPrint('Error logging out: $e');
      _lastError.value = 'Logout gagal: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }
}
