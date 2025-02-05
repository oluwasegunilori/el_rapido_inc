import 'package:el_rapido_inc/core/data/model/user.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:el_rapido_inc/dashboard/transaction/data/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showTransactionDetails(BuildContext context, Transaction transaction, Merchant merchant, Inventory inventory, User createdBy) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Transaction Details", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Merchant", merchant.name),
            _buildDetailRow("Location", merchant.location),
            _buildDivider(),
            _buildDetailRow("Inventory", inventory.name),
            _buildDetailRow("Quantity Available", inventory.quantity.toString()),
            _buildDetailRow("Inventory Price", "\$${inventory.price.toStringAsFixed(2)}"),
            _buildDivider(),
            _buildDetailRow("Transaction Quantity", transaction.quantity.toString()),
            _buildDetailRow("Price per Unit", "\$${transaction.price.toStringAsFixed(2)}"),
            _buildDetailRow("Total Price", "\$${transaction.totalPrice.toStringAsFixed(2)}"),
            _buildDetailRow("Date", _formatDate(transaction.date)),
            _buildDetailRow("Created By", "${createdBy.firstName} ${createdBy.lastName}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(value, style: const TextStyle(color: Colors.black87))),
      ],
    ),
  );
}

Widget _buildDivider() {
  return Divider(color: Colors.grey.shade300, thickness: 1);
}

String _formatDate(DateTime date) {
  return DateFormat("dd MMM yyyy, hh:mm a").format(date);
}
