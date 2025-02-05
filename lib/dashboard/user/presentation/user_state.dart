import 'package:el_rapido_inc/core/data/model/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users; // Replace with User model if needed
  UserLoaded(this.users);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}