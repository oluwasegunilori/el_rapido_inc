import 'package:equatable/equatable.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class VerifyTokenEvent extends VerificationEvent {
  final String token;

  const VerifyTokenEvent(this.token);

  @override
  List<Object?> get props => [token];
}
