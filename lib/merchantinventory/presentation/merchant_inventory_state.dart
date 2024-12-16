import 'package:el_rapido_inc/merchantinventory/data/model/merchant_inventory.dart';
import 'package:equatable/equatable.dart';

abstract class MerchantInventoryState extends Equatable {
  const MerchantInventoryState();

  @override
  List<Object?> get props => [];
}

class MerchantInventoryInitial extends MerchantInventoryState {}

class MerchantInventoryLoading extends MerchantInventoryState {}

class MerchantInventorySuccess extends MerchantInventoryState {
  final List<MerchantInventory> inventories;

  const MerchantInventorySuccess(this.inventories);

  @override
  List<Object?> get props => [inventories];
}

class MerchantInventoryFailure extends MerchantInventoryState {
  final String errorMessage;

  const MerchantInventoryFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class MerchantInventoryOperationSuccess extends MerchantInventoryState {
  const MerchantInventoryOperationSuccess();
}
