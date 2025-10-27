import 'package:papa/app/app.bottomsheets.dart';
import 'package:papa/app/app.dialogs.dart';
import 'package:papa/app/app.locator.dart';
import 'package:papa/app/app.router.dart';
import 'package:papa/services/auth_service.dart';
import 'package:papa/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  String get counterLabel => 'Counter is: $_counter';
  String? get userEmail => _authService.currentUser?.email;

  int _counter = 0;

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Stacked Rocks!',
      description: 'Give stacked $_counter stars on Github',
    );
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  /// Logs out the current user and navigates back to login screen.
  Future<void> logout() async {
    setBusy(true);
    try {
      await _authService.logout();
      await _navigationService.replaceWithLoginView();
    } catch (e) {
      // Show error dialog if logout fails
      await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Logout Error',
        description: 'Failed to logout: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }
}
