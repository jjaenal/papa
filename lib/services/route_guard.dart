import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../app/app.router.dart';
import 'auth_service.dart';

/// Route guard untuk mengecek apakah user sudah login
/// Jika belum login, redirect ke login page
class AuthGuard extends StackedRouteGuard {
  final AuthService _authService = locator<AuthService>();
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    // Cek apakah user sudah login
    final isAuthenticated = _authService.isAuthenticated;

    // Jika route adalah login atau startup, biarkan navigasi lanjut
    if (resolver.route.name == Routes.loginView ||
        resolver.route.name == Routes.startupView) {
      return resolver.next();
    }

    // Jika belum login dan bukan ke halaman login, redirect ke login
    if (!isAuthenticated) {
      _navigationService.replaceWith(Routes.loginView);
      return resolver.next(false);
    }

    // Jika sudah login, lanjutkan navigasi
    return resolver.next();
  }
}
