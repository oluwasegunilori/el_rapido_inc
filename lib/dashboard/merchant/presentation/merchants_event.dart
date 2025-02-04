import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:el_rapido_inc/merchantinventory/data/model/merchant_inventory.dart';
import 'package:equatable/equatable.dart';

abstract class MerchantEvent extends Equatable {
  const MerchantEvent();

  @override
  List<Object?> get props => [];
}

class CreateMerchantEvent extends MerchantEvent {
  final Merchant merchant;

  const CreateMerchantEvent(this.merchant);

  @override
  List<Object?> get props => [merchant];
}

class FetchMerchantsEvent extends MerchantEvent {}

class UpdateMerchantEvent extends MerchantEvent {
  final Merchant merchant;

  const UpdateMerchantEvent(this.merchant);

  @override
  List<Object?> get props => [merchant];
}

class DeleteMerchantEvent extends MerchantEvent {
  final String merchantId;

  const DeleteMerchantEvent(this.merchantId);

  @override
  List<Object?> get props => [merchantId];
}

class UpdateInventoryListEvent extends MerchantEvent {
  final String merchantId;
  final List<MerchantInventory> inventoryList;

  const UpdateInventoryListEvent(this.merchantId, this.inventoryList);

  @override
  List<Object?> get props => [merchantId, inventoryList];
}

class FetchMerchantsByInventoryIdEvent extends MerchantEvent {
  final String inventoryId;

  const FetchMerchantsByInventoryIdEvent(this.inventoryId);

  @override
  List<Object?> get props => [inventoryId];
}