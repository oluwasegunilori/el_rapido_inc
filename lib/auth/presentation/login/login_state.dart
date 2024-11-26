import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  final String email;
  LoginInitial({this.email = ""});

  @override
  List<Object?> get props => [email];
}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class LoginNotActivated extends LoginState {
  final String error;
  LoginNotActivated({required this.error});

  @override
  List<Object?> get props => [error];
}
