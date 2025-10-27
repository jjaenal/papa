import 'package:papa/app/app.locator.dart';
import 'package:papa/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// [OnboardingViewModel] handles onboarding form state and submission.
///
/// Provides setters for name and phone, a computed [canSubmit] flag, and
/// simple validation rules. On submit, it navigates to HomeView.
class OnboardingViewModel extends BaseViewModel {
  final NavigationService _navigationService;

  OnboardingViewModel({NavigationService? navigationService})
      : _navigationService = navigationService ?? locator<NavigationService>();

  String _name = '';
  String _phone = '';

  /// Updates the name field and triggers UI rebuild.
  void setName(String value) {
    _name = value.trim();
    rebuildUi();
  }

  /// Updates the phone field and triggers UI rebuild.
  void setPhone(String value) {
    _phone = value.trim();
    rebuildUi();
  }

  /// Returns true when the current [name] and [phone] satisfy validation.
  bool get canSubmit => validateName(_name) && validatePhone(_phone);

  /// Validates the provided name. Returns true for length >= 2.
  static bool validateName(String name) => name.trim().length >= 2;

  /// Validates the provided phone. Returns true for 10-15 digits.
  static bool validatePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  /// Submits the profile and navigates to home view.
  /// In the future, this will persist to Supabase.
  Future<void> submitProfile() async {
    setBusy(true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      await _navigationService.replaceWithHomeView();
    } finally {
      setBusy(false);
    }
  }
}
