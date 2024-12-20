
import 'package:el_rapido_inc/auth/presentation/signup/signup_event.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_state.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/data/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:el_rapido_inc/core/data/model/user.dart' as inUser;
import 'package:flutter/foundation.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserSessionManager _userSessionManager;
  final UserRepository _userRepository;

  SignupBloc(this._auth, this._googleSignIn, this._userSessionManager,
      this._userRepository)
      : super(SignupInitial()) {
    on<SignupButtonPressed>((event, emit) async {
      emit(SignupLoading());
      try {
        var userCreds = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        final actionCodeSettings = ActionCodeSettings(
          url: getVerificationLink(userCreds),
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
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        final userCreds = await _auth.signInWithPopup(authProvider);
        await createUserGoogle(userCreds, emit);
      } catch (e) {
        emit(SignupFailure(e.toString()));
      }
    });

    on<UserVerification>((event, emit) async {
      emit(SignupLoading());
    });


    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {});
  }

  Future<void> createUserGoogle(
      UserCredential userCreds, Emitter<SignupState> emit) async {
    _userRepository.createUser(inUser.User.fromFirebaseAuth(userCreds, activated: true));
    emit(SignupSuccess(moveToDashBoard: true));
  }

  String getVerificationLink(UserCredential userCreds) {
    return kDebugMode
        ? "http://localhost:5000/signupverification?token=${userCreds.user?.uid}"
        : "https://elrapidoinv.web.app/signupverification?token=${userCreds.user?.uid}";
  }

  void saveUserSignIn(UserCredential userCreds) {
    _userSessionManager.saveUserLoginSession(userCreds);
  }
}
