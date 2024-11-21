import 'dart:io';

import 'package:el_rapido_inc/auth/presentation/signup/signup_event.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_state.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/data/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:el_rapido_inc/core/data/model/user.dart' as inUser;

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserSessionManager _userSessionManager = UserSessionManagerImpl();
  final UserRepository _userRepository = FirestoreUserRepository();

  SignupBloc() : super(SignupInitial()) {
    on<SignupButtonPressed>((event, emit) async {
      emit(SignupLoading());
      try {
        var userCreds = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        final actionCodeSettings = ActionCodeSettings(
          url:
              "http://localhost:5000/signupverification?token=${userCreds.user?.uid}",
        );

        await userCreds.user?.sendEmailVerification(actionCodeSettings);
        _userRepository.saveSignUpDetailsTemporarily(
            inUser.User.fromFirebaseAuthTemp(
                userCreds, event.firstName, event.lastName));
        emit(SignupSuccess(message: "Check your mail for verification"));
      } catch (e) {
        emit(SignupFailure(e.toString()));
      }
    });

    on<GoogleSignInPressed>((event, emit) async {
      emit(SignupLoading());
      try {
        GoogleSignInAccount? googleUser;
        if (kIsWeb) {
          googleUser = await _googleSignIn.signInSilently();
        } else {
          googleUser = await _googleSignIn.signIn();
        }
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );
          var userCreds = await _auth.signInWithCredential(credential);
          _userRepository.createUser(inUser.User.fromFirebaseAuth(userCreds));
          emit(SignupSuccess(moveToDashBoard: true));
        } else {
          emit(SignupFailure('Google Sign-In failed'));
        }
      } catch (e) {
        emit(SignupFailure(e.toString()));
      }
    });

    on<UserVerification>((event, emit) async {
      emit(SignupLoading());
    });
  }

  void saveUserSignIn(UserCredential userCreds) {
    _userSessionManager.saveUserLoginSession(userCreds);
  }
}
