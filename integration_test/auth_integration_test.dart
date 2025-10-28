import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:papa/main.dart' as app;

/// Integration test untuk UI autentikasi
///
/// Test ini memverifikasi bahwa UI login berfungsi dengan baik
/// tanpa memerlukan konfigurasi OAuth yang kompleks
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication UI Tests', () {
    testWidgets('Login UI elements are present and functional',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify all key UI elements are present
      expect(find.byKey(const Key('phone_input')), findsOneWidget);
      expect(find.byKey(const Key('send_otp_button')), findsOneWidget);
      expect(find.byKey(const Key('google_signin_button')), findsOneWidget);

      // Verify initial button text
      expect(find.text('Kirim OTP'), findsOneWidget);
      expect(find.text('Login dengan Google'), findsOneWidget);

      // Test phone input interaction
      final phoneInput = find.byKey(const Key('phone_input'));
      await tester.tap(phoneInput);
      await tester.pumpAndSettle();

      // Enter and clear phone number
      await tester.enterText(phoneInput, '081234567890');
      await tester.pumpAndSettle();

      await tester.enterText(phoneInput, '');
      await tester.pumpAndSettle();

      debugPrint('✅ All UI elements are present and functional');
    });

    testWidgets('Button interactions work without errors',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Test Google sign-in button tap (should not crash)
      final googleButton = find.byKey(const Key('google_signin_button'));
      await tester.tap(googleButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Test OTP button tap without phone number (should handle gracefully)
      final sendOtpButton = find.byKey(const Key('send_otp_button'));
      await tester.tap(sendOtpButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      debugPrint('✅ Button interactions work without crashes');
    });
  });
}
