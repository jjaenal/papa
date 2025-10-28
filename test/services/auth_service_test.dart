import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:papa/app/app.locator.dart';
import 'package:papa/services/auth_service.dart';
import 'package:papa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/test_helpers.mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake SupabaseService yang bisa di-injeksi ke locator
class FakeSupabaseService extends SupabaseService {
  final SupabaseClient? _fakeClient;
  FakeSupabaseService([this._fakeClient]);
  @override
  SupabaseClient? get client => _fakeClient;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AuthService', () {
    late AuthService service;

    tearDown(() {
      if (locator.isRegistered<SupabaseService>()) {
        locator.unregister<SupabaseService>();
      }
    });

    test('local OTP flow generates and verifies OTP', () async {
      // No Supabase client required for local OTP
      locator.registerSingleton<SupabaseService>(FakeSupabaseService(null));
      // Prepare SharedPreferences mock BEFORE service initialization
      SharedPreferences.setMockInitialValues({});
      service = AuthService();
      // Note: shared_preferences uses real instance; we just run methods

      final sendResult = await service.loginWithPhoneLocal('+6281234567890');
      expect(sendResult, isTrue);

      // Retrieve OTP from prefs to verify
      final prefs = await SharedPreferences.getInstance();
      final otp = prefs.getString('local_otp');
      final phone = prefs.getString('local_phone');
      expect(otp, isNotNull);
      expect(phone, '+6281234567890');

      final verifyResult = await service.verifyOtpLocal('+6281234567890', otp!);
      expect(verifyResult, isTrue);
      expect(service.isAuthenticated, isTrue);
      expect(service.lastError, isNull);
    });

    test('returns false when client is null for loginWithPhone', () async {
      locator.registerSingleton<SupabaseService>(FakeSupabaseService(null));
      // Reset local prefs state to avoid carry-over from previous tests
      SharedPreferences.setMockInitialValues({});
      service = AuthService();

      final result = await service.loginWithPhone('+620000000000');
      expect(result, isFalse);
      expect(service.isAuthenticated, isFalse);
      expect(service.lastError, isNotNull);
    });

    test('loginWithPhone returns true when signInWithOtp succeeds', () async {
      final mockClient = MockSupabaseClient();
      final mockAuth = MockGoTrueClient();
      when(mockClient.auth).thenReturn(mockAuth);
      when(mockAuth.signInWithOtp(phone: anyNamed('phone')))
          .thenAnswer((_) async => Future.value());

      locator
          .registerSingleton<SupabaseService>(FakeSupabaseService(mockClient));
      service = AuthService();

      final result = await service.loginWithPhone('+620000000000');
      expect(result, isTrue);
    });

    test('verifyOtp returns false when client is null', () async {
      locator.registerSingleton<SupabaseService>(FakeSupabaseService(null));
      service = AuthService();

      final result = await service.verifyOtp('+620000000000', '123456');
      expect(result, isFalse);
      expect(service.currentUser, isNull);
      expect(service.lastError, isNotNull);
    });

    test('local login returns false with invalid phone and sets lastError',
        () async {
      locator.registerSingleton<SupabaseService>(FakeSupabaseService(null));
      SharedPreferences.setMockInitialValues({});
      service = AuthService();

      final result = await service.loginWithPhoneLocal('08123456789');
      expect(result, isFalse);
      expect(service.lastError, isNotNull);
    });

    test('loginWithGoogle returns false when client is null', () async {
      locator.registerSingleton<SupabaseService>(FakeSupabaseService(null));
      service = AuthService();

      final result = await service.loginWithGoogle();
      expect(result, isFalse);
    });

    // Skipping explicit OAuth path verification due to extension method constraints

    test('logout resets auth state', () async {
      final mockClient = MockSupabaseClient();
      final mockAuth = MockGoTrueClient();
      when(mockClient.auth).thenReturn(mockAuth);
      when(mockAuth.signOut()).thenAnswer((_) async => Future.value());

      locator
          .registerSingleton<SupabaseService>(FakeSupabaseService(mockClient));
      service = AuthService();

      await service.logout();
      expect(service.currentUser, isNull);
      expect(service.isAuthenticated, isFalse);
    });

    test('init auth state listens to stream without errors', () async {
      final mockClient = MockSupabaseClient();
      final mockAuth = MockGoTrueClient();
      when(mockClient.auth).thenReturn(mockAuth);
      when(mockAuth.currentSession).thenReturn(null);
      when(mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());

      locator
          .registerSingleton<SupabaseService>(FakeSupabaseService(mockClient));
      service = AuthService();

      expect(service.isAuthenticated, isFalse);
      expect(service.currentUser, isNull);
    });
  });
}
