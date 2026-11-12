import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles the local account and the "remember me" session.
///
/// Task 5 of the assignment asks for local persistence — this is it.
/// Passwords are never stored in plain text: only a SHA-256 hash is kept,
/// which is what a real backend would do server-side.
class AuthService {
  static const String _kEmail = 'auth.email';
  static const String _kName = 'auth.name';
  static const String _kPasswordHash = 'auth.password_hash';
  static const String _kSignedIn = 'auth.signed_in';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<bool> hasSession() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_kSignedIn) ?? false;
  }

  Future<String?> savedName() async => (await _prefs).getString(_kName);

  Future<String?> savedEmail() async => (await _prefs).getString(_kEmail);

  Future<bool> hasAccount() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_kEmail) != null;
  }

  /// Returns an error message, or `null` when the sign-in succeeded.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await _prefs;
    final String? savedEmail = prefs.getString(_kEmail);
    final String? savedHash = prefs.getString(_kPasswordHash);

    if (savedEmail == null || savedHash == null) {
      return 'No account found. Create one first.';
    }
    if (savedEmail != email.trim().toLowerCase()) {
      return 'No account found with this email.';
    }
    if (savedHash != _hash(password)) {
      return 'Incorrect password. Try again.';
    }

    await prefs.setBool(_kSignedIn, true);
    return null;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(_kName, name.trim());
    await prefs.setString(_kEmail, email.trim().toLowerCase());
    await prefs.setString(_kPasswordHash, _hash(password));
    await prefs.setBool(_kSignedIn, true);
  }

  Future<void> signOut() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_kSignedIn, false);
  }
}
