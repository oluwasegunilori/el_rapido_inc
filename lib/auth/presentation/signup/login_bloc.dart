import 'dart:io';

import 'package:el_rapido_inc/auth/presentation/login/login_event.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_state.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/data/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserSessionManager _userSessionManager = UserSessionManagerImpl();
  final UserRepository _userRepository = FirestoreUserRepository();

  LoginBloc() : super(LoginInitial()) {
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

        bool isUserActivated =
            await _userRepository.isUserActivated(userCreds.user!.uid);

        if (!isUserActivated) {
          await userCreds.user?.sendEmailVerification();
        }

        saveUserSignIn(userCreds);

        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });

    on<GoogleSignInPressed>((event, emit) async {
      emit(LoginLoading());
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
          saveUserSignIn(userCreds);
          emit(LoginSuccess());
        } else {
          emit(LoginFailure('Google Sign-In failed'));
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }

  void saveUserSignIn(UserCredential userCreds) {
    _userSessionManager.saveUserLoginSession(userCreds);
  }
}
