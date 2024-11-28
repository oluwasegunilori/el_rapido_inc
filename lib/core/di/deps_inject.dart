import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_bloc.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_bloc.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_bloc.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/data/repository/user_repository.dart';
import 'package:el_rapido_inc/dashboard/inventory/data/inventory_repository_impl.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory_repository.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> depsSetup() async {
  // Initialize SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register UserSessionManager implementation as a singleton
  getIt.registerSingleton<UserSessionManager>(
    UserSessionManagerImpl(prefs: prefs),
  );

  //repos
  getIt.registerFactory<UserRepository>(
      () => FirestoreUserRepository(firestore: firestore));

  getIt.registerFactory<InventoryRepository>(
      () => FirebaseInventoryRepository(firestore: firestore));

  //blocs
  getIt.registerFactory<VerificationBloc>(
      () => VerificationBloc(firestore, getIt<UserSessionManager>()));

  getIt.registerFactory<SignupBloc>(() => SignupBloc(_auth, _googleSignIn,
      getIt<UserSessionManager>(), getIt<UserRepository>()));

  getIt.registerFactory<LoginBloc>(() => LoginBloc(_auth, _googleSignIn,
      getIt<UserSessionManager>(), getIt<UserRepository>(), firestore));

  getIt.registerFactory<InventoryBloc>(
      () => InventoryBloc(getIt<InventoryRepository>()));
}
