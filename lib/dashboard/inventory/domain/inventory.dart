import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Inventory extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final Timestamp? lastUpdated;
  final String? createdBy;
  final String description;
  final String? imageUrl;

  const Inventory({
    required this.id,
    required this.name,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.description,
    this.imageUrl,
    this.createdBy,
    this.lastUpdated,
  });

  Inventory removeQuantity(int quantity) {
    return Inventory(
      id: id,
      name: name,
      quantity: this.quantity - quantity,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      description: description,
      createdBy: createdBy,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        quantity,
        costPrice,
        sellingPrice,
        lastUpdated,
        createdBy,
        description,
      ];

  @override
  bool get stringify => true;

  /// Factory constructor to create an Inventory instance from a map.
  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      costPrice: (map['costPrice'] as num).toDouble(),
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      lastUpdated: map['lastUpdated'] as Timestamp?,
      createdBy: map['createdBy'] as String?,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
