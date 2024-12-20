import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_bloc.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_bloc.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_bloc.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/data/repository/logger_repository.dart';
import 'package:el_rapido_inc/core/data/repository/user_repository.dart';
import 'package:el_rapido_inc/dashboard/inventory/data/image_upload_reposiotry_impl.dart';
import 'package:el_rapido_inc/dashboard/inventory/data/inventory_repository_impl.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/image_upload_repository.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory_repository.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_bloc.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/uploader/image_upload_bloc.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/repository/merchants_repository.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_bloc.dart';
import 'package:el_rapido_inc/dashboard/transaction/data/repository/transaction_repository.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_bloc.dart';
import 'package:el_rapido_inc/merchantinventory/data/repository/merchant_inventory_repository.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> depsSetup() async {
  // Initialize SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["email"]);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio dio = Dio();

  // Register UserSessionManager implementation as a singleton
  getIt.registerSingleton<UserSessionManager>(
    UserSessionManagerImpl(prefs: prefs),
  );

  //repos
  getIt.registerFactory<UserRepository>(
      () => FirestoreUserRepository(firestore: firestore));

  getIt.registerFactory<InventoryRepository>(() => FirebaseInventoryRepository(
      firestore: firestore,
      userSessionManager: getIt<UserSessionManager>(),
      loggerRepository: getIt<LoggerRepository>()));

  getIt.registerFactory<ImageUploadRepository>(
      () => ImageUploadRepostoryImpl(dio: dio));

  getIt.registerFactory<LoggerRepository>(
      () => FirebaseLoggerRepository(firestore));

  getIt.registerFactory<MerchantsRepository>(
      () => MerchantsRepositoryImpl(firestore, getIt<InventoryRepository>()));

  getIt.registerFactory<MerchantInventoryRepository>(() =>
      MerchantInventoryRepositoryImpl(firestore, getIt<InventoryRepository>()));

  getIt.registerFactory<TransactionRepository>(
      () => TransactionRepositoryImpl(firestore, getIt()));

  //blocs
  getIt.registerFactory<VerificationBloc>(
      () => VerificationBloc(firestore, getIt<UserSessionManager>()));

  getIt.registerFactory<SignupBloc>(() => SignupBloc(_auth, _googleSignIn,
      getIt<UserSessionManager>(), getIt<UserRepository>()));

  getIt.registerFactory<LoginBloc>(() => LoginBloc(_auth, _googleSignIn,
      getIt<UserSessionManager>(), getIt<UserRepository>(), firestore));

  getIt.registerFactory<InventoryBloc>(
      () => InventoryBloc(getIt<InventoryRepository>()));

  getIt.registerFactory<ImageUploadBloc>(
      () => ImageUploadBloc(getIt<ImageUploadRepository>()));

  getIt.registerFactory<MerchantBloc>(
      () => MerchantBloc(getIt<MerchantsRepository>()));

  getIt.registerFactory<MerchantInventoryBloc>(
      () => MerchantInventoryBloc(getIt<MerchantInventoryRepository>()));

  getIt.registerFactory<TransactionBloc>(
      () => TransactionBloc(getIt<TransactionRepository>()));
}
