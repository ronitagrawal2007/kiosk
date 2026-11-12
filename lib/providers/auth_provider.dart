import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

enum AuthStatus { checking, signedOut, signedIn }

/// Owns the session state for the whole app.
/// Screens only read [status] and call [signIn] / [signUp] / [signOut].
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  AuthStatus _status = AuthStatus.checking;
  String _name = '';
  String _email = '';

  AuthStatus get status => _status;
  String get name => _name.isEmpty ? 'there' : _name;
  String get email => _email;

  /// Called once from the splash screen.
  Future<void> bootstrap() async {
    final bool hasSession = await _service.hasSession();
    if (hasSession) {
      _name = await _service.savedName() ?? '';
      _email = await _service.savedEmail() ?? '';
    }
    _status = hasSession ? AuthStatus.signedIn : AuthStatus.signedOut;
    notifyListeners();
  }

  Future<bool> hasAccount() => _service.hasAccount();

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final String? error =
        await _service.signIn(email: email, password: password);
    if (error != null) return error;

    _email = email.trim().toLowerCase();
    _name = await _service.savedName() ?? '';
    _status = AuthStatus.signedIn;
    notifyListeners();
    return null;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _service.signUp(name: name, email: email, password: password);
    _name = name.trim();
    _email = email.trim().toLowerCase();
    _status = AuthStatus.signedIn;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _service.signOut();
    _status = AuthStatus.signedOut;
    _name = '';
    _email = '';
    notifyListeners();
  }
}
