import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:el_rapido_inc/core/data/model/user.dart' as inUser;

abstract class UserSessionManager {
  Future<void> saveUserLoginSession(UserCredential userCredential);
  Future<void> saveUserLoginSessionWithUser(inUser.User user);
  Future<bool> isSessionExpired();
  Future<void> clearSession();
  Future<String> getLastEmail();
  Future<String> getUserId();
}

class UserSessionManagerImpl implements UserSessionManager {
  final SharedPreferences prefs;
  static const String _keyUid = 'uid';
  static const String _keyEmail = 'email';
  static const String _keyExpiry = 'expiry';

  UserSessionManagerImpl({required this.prefs});

  // Save user credentials
  @override
  Future<void> saveUserLoginSession(UserCredential userCredential) async {
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

  @override
  Future<String> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final emailString = prefs.getString(_keyEmail);
    if (emailString == null) {
      return "";
    } else {
      return emailString;
    }
  }

  @override
  Future<void> saveUserLoginSessionWithUser(inUser.User user) async {
    final prefs = await SharedPreferences.getInstance();
    final expirationTime =
        DateTime.now().add(const Duration(days: 1)).toIso8601String();

    await prefs.setString(_keyUid, user.id);
    await prefs.setString(_keyEmail, user.email);
    await prefs.setString(_keyExpiry, expirationTime);
  }
  
  @override
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString(_keyUid);
    if (idString == null) {
      return "";
    } else {
      return idString;
    }
  }
}
