import 'package:equatable/equatable.dart';

class Merchant extends Equatable {
  final String id;
  final String name;
  final String location;

  const Merchant({
    required this.id,
    required this.name,
    required this.location,
  });

  @override
  List<Object?> get props => [id, name, location];

  Merchant copyWith({
    String? id,
    String? name,
    String? location,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }
}
