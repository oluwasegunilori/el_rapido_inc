import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;

  InventoryBloc(this.repository) : super(InventoryInitial()) {
    on<LoadInventories>((event, emit) async {
      emit(InventoryLoading());
      await emit.forEach<List<Inventory>>(
        repository.fetchInventories(),
        onData: (inventories) => InventoryLoaded(inventories),
        onError: (error, stackTrace) => InventoryError(error.toString()),
      );
    });

    on<AddInventory>((event, emit) async {
      try {
        await repository.createInventory(event.inventory);
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });

    on<UpdateInventory>((event, emit) async {
      try {
        await repository.updateInventory(event.inventory);
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });

    on<DeleteInventory>((event, emit) async {
      try {
        await repository.deleteInventory(event.id);
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });
  }
}
