import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:equatable/equatable.dart';

abstract class MerchantState extends Equatable {
  const MerchantState();

  @override
  List<Object?> get props => [];
}

class MerchantInitialState extends MerchantState {}

class MerchantLoadingState extends MerchantState {}

class MerchantSuccessState extends MerchantState {
  final Merchant? merchant;
  final List<Merchant>? merchants;

  const MerchantSuccessState({this.merchant, this.merchants});

  @override
  List<Object?> get props => [merchant, merchants];
}

class MerchantErrorState extends MerchantState {
  final String message;

  const MerchantErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
