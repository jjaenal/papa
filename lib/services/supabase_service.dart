import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as fd;

/// [SupabaseService] manages Supabase initialization and configuration.
///
/// This service provides helpers to load environment variables, validate
/// required keys, and initialize the Supabase client used across the app.
/// It uses `supabase_flutter` for the client SDK.
///
/// Example:
/// ```dart
/// final svc = SupabaseService();
/// await svc.initFromEnv();
/// final client = svc.client;
/// ```
class SupabaseService {
  SupabaseClient? _client;

  /// Returns the initialized [SupabaseClient] or null if not initialized.
  SupabaseClient? get client => _client;

  /// Loads `.env` file and initializes Supabase using `SUPABASE_URL` and `SUPABASE_KEY`.
  ///
  /// Throws [StateError] when required variables are missing.
  Future<void> initFromEnv({String fileName = '.env'}) async {
    try {
      await fd.dotenv.load(fileName: fileName);
    } catch (_) {
      // Fallback for local dev if .env not present
      try {
        await fd.dotenv.load(fileName: '.env.example');
      } catch (_) {
        // ignore, validation will throw below
      }
    }

    final env = {
      'SUPABASE_URL': fd.dotenv.maybeGet('SUPABASE_URL') ?? '',
      'SUPABASE_KEY': fd.dotenv.maybeGet('SUPABASE_KEY') ?? '',
    };

    if (!validateEnvMap(env)) {
      throw StateError('Missing SUPABASE_URL or SUPABASE_KEY in env');
    }

    await Supabase.initialize(
      url: env['SUPABASE_URL']!,
      anonKey: env['SUPABASE_KEY']!,
    );
    _client = Supabase.instance.client;
  }

  /// Validates required env keys for Supabase initialization.
  ///
  /// Returns `true` if both `SUPABASE_URL` and `SUPABASE_KEY` are present and non-empty.
  static bool validateEnvMap(Map<String, String> env) {
    final url = env['SUPABASE_URL'] ?? '';
    final key = env['SUPABASE_KEY'] ?? '';
    return url.trim().isNotEmpty && key.trim().isNotEmpty;
  }
}
