import 'dart:async';

import 'package:el_rapido_inc/dashboard/transaction/data/repository/transaction_repository.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_event.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc(this.transactionRepository) : super(TransactionInitial()) {
    on<CreateTransaction>((event, emit) async {
      try {
        emit(TransactionLoading());
        await transactionRepository.createTransaction(event.transaction);
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<FetchTransactions>((event, emit) async {
      try {
        emit(TransactionLoading());
        await transactionRepository
            .fetchTransactions(
          merchantId: event.merchantId,
          inventoryId: event.inventoryId,
          dateRange: event.dateRange,
          createdBy: event.createdBy,
        )
            .listen((transactions) {
          emit(TransactionLoaded(transactions));
        }).asFuture();
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });
  }
}
