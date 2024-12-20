import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_event.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_state.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/data/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:el_rapido_inc/core/data/model/user.dart' as inUser;
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserSessionManager _userSessionManager;
  final UserRepository _userRepository;
  final FirebaseFirestore firestore;

  LoginBloc(this._auth, this._googleSignIn, this._userSessionManager,
      this._userRepository, this.firestore)
      : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        //Sign in with email and password
        var userCreds = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        //check if user has been activated and if not send verification mail
        if (userCreds.user == null) {
          emit(LoginFailure("Invalid login"));
        }

        await confirmUserActivation(userCreds, emit);
      } catch (e) {
        emit(LoginFailure("Invalid credentials $e"));
      }
    });

    on<GoogleSignInPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        final userCreds = await _auth.signInWithPopup(authProvider);
        saveUserSignIn(userCreds);
        await _userRepository.createUserFromGoogleLogin(
            inUser.User.fromFirebaseAuth(userCreds, activated: true));
        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }

  Future<void> confirmUserActivation(
      UserCredential userCreds, Emitter<LoginState> emit) async {
    bool isUserActivated =
        await _userRepository.isUserActivated(userCreds.user!.uid);

    if (!isUserActivated) {
      final actionCodeSettings = ActionCodeSettings(
        url:
            "http://localhost:5000/signupverification?token=${userCreds.user?.uid}",
      );

      await userCreds.user?.sendEmailVerification(actionCodeSettings);
      // Update the user document to set `activated` to true
      await firestore.collection('users').doc(userCreds.user!.uid).update({
        'verificationSentDate': Timestamp.now(),
      });

      emit(LoginNotActivated(
          error: "Please check your email to verify your account"));
    } else {
      saveUserSignIn(userCreds);
      emit(LoginSuccess());
    }
  }

  void saveUserSignIn(UserCredential userCreds) {
    _userSessionManager.saveUserLoginSession(userCreds);
  }
}
