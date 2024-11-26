import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/core/data/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserRepository {
  /// Creates or updates a user in Firestore
  Future<void> createUser(User user);

  /// Retrieves a user by email from Firestore
  Future<User?> getUserByEmail();

  Future<void> updateUserWithToken(String token);

  Future<void> saveUserSignUpSession(String userCredential);

  Future<void> saveSignUpDetailsTemporarily(User user);

  Future<bool> isUserActivated(String token);
}

const String USER_COLL = "users";

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore firestore;

  FirestoreUserRepository({required this.firestore});


  @override
  Future<void> createUser(User user) async {
    try {
      await firestore
          .collection(USER_COLL)
          .doc(user.email)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<User?> getUserByEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    if (email == null) {
      return null;
    }

    try {
      final doc = await firestore.collection(USER_COLL).doc(email).get();
      if (doc.exists && doc.data() != null) {
        return User.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to retrieve user: $e');
    }
  }

  @override
  Future<void> saveUserSignUpSession(String userCredential) {
    // TODO: implement saveUserSignUpSession
    throw UnimplementedError();
  }

  @override
  Future<void> saveSignUpDetailsTemporarily(User user) async {
    try {
      await firestore
          .collection(USER_COLL)
          .doc(user.id)
          .set(user.toTempFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<void> updateUserWithToken(String token) {
    // TODO: implement updateUserWithToken
    throw UnimplementedError();
  }

  @override
  Future<bool> isUserActivated(String token) async {
    final userDoc = await firestore.collection('users').doc(token).get();

    if (!userDoc.exists) {
      return false;
    }

    final data = userDoc.data();
    final bool activated = data?['activated'] ?? false;

    return activated;
  }
}
