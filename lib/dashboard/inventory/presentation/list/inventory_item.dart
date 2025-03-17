import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:flutter/material.dart';

class InventoryItem extends StatelessWidget {
  final Inventory inventory;
  final VoidCallback onEdit;
  final VoidCallback onManageMerchants;
  final VoidCallback onSellDirectlyToCustomer;
  final VoidCallback onClick;

  const InventoryItem({
    super.key,
    required this.inventory,
    required this.onEdit,
    required this.onManageMerchants,
    required this.onSellDirectlyToCustomer,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        child: Stack(
          children: [
            Padding(
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
                            height: 150,
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
                      'Selling Price: \$${inventory.sellingPrice}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'merchants':
                      onManageMerchants();
                      break;
                    case 'createTransaction':
                      onSellDirectlyToCustomer();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                      value: "merchants", child: Text("Merchants")),
                  const PopupMenuItem(
                      value: "createTransaction",
                      child: Text("Create Transaction")),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
        onTap: () {
          onClick();
        },
      ),
    );
  }
}
