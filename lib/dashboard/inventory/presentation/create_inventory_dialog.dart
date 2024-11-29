import 'dart:math';

import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:flutter/material.dart';

void showCreateInventoryDialog(
  BuildContext context,
  Function(Inventory inventory) onAdd,
) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth = screenWidth < 600
          ? screenWidth * 0.9 // 90% width for mobile devices
          : screenWidth * 0.5; // 50% width for desktop devices
      return AlertDialog(
        title: const Text('Add Inventory'),
        content: SizedBox(
          width: min(dialogWidth, 500),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red), // Red cancel text
            ),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final inventory = Inventory(
                  id: '',
                  name: nameController.text,
                  quantity: int.parse(quantityController.text),
                  price: double.parse(priceController.text),
                  description: descriptionController.text,
                );
                onAdd(inventory);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
