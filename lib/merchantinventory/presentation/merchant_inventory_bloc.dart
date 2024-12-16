import 'package:el_rapido_inc/merchantinventory/data/model/merchant_inventory.dart';
import 'package:el_rapido_inc/merchantinventory/data/repository/merchant_inventory_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'merchant_inventory_event.dart';
import 'merchant_inventory_state.dart';

class MerchantInventoryBloc extends Bloc<MerchantInventoryEvent, MerchantInventoryState> {
  final MerchantInventoryRepository repository;

  MerchantInventoryBloc(this.repository) : super(MerchantInventoryInitial()) {
    // Handle create inventory event
    on<CreateMerchantInventory>((event, emit) async {
      emit(MerchantInventoryLoading());
      try {
        await repository.createMerchantInventory(event.inventory);
      } catch (e) {
        emit(MerchantInventoryFailure(e.toString()));
      }
    });

    // Handle update quantity event
    on<UpdateMerchantInventoryQuantity>((event, emit) async {
      emit(MerchantInventoryLoading());
      try {
        await repository.updateMerchantInventoryQuantity(event.inventoryId, event.newQuantity);
        emit(const MerchantInventoryOperationSuccess());
      } catch (e) {
        emit(MerchantInventoryFailure(e.toString()));
      }
    });

    // Handle update price event
    on<UpdateMerchantInventoryPrice>((event, emit) async {
      emit(MerchantInventoryLoading());
      try {
        await repository.updateMerchantInventoryPrice(event.inventoryId, event.newPrice);
        emit(const MerchantInventoryOperationSuccess());
      } catch (e) {
        emit(MerchantInventoryFailure(e.toString()));
      }
    });

    // Handle fetch inventories by merchant and inventory IDs
    on<FetchMerchantInventoriesByMerchantAndInventoryIds>((event, emit) async {
      emit(MerchantInventoryLoading());
      try {
        final stream = repository.fetchMerchantInventoriesByMerchantAndInventoryIds(event.merchantId, event.inventoryId);
        await emit.forEach<List<MerchantInventory>>(stream, onData: (inventories) {
          return MerchantInventorySuccess(inventories);
        });
      } catch (e) {
        emit(MerchantInventoryFailure(e.toString()));
      }
    });

    // Handle fetch inventories by merchant ID
    on<FetchMerchantInventoriesByMerchantId>((event, emit) async {
      emit(MerchantInventoryLoading());
      try {
        final stream = repository.fetchMerchantInventoriesByMerchantId(event.merchantId);
        await emit.forEach<List<MerchantInventory>>(stream, onData: (inventories) {
          return MerchantInventorySuccess(inventories);
        });
      } catch (e) {
        emit(MerchantInventoryFailure(e.toString()));
      }
    });
  }
}
