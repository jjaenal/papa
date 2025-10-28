import 'package:flutter_test/flutter_test.dart';
import 'package:papa/services/supabase_service.dart';

void main() {
  group('SupabaseService.validateEnvMap', () {
    test('returns true when both keys are present and non-empty', () {
      final env = {
        'SUPABASE_URL': 'https://example.supabase.co',
        'SUPABASE_KEY': 'anon-key',
      };
      expect(SupabaseService.validateEnvMap(env), isTrue);
    });

    test('returns false when SUPABASE_URL missing', () {
      final env = {
        'SUPABASE_KEY': 'anon-key',
      };
      expect(SupabaseService.validateEnvMap(env), isFalse);
    });

    test('returns false when SUPABASE_KEY missing', () {
      final env = {
        'SUPABASE_URL': 'https://example.supabase.co',
      };
      expect(SupabaseService.validateEnvMap(env), isFalse);
    });

    test('returns false when values are empty or whitespace', () {
      final env = {
        'SUPABASE_URL': '   ',
        'SUPABASE_KEY': '',
      };
      expect(SupabaseService.validateEnvMap(env), isFalse);
    });
  });
}
