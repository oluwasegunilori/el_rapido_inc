import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String merchantId;
  final String inventoryId;
  final DateTime date;
  final int quantity;
  final double price;
  final double totalPrice;
  final String createdBy;

  Transaction({
    required this.id,
    required this.merchantId,
    required this.inventoryId,
    required this.date,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.createdBy,
  });

  factory Transaction.fromMap(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'],
      merchantId: data['merchantId'],
      inventoryId: data['inventoryId'],
      date: DateTime.parse(data['date']),
      quantity: data['quantity'],
      price: data['price'],
      totalPrice: data['totalPrice'],
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchantId': merchantId,
      'inventoryId': inventoryId,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
      'createdBy': createdBy,
    };
  }

  Transaction copyWith({
    String? id,
    String? merchantId,
    String? inventoryId,
    DateTime? date,
    int? quantity,
    double? price,
    double? totalPrice,
    String? createdBy,
  }) {
    return Transaction(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      inventoryId: inventoryId ?? this.inventoryId,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        merchantId,
        inventoryId,
        date,
        quantity,
        price,
        totalPrice,
        createdBy
      ];
}
