import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, store, customer }


class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;
  final bool activated;
  final Timestamp dateCreated; // New field

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.activated,
    required this.dateCreated, // Required field
  });

  /// Convert User to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.name, // Store enum as a string
      'activated': activated,
      'dateCreated': dateCreated, // Save the Timestamp
    };
  }

  /// Convert User to Firestore map for temporary storage
  Map<String, dynamic> toTempFirestore() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.name, // Store enum as a string
      'activated': false,
      'dateCreated': dateCreated, // Save the Timestamp
    };
  }

  /// Create User from Firestore map
  factory User.fromFirestore(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.customer, // Default to 'customer' if not matched
      ),
      activated: map['activated'] ?? false,
      dateCreated: map['dateCreated'] as Timestamp, // Convert to Timestamp
    );
  }

  /// Create User from Firebase Auth UserCredential
  factory User.fromFirebaseAuth(UserCredential credential) {
    final firebaseUser = credential.user!;
    return User(
      id: firebaseUser.uid,
      firstName: firebaseUser.displayName?.split(' ').first ?? '',
      lastName: firebaseUser.displayName?.split(' ').skip(1).join(' ') ?? '',
      email: firebaseUser.email ?? '',
      role: UserRole.customer, // Default role for new users
      activated: false,
      dateCreated: Timestamp.now(), // Set the current timestamp
    );
  }

  /// Temporary User creation from Firebase Auth with additional details
  factory User.fromFirebaseAuthTemp(
    UserCredential credential,
    String firstName,
    String lastName,
  ) {
    final firebaseUser = credential.user!;
    return User(
      id: firebaseUser.uid,
      firstName: firstName,
      lastName: lastName,
      email: firebaseUser.email ?? '',
      role: UserRole.customer, // Default role for new users
      activated: false,
      dateCreated: Timestamp.now(), // Set the current timestamp
    );
  }

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, role, activated, dateCreated];
}
