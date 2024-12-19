import 'package:equatable/equatable.dart';

import '../data/model/transaction_model.dart';

abstract class TransactionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  TransactionLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}
