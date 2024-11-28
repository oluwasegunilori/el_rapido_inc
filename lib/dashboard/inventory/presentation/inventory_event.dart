import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInventories extends InventoryEvent {}

class AddInventory extends InventoryEvent {
  final Inventory inventory;
  AddInventory(this.inventory);

  @override
  List<Object?> get props => [inventory];
}

class UpdateInventory extends InventoryEvent {
  final Inventory inventory;
  UpdateInventory(this.inventory);

  @override
  List<Object?> get props => [inventory];
}

class DeleteInventory extends InventoryEvent {
  final String id;
  DeleteInventory(this.id);

  @override
  List<Object?> get props => [id];
}
