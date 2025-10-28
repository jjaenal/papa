import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/auth_service.dart';

class LoginViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  // Toggle sementara untuk menggunakan OTP lokal
  static const bool useLocalOtp = true;

  // Form state
  String _phone = '';
  String _otp = '';
  String? _phoneError;
  String? _otpError;
  bool _otpSent = false;

  // Getters
  String get phone => _phone;
  String get otp => _otp;
  String? get phoneError => _phoneError;
  String? get otpError => _otpError;
  bool get otpSent => _otpSent;
  bool get isLoading => busy(this);
  String? get lastError => _authService.lastError;

  // Setters
  void setPhone(String value) {
    _phone = value;
    _phoneError = null;
    notifyListeners();
  }

  void setOtp(String value) {
    _otp = value;
    _otpError = null;
    notifyListeners();
  }

  // Validasi nomor telepon
  bool _validatePhone() {
    if (_phone.isEmpty) {
      _phoneError = 'Nomor telepon tidak boleh kosong';
      notifyListeners();
      return false;
    }

    // Format nomor telepon harus +62xxx
    if (!_phone.startsWith('+62')) {
      _phoneError = 'Format nomor telepon harus +62xxx';
      notifyListeners();
      return false;
    }

    return true;
  }

  // Validasi OTP
  bool _validateOtp() {
    if (_otp.isEmpty) {
      _otpError = 'Kode OTP tidak boleh kosong';
      notifyListeners();
      return false;
    }

    if (_otp.length < 6) {
      _otpError = 'Kode OTP tidak valid';
      notifyListeners();
      return false;
    }

    return true;
  }

  // Kirim OTP
  Future<void> sendOtp() async {
    if (!_validatePhone()) return;

    setBusy(true);
    try {
      final success = useLocalOtp
          ? await _authService.loginWithPhoneLocal(_phone)
          : await _authService.loginWithPhone(_phone);

      if (success) {
        _otpSent = true;
      } else {
        _phoneError =
            _authService.lastError ?? 'Gagal mengirim OTP. Coba lagi.';
      }
    } catch (e) {
      _phoneError = _authService.lastError ?? 'Error: ${e.toString()}';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Verifikasi OTP
  Future<void> verifyOtp() async {
    if (!_validateOtp()) return;

    setBusy(true);
    try {
      final success = useLocalOtp
          ? await _authService.verifyOtpLocal(_phone, _otp)
          : await _authService.verifyOtp(_phone, _otp);

      if (success) {
        // Navigasi ke onboarding jika berhasil login
        await _navigationService.replaceWith(Routes.onboardingView);
      } else {
        _otpError = _authService.lastError ??
            'Kode OTP tidak valid atau sudah kadaluarsa';
        notifyListeners();
      }
    } catch (e) {
      _otpError = _authService.lastError ?? 'Error: ${e.toString()}';
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // Login dengan Google
  Future<void> loginWithGoogle() async {
    setBusy(true);
    try {
      final success = await _authService.loginWithGoogle();

      if (success) {
        // Navigasi ke onboarding jika berhasil login
        await _navigationService.replaceWith(Routes.onboardingView);
      } else {
        // Tampilkan error jika gagal
        setErrorForObject(
            'google', _authService.lastError ?? 'Gagal login dengan Google');
        notifyListeners();
      }
    } catch (e) {
      setErrorForObject(
          'google', _authService.lastError ?? 'Error: ${e.toString()}');
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }
}
