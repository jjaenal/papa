import 'package:papa/app/app.locator.dart';
import 'package:papa/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:papa/services/supabase_service.dart';
import 'package:papa/services/auth_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _supabaseService = locator<SupabaseService>();
  final _authService = locator<AuthService>();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    setBusy(true);
    try {
      await _supabaseService.initFromEnv();
    } catch (_) {
      // Continue gracefully even if env missing; onboarding can proceed
    }
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate based on auth state
    if (_authService.isAuthenticated) {
      // User sudah login, arahkan ke onboarding
      await _navigationService.replaceWithOnboardingView();
    } else {
      // User belum login, arahkan ke login
      await _navigationService.replaceWithLoginView();
    }
    setBusy(false);
  }
}
