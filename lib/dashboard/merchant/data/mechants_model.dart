import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:equatable/equatable.dart';

class Merchants extends Equatable {
  final String id;
  final String name;
  final String location;
  final List<Inventory> inventoryList;

  const Merchants({
    required this.id,
    required this.name,
    required this.location,
    required this.inventoryList,
  });

  @override
  List<Object?> get props => [id, name, location, inventoryList];

  Merchants copyWith({
    String? id,
    String? name,
    String? location,
    List<Inventory>? inventoryList,
  }) {
    return Merchants(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      inventoryList: inventoryList ?? this.inventoryList,
    );
  }
}