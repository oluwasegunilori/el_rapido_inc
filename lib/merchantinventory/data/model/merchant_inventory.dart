import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class MerchantInventory extends Equatable {
  final String id;
  final String inventoryId;
  final String merchantId;
  final double price;
  final int quantity;

  const MerchantInventory({
    required this.id,
    required this.inventoryId,
    required this.merchantId,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inventoryId': inventoryId,
      'merchantId' : merchantId,
      'price': price,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'id': const Uuid().v4(),
      'inventoryId': inventoryId,
      'merchantId' : merchantId,
      'price': price,
      'quantity': quantity,
    };
  }

  factory MerchantInventory.fromMap(Map<String, dynamic> map) {
    return MerchantInventory(
      id: map['id'],
      inventoryId: map['inventoryId'],
      merchantId: map['merchantId'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  @override
  List<Object?> get props => [id, inventoryId, merchantId ,price, quantity];
}
