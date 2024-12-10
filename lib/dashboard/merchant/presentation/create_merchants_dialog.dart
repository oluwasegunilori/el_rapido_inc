import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:flutter/material.dart';

void showCreateMerchantDialog(
  BuildContext context,
  Merchant? merchant,
  Function(Merchant merchant) onAdd,
) {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController =
      TextEditingController(text: merchant?.name);
  final TextEditingController locationController =
      TextEditingController(text: merchant?.location);

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth =
          screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.5;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(merchant == null ? 'Add Merchant' : 'Update Merchant'),
            content: SizedBox(
              width: dialogWidth.clamp(0, 500),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
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
                        validator: (value) => value == null || value.isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Location is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            final newMerchant = Merchant(
                              id: merchant?.id ?? '',
                              name: nameController.text,
                              location: locationController.text,
                              inventoryList: merchant?.inventoryList ?? [],
                            );
                            onAdd(newMerchant);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(merchant == null ? 'Add' : 'Update'),
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
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
