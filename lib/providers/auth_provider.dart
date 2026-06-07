import 'dart:async';
import 'package:flutter/foundation.dart'; // kIsWeb ke liye zaroori hai
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Mobile native flow ke liye
import 'package:deepfake_ai/services/supabase_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AuthProvider – Production-ready authentication state management.
///
/// Uses [ChangeNotifier] for Provider integration.
/// Manages email/password auth, Google OAuth, session persistence,
/// and real-time auth state listening via Supabase.
/// ─────────────────────────────────────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  // ──────────────────── Private State ────────────────────
  final SupabaseClient _client = SupabaseService.client;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  Session? _session;
  late final StreamSubscription<AuthState> _authStateSubscription;

  // Web Client ID constant configuration
  static const String _myWebClientId = '501633342548-nh2bqgig4le1scos6vhf05n5fv7l4aa5.apps.googleusercontent.com';

  // ──────────────────── Constructor ────────────────────
  AuthProvider() {
    _initAuthListener();
  }

  // ──────────────────── Getters ────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  Session? get session => _session;
  bool get isAuthenticated => _user != null;
  String? get userEmail => _user?.email;
  String? get userDisplayName =>
      _user?.userMetadata?['full_name'] as String? ??
      _user?.userMetadata?['name'] as String?;

  // ──────────────────── Auth State Listener ────────────────────
  void _initAuthListener() {
    _session = _client.auth.currentSession;
    _user = _client.auth.currentUser;

    _authStateSubscription = _client.auth.onAuthStateChange.listen(
      (AuthState authState) {
        final AuthChangeEvent event = authState.event;
        final Session? newSession = authState.session;

        debugPrint('[AuthProvider] Auth event: $event');

        _session = newSession;
        _user = newSession?.user;

        switch (event) {
          case AuthChangeEvent.signedIn:
            _printBearerToken();
            break;
          case AuthChangeEvent.signedOut:
            debugPrint('[AuthProvider] User signed out.');
            break;
          case AuthChangeEvent.tokenRefreshed:
            debugPrint('[AuthProvider] Token refreshed.');
            _printBearerToken();
            break;
          case AuthChangeEvent.initialSession:
            if (newSession != null) {
              debugPrint('[AuthProvider] Restored session from persistence.');
              _printBearerToken();
            }
            break;
          default:
            break;
        }

        notifyListeners();
      },
      onError: (error) {
        debugPrint('[AuthProvider] Auth stream error: $error');
      },
    );
  }

  // ──────────────────── Session Expiry Logic ────────────────────
  Future<void> checkSessionExpiry() async {
    if (_session == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString('last_login_timestamp');
    
    if (lastLoginStr != null) {
      final lastLogin = DateTime.tryParse(lastLoginStr);
      if (lastLogin != null) {
        final difference = DateTime.now().difference(lastLogin).inDays;
        if (difference >= 5) {
          debugPrint('[AuthProvider] Session expired (older than 5 days). Signing out.');
          await signOut();
        }
      }
    }
  }

  Future<void> _updateLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_login_timestamp', DateTime.now().toIso8601String());
  }

  // ──────────────────── Email Sign Up ────────────────────
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final AuthResponse response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: fullName != null ? {'full_name': fullName.trim()} : null,
      );

      if (response.user != null) {
        if (response.user!.identities != null && response.user!.identities!.isEmpty) {
          _setError('This email is already registered. Please log in.');
          return false;
        }
        debugPrint('[AuthProvider] Sign-up successful for: ${response.user!.email}');
        _printBearerToken();
        return true;
      } else {
        _setError('Sign-up completed but no user was returned. Check your email for confirmation.');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      debugPrint('[AuthProvider] Sign-up AuthException: ${e.message}');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('[AuthProvider] Sign-up error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ──────────────────── Email Sign In ────────────────────
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.session != null) {
        debugPrint('[AuthProvider] Sign-in successful for: ${response.user?.email}');
        await _updateLoginTimestamp();
        _printBearerToken();
        return true;
      } else {
        _setError('Sign-in failed. Please verify your credentials.');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      debugPrint('[AuthProvider] Sign-in AuthException: ${e.message}');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('[AuthProvider] Sign-in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ──────────────────── Google OAuth Sign In ────────────────────
  /// Web pe browser flow aur Mobile pe native flow use karega.
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      if (kIsWeb) {
        // 🌐 WEB: Redirect flow
        String webRedirectUrl = Uri.base.origin;
        if (!webRedirectUrl.endsWith('/')) {
          webRedirectUrl = '$webRedirectUrl/';
        }

        final bool launched = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: webRedirectUrl,
        );

        if (!launched) {
          _setError('Could not launch Google sign-in.');
          return false;
        }
      } else {
        // 📱 MOBILE: Native Flow
        final googleSignIn = GoogleSignIn(
          serverClientId: _myWebClientId,
          scopes: ['email', 'profile'],
        );

        final googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          _setError('Sign-in cancelled.');
          return false;
        }

        final googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;
        final String? accessToken = googleAuth.accessToken;

        if (idToken == null || accessToken == null) {
          _setError('Google authentication failed (missing tokens).');
          return false;
        }

        await _client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }

      await _updateLoginTimestamp();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      debugPrint('[AuthProvider] Google AuthException: ${e.message}');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      debugPrint('[AuthProvider] Google Sign-in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ──────────────────── Sign Out ────────────────────
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      // 1. Local Shared Preferences clean up
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_login_timestamp');
      
      // 2. 📱 Mobile native Google account detachment
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: _myWebClientId,
          scopes: ['email', 'profile'],
        );
        
        // Google session ko disconnect karna taake next time account dubara pucha jaye
        try {
          await googleSignIn.signOut();
          await googleSignIn.disconnect(); 
          debugPrint('[AuthProvider] Native Google accounts disconnected and cache wiped.');
        } catch (googleError) {
          debugPrint('[AuthProvider] Silent ignore google plugin clean up error: $googleError');
        }
      }
      
      // 3. Supabase cloud session clean up
      await _client.auth.signOut();
      
      // 4. Local state reset
      _user = null;
      _session = null;
      
      debugPrint('[AuthProvider] Sign-out successful.');
    } on AuthException catch (e) {
      _setError(e.message);
      debugPrint('[AuthProvider] Supabase Sign-out AuthException: ${e.message}');
    } catch (e) {
      _setError('Sign-out failed.');
      debugPrint('[AuthProvider] Sign-out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ──────────────────── Utility Methods ────────────────────
  void clearError() {
    _clearError();
  }

  // ──────────────────── Private Helpers ────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _printBearerToken() {
    final String? accessToken = _client.auth.currentSession?.accessToken;
    if (accessToken != null) {
      debugPrint('Bearer $accessToken');
    }
  }

  // ──────────────────── Dispose ────────────────────
  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}