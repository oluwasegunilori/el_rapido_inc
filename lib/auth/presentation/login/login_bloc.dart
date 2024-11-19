import 'package:el_rapido_inc/auth/presentation/login/login_event.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth;

  LoginBloc(this._auth) : super(LoginInitial());

  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();
      try {
        await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        yield LoginSuccess();
      } catch (e) {
        yield LoginFailure(e.toString());
      }
    }
  }
}
