import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:el_rapido_inc/merchantinventory/data/model/merchant_inventory.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_bloc.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MerchantInventoryDialog extends StatefulWidget {
  final List<Inventory> inventoryList;
  final Merchant merchant;

  const MerchantInventoryDialog({
    Key? key,
    required this.inventoryList,
    required this.merchant,
  }) : super(key: key);

  @override
  State<MerchantInventoryDialog> createState() =>
      _MerchantInventoryDialogState();
}

class _MerchantInventoryDialogState extends State<MerchantInventoryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Inventory? selectedInventory;
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth =
        screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.4;

    return AlertDialog(
      title: Text("Add Quantity to ${widget.merchant.name}"),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Searchable dropdown for selecting an inventory item
                DropdownSearch<Inventory>(
                  items: (filter, infiniteScrollPops) => widget.inventoryList,
                  itemAsString: (Inventory inventory) =>
                      "${inventory.name} \nRemaining:  ${inventory.quantity}",
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: "Select Inventory ",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (Inventory? value) {
                    setState(() {
                      selectedInventory = value;
                    });
                  },
                  selectedItem: selectedInventory,
                  validator: (value) =>
                      value == null ? "Please select an inventory" : null,
                  compareFn: (item1, item2) => item1 == item2,
                  filterFn: (item, filter) {
                    return item.name.contains(filter);
                  },
                  popupProps: const PopupProps.menu(
                      showSearchBox: true, searchDelay: Duration.zero),
                ),
                const SizedBox(height: 16.0),
                // TextField for entering quantity
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Quantity",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Quantity is required";
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity <= 0) {
                      return "Enter a valid quantity";
                    } else if (selectedInventory != null &&
                        quantity > selectedInventory!.quantity) {
                      return "Quantity cannot be more than the remaining quantity for ${selectedInventory?.name}";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              final int quantity = int.parse(quantityController.text);
              BlocProvider.of<MerchantInventoryBloc>(context).add(
                CreateMerchantInventory(
                  MerchantInventory(
                    id: "",
                    inventoryId: selectedInventory!.id,
                    merchantId: widget.merchant.id,
                    price: selectedInventory!.price,
                    quantity: quantity,
                    status: InventoryStatus.started,
                    createdAt: Timestamp.now(),
                    lastUpdated: Timestamp.now(),
                  ),
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
