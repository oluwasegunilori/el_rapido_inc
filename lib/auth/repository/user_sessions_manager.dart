import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserSessionManager {
  Future<void> saveUserSession(UserCredential userCredential);
  Future<bool> isSessionExpired();
  Future<void> clearSession();
}

class UserSessionManagerImpl implements UserSessionManager {
  static const String _keyUid = 'uid';
  static const String _keyEmail = 'email';
  static const String _keyExpiry = 'expiry';

  // Save user credentials
  @override
  Future<void> saveUserSession(UserCredential userCredential) async {
    final prefs = await SharedPreferences.getInstance();
    final expirationTime =
        DateTime.now().add(const Duration(days: 1)).toIso8601String();

    await prefs.setString(_keyUid, userCredential.user?.uid ?? '');
    await prefs.setString(_keyEmail, userCredential.user?.email ?? '');
    await prefs.setString(_keyExpiry, expirationTime);
  }

  // Check if the session is expired
  @override
  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_keyExpiry);
    if (expiryString == null) return true;

    final expiryTime = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiryTime);
  }

  // Clear session
  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
