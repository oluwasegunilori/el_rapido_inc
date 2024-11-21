abstract class SignupEvent {}

class SignupButtonPressed extends SignupEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  SignupButtonPressed(this.email, this.password, this.firstName, this.lastName);
}

class GoogleSignInPressed extends SignupEvent {}

class UserVerification extends SignupEvent {
  final String? token;

  UserVerification({required this.token});
}
