import 'package:supabase_flutter/supabase_flutter.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Supabase Service – Singleton access to the Supabase client.
///
/// Call [SupabaseService.initialize] once in main() before runApp().
/// Access the client anywhere via [SupabaseService.client].
/// ─────────────────────────────────────────────────────────────────────────────
class SupabaseService {
  SupabaseService._(); // Prevent instantiation

  // ──────────────────── Configuration ────────────────────
  static const String _supabaseUrl = 'https://jmolyorfbdvztrlsjybi.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imptb2x5b3JmYmR2enRybHNqeWJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2MzQ5ODAsImV4cCI6MjA5NTIxMDk4MH0.H7ultcZ6twZniok59O8W6DODAVjm34ESSRwU6aYbsx8';

  // ──────────────────── Initialization ────────────────────
  /// Must be called once before runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      // Optional: Configure deep-link scheme for OAuth redirect
      // authOptions: const FlutterAuthClientOptions(
      //   authFlowType: AuthFlowType.pkce,
      // ),
    );
  }

  // ──────────────────── Client Accessor ────────────────────
  /// Returns the initialized [SupabaseClient].
  static SupabaseClient get client => Supabase.instance.client;
}
