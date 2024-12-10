import 'package:el_rapido_inc/dashboard/merchant/data/model/merchant_inventory.dart';
import 'package:equatable/equatable.dart';

class Merchant extends Equatable {
  final String id;
  final String name;
  final String location;
  final List<MerchantInventory> inventoryList;

  const Merchant({
    required this.id,
    required this.name,
    required this.location,
    required this.inventoryList,
  });

  @override
  List<Object?> get props => [id, name, location, inventoryList];

  Merchant copyWith({
    String? id,
    String? name,
    String? location,
    List<MerchantInventory>? inventoryList,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      inventoryList: inventoryList ?? this.inventoryList,
    );
  }
}
