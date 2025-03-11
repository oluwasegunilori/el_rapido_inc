import 'package:el_rapido_inc/core/data/model/user.dart';
import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {

  @override
  List<Object?> get props => [];
}

class FetchUsers extends UserEvent {}

class UpdateUser extends UserEvent {
  final User user;
  UpdateUser(this.user);
  @override
  List<Object?> get props => [user];
}
