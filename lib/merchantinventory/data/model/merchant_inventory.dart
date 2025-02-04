import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';


enum InventoryStatus {
  started,
  completed,
}

class MerchantInventory extends Equatable {
  final String id;
  final String inventoryId;
  final String merchantId;
  final double price;
  final int quantity;
  final InventoryStatus status;
  final Timestamp? lastUpdated;
  final Timestamp? createdAt;


  const MerchantInventory({
    required this.id,
    required this.inventoryId,
    required this.merchantId,
    required this.price,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inventoryId': inventoryId,
      'merchantId': merchantId,
      'price': price,
      'quantity': quantity,
      'status': status.name, // Store the status as a string
      'lastUpdated': Timestamp.now(),
    };
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'id': const Uuid().v4(),
      'inventoryId': inventoryId,
      'merchantId': merchantId,
      'price': price,
      'quantity': quantity,
      'status': status.name,
      'createdAt': Timestamp.now(),
      'lastUpdated': Timestamp.now(),
    };
  }

  factory MerchantInventory.fromMap(Map<String, dynamic> map) {
    return MerchantInventory(
      id: map['id'],
      inventoryId: map['inventoryId'],
      merchantId: map['merchantId'],
      price: map['price'],
      quantity: map['quantity'],
      status: InventoryStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => InventoryStatus.started), // Fallback to `started`
      lastUpdated: map['lastUpdated'] as Timestamp? ?? Timestamp.now(),
      createdAt: map['lastUpdated'] as Timestamp? ?? Timestamp.now(),
    );
  }

  @override
  List<Object?> get props => [id, inventoryId, merchantId, price, quantity, status, createdAt, lastUpdated];
}
