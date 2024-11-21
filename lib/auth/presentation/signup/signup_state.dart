abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final String? message;
  final bool moveToDashBoard;

  SignupSuccess({this.message, this.moveToDashBoard = false});
}

class SignupFailure extends SignupState {
  final String error;
  SignupFailure(this.error);
}
