import 'dart:async';

import 'package:el_rapido_inc/dashboard/merchant/data/repository/merchants_repository.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_event.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MerchantBloc extends Bloc<MerchantEvent, MerchantState> {
  final MerchantsRepository repository;

  MerchantBloc(this.repository) : super(MerchantInitialState()) {
    on<CreateMerchantEvent>(_createMerchant);
    on<FetchMerchantsEvent>(_fetchMerchants);
    on<UpdateMerchantEvent>(_updateMerchant);
    on<DeleteMerchantEvent>(_deleteMerchant);
    on<UpdateInventoryListEvent>(_updateInventoryList);
    on<FetchMerchantsByInventoryIdEvent>(_fetchMerchantsByInventoryId);
    add(FetchMerchantsEvent());
  }

  Future<void> _fetchMerchants(
    FetchMerchantsEvent event,
    Emitter<MerchantState> emit,
  ) async {
    emit(MerchantLoadingState());
    try {
      final stream = repository.fetchMerchants(); // Stream of merchants
      await for (final merchants in stream) {
        emit(MerchantSuccessState(merchants: merchants));
      }
    } catch (e) {
      emit(MerchantErrorState(e.toString()));
    }
  }

  // Implement other methods similarly...

  FutureOr<void> _createMerchant(
      CreateMerchantEvent event, Emitter<MerchantState> emit) {
    repository.createMerchant(event.merchant);
  }

  FutureOr<void> _updateMerchant(
      UpdateMerchantEvent event, Emitter<MerchantState> emit) {
    repository.updateMerchant(event.merchant);
  }

  FutureOr<void> _deleteMerchant(
      DeleteMerchantEvent event, Emitter<MerchantState> emit) {}

  FutureOr<void> _updateInventoryList(
      UpdateInventoryListEvent event, Emitter<MerchantState> emit) {}

  FutureOr<void> _fetchMerchantsByInventoryId(
      FetchMerchantsByInventoryIdEvent event, Emitter<MerchantState> emit) {}
}
