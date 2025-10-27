import 'package:papa/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:papa/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:papa/ui/views/home/home_view.dart';
import 'package:papa/ui/views/startup/startup_view.dart';
import 'package:papa/ui/views/onboarding/onboarding_view.dart';
import 'package:papa/ui/views/login/login_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:papa/services/supabase_service.dart';
import 'package:papa/services/auth_service.dart';
import 'package:papa/services/route_guard.dart';
import 'package:stacked_services/stacked_services.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView, guards: [AuthGuard]),
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: OnboardingView, guards: [AuthGuard]),
    MaterialRoute(page: LoginView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SupabaseService),
    LazySingleton(classType: AuthService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
