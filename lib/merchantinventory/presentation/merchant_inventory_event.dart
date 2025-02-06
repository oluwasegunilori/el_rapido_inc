import 'package:el_rapido_inc/merchantinventory/data/model/merchant_inventory.dart';
import 'package:equatable/equatable.dart';

abstract class MerchantInventoryEvent extends Equatable {
  const MerchantInventoryEvent();

  @override
  List<Object?> get props => [];
}

class CreateMerchantInventory extends MerchantInventoryEvent {
  final MerchantInventory inventory;

  const CreateMerchantInventory(this.inventory);

  @override
  List<Object?> get props => [inventory];
}

class UpdateMerchantInventoryQuantity extends MerchantInventoryEvent {
  final MerchantInventory merchantInventory;
  final int newQuantity;

  const UpdateMerchantInventoryQuantity(this.merchantInventory, this.newQuantity);

  @override
  List<Object?> get props => [merchantInventory, newQuantity];
}

class UpdateMerchantInventoryPrice extends MerchantInventoryEvent {
  final String inventoryId;
  final double newPrice;

  const UpdateMerchantInventoryPrice(this.inventoryId, this.newPrice);

  @override
  List<Object?> get props => [inventoryId, newPrice];
}

class FetchMerchantInventoriesByMerchantAndInventoryIds
    extends MerchantInventoryEvent {
  final String merchantId;
  final String inventoryId;

  const FetchMerchantInventoriesByMerchantAndInventoryIds(
      this.merchantId, this.inventoryId);

  @override
  List<Object?> get props => [merchantId, inventoryId];
}

class FetchMerchantInventoriesByMerchantId extends MerchantInventoryEvent {
  final String merchantId;

  const FetchMerchantInventoriesByMerchantId(this.merchantId);

  @override
  List<Object?> get props => [merchantId];
}

class FetchMerchantInventoriesByInventoryId extends MerchantInventoryEvent {
  final String inventoryId;

  const FetchMerchantInventoriesByInventoryId(this.inventoryId);

  @override
  List<Object?> get props => [inventoryId];
}

class ReduceMerchantInventoryQuantityEvent extends MerchantInventoryEvent {
  final String merchantInventoryId;
  final int quantity;

  const ReduceMerchantInventoryQuantityEvent(
      {required this.merchantInventoryId, required this.quantity});

  @override
  List<Object?> get props => [merchantInventoryId, quantity];
}

class ClearQuantitiesEvent extends MerchantInventoryEvent {
  final MerchantInventory merchantInventory;

  const ClearQuantitiesEvent({required this.merchantInventory});

  @override
  List<Object?> get props => [merchantInventory];

}
