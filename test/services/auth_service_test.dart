import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:papa/app/app.locator.dart';
import 'package:papa/services/auth_service.dart';
import 'package:papa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/test_helpers.mocks.dart';

/// Fake SupabaseService yang bisa di-injeksi ke locator
class FakeSupabaseService extends SupabaseService {
  final SupabaseClient? _fakeClient;
  FakeSupabaseService([this._fakeClient]);
  @override
  SupabaseClient? get client => _fakeClient;
}

void main() {
  group('AuthService', () {
    late AuthService service;

    tearDown(() {
      if (locator.isRegistered<SupabaseService>()) {
        locator.unregister<SupabaseService>();
      }
    });

    test('returns false when client is null for loginWithPhone', () async {
      locator.registerSingleton<SupabaseService>(FakeSupabaseService(null));
      service = AuthService();

      final result = await service.loginWithPhone('+620000000000');
      expect(result, isFalse);
      expect(service.isAuthenticated, isFalse);
    });

    test('loginWithPhone returns true when signInWithOtp succeeds', () async {
      final mockClient = MockSupabaseClient();
      final mockAuth = MockGoTrueClient();
      when(mockClient.auth).thenReturn(mockAuth);
      when(mockAuth.signInWithOtp(phone: anyNamed('phone')))
          .thenAnswer((_) async => Future.value());

      locator.registerSingleton<SupabaseService>(FakeSupabaseService(mockClient));
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

      locator.registerSingleton<SupabaseService>(FakeSupabaseService(mockClient));
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

      locator.registerSingleton<SupabaseService>(FakeSupabaseService(mockClient));
      service = AuthService();

      expect(service.isAuthenticated, isFalse);
      expect(service.currentUser, isNull);
    });
  });
}