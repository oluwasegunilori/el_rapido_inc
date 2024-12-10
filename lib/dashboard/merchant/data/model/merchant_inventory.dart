import 'package:equatable/equatable.dart';

class MerchantInventory extends Equatable {
  final String inventoryId;
  final double price;
  final int quantity;

  const MerchantInventory({
    required this.inventoryId,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'inventoryId': inventoryId,
      'price': price,
      'quantity': quantity,
    };
  }

  factory MerchantInventory.fromMap(Map<String, dynamic> map) {
    return MerchantInventory(
      inventoryId: map['inventoryId'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  @override
  List<Object?> get props => [inventoryId, price, quantity];
}
