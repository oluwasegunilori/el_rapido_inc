import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:flutter/material.dart';

class InventoryItem extends StatelessWidget {
  final Inventory inventory;
  InventoryItem({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: inventory.imageUrl?.isNotEmpty == true
                  ? Image.network(
                      inventory.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                inventory.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Quantity: ${inventory.quantity}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Price: \$${inventory.price}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}