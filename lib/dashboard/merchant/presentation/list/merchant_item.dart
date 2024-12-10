import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:flutter/material.dart';

class MerchantItem extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageInventory;

  const MerchantItem({
    super.key,
    required this.merchant,
    required this.onEdit,
    required this.onDelete,
    required this.onManageInventory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    merchant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    merchant.location,
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
                  case 'delete':
                    onDelete();
                    break;
                  case 'inventory':
                    onManageInventory();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
                const PopupMenuItem(
                  value: "inventory",
                  child: Text("Manage Inventory"),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}
