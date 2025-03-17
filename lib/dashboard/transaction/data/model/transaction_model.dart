import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String merchantId;
  final String inventoryId;
  final DateTime date;
  final int quantity;
  final double costPrice;
  final double price;
  final double totalPrice;
  final double discount;
  final DiscountType discountType;
  final TransactionType transactionType;
  final String createdBy;

  Transaction({
    required this.id,
    required this.merchantId,
    required this.inventoryId,
    required this.date,
    required this.quantity,
    required this.costPrice,
    required this.price,
    required this.totalPrice,
    required this.discount,
    required this.discountType,
    required this.transactionType,
    required this.createdBy,
  });

  factory Transaction.fromMap(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'],
      merchantId: data['merchantId'],
      inventoryId: data['inventoryId'],
      date: DateTime.parse(data['date']),
      quantity: data['quantity'],
      costPrice: data['costPrice'],
      price: data['price'],
      totalPrice: data['totalPrice'],
      discount: data['discount'],
      discountType: DiscountType.values.firstWhere(
        (d) => d.name == data['discountType'],
        orElse: () => DiscountType.Whole,
      ),
      transactionType: TransactionType.values.firstWhere(
        (t) => t.name == data['transactionType'],
        orElse: () => TransactionType.Cash,
      ),
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
      'costPrice' : costPrice,
      'price': price,
      'totalPrice': totalPrice,
      'discount': discount,
      'discountType': discountType.name,
      'transactionType': transactionType.name,
      'createdBy': createdBy,
    };
  }

  Transaction copyWith({
    String? id,
    String? merchantId,
    String? inventoryId,
    DateTime? date,
    int? quantity,
    double? costPrice,
    double? price,
    double? totalPrice,
    double? discount,
    DiscountType? discountType,
    TransactionType? transactionType,
    String? createdBy,
  }) {
    return Transaction(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      inventoryId: inventoryId ?? this.inventoryId,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      transactionType: transactionType ?? this.transactionType,
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
        costPrice,
        price,
        totalPrice,
        discount,
        discountType,
        transactionType,
        createdBy
      ];
}

enum DiscountType {
  Whole,
  Percentage;
}

enum TransactionType {
  Cash,
  CreditorDebit,
  Etransfer,
}
