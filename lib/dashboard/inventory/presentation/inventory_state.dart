import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:equatable/equatable.dart';

abstract class InventoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Inventory> inventories;
  InventoryLoaded(this.inventories);

  @override
  List<Object?> get props => [inventories];
}

class InventoryError extends InventoryState {
  final String error;
  InventoryError(this.error);

  @override
  List<Object?> get props => [error];
}
