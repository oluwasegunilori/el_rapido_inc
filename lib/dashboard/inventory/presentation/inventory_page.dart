import 'package:el_rapido_inc/auth/presentation/logout.dart';
import 'package:el_rapido_inc/core/screen_calc.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/create_inventory_dialog.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/list/inventory_item.dart';
import 'package:el_rapido_inc/dashboard/transaction/data/model/transaction_model.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_bloc.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'inventory_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    InventoryBloc inventoryBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: !isMobile(context)
          ? AppBar(
              title: const Text(
                'Inventories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              elevation: 4,
              actions: [
                buildLogoutButton(context),
              ],
            )
          : null,
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context1, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            return ResponsiveGridList(
              desiredItemWidth: 200,
              children: state.inventories.map(
                (inven) {
                  return InventoryItem(
                    inventory: inven,
                    onEdit: () {
                      showCreateInventoryDialog(context, inven,
                          (inventoryUpdated) {
                        inventoryBloc.add(UpdateInventory(inventoryUpdated));
                      });
                    },
                    onManageMerchants: () {
                      context.pushNamed("merchantsunderinventory",
                          pathParameters: {"inventoryId": inven.id});
                    },
                    onSellDirectlyToCustomer: () {
                      _showAddTransactionDialog(context, inven);
                    },
                    onClick: () {},
                  );
                },
              ).toList(),
            );
          } else if (state is InventoryError) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text('No data available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateInventoryDialog(context, null, (inventory) {
            inventoryBloc.add(AddInventory(inventory));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.hidden) {}
  }
}

void _showAddTransactionDialog(
  BuildContext context,
  Inventory inventory,
) {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController =
      TextEditingController(text: inventory.sellingPrice.toString());
  final TextEditingController wholeDiscountController = TextEditingController();
  final TextEditingController pricePlusDiscountController =
      TextEditingController();

  double percentageDiscount = 0.0;
  bool isWholeDiscount = true;
  TransactionType selectedTransactionType = TransactionType.Cash;
  final _formKey = GlobalKey<FormState>();

  void updatePricePlusDiscount() {
    double transactionPrice = inventory.sellingPrice;
    int quantity = int.tryParse(quantityController.text) ?? 0;
    double discount = isWholeDiscount
        ? (double.tryParse(wholeDiscountController.text) ?? 0.0)
        : (percentageDiscount / 100) * (transactionPrice * quantity);
    double totalPrice = (transactionPrice * quantity) - discount;

    pricePlusDiscountController.text =
        (totalPrice + totalPrice * 0.13).toStringAsFixed(2);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      updatePricePlusDiscount();
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Transaction Directly to Consumer'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(inventory.name),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<TransactionType>(
                    value: selectedTransactionType,
                    decoration: const InputDecoration(
                      labelText: 'Transaction Type',
                      border: OutlineInputBorder(),
                    ),
                    items: TransactionType.values.map((TransactionType type) {
                      return DropdownMenuItem<TransactionType>(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (TransactionType? newValue) {
                      setState(() {
                        selectedTransactionType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(updatePricePlusDiscount);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity.';
                      }
                      final int? enteredQuantity = int.tryParse(value);
                      if (enteredQuantity == null) {
                        return 'Please enter a valid number.';
                      }
                      if (enteredQuantity > inventory.quantity) {
                        return 'Quantity cannot exceed ${inventory.quantity}.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: priceController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Text('Discount Type:'),
                      Switch(
                        value: isWholeDiscount,
                        onChanged: (value) {
                          setState(() {
                            isWholeDiscount = value;
                            updatePricePlusDiscount();
                          });
                        },
                      ),
                      Text(isWholeDiscount ? 'Whole Discount' : 'Percentage'),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  isWholeDiscount
                      ? TextFormField(
                          controller: wholeDiscountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Whole Discount',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(updatePricePlusDiscount);
                          },
                        )
                      : Slider(
                          value: percentageDiscount,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: '${percentageDiscount.toStringAsFixed(0)}%',
                          onChanged: (value) {
                            setState(() {
                              percentageDiscount = value;
                              updatePricePlusDiscount();
                            });
                          },
                        ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: pricePlusDiscountController,
                    readOnly: true,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Final Price + tax',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final int updatedQuantity =
                        int.parse(quantityController.text);
                    final double transactionPrice = inventory.sellingPrice;
                    double discount = isWholeDiscount
                        ? (double.tryParse(wholeDiscountController.text) ?? 0.0)
                        : (percentageDiscount / 100) *
                            (transactionPrice * updatedQuantity);
                    final double priceBeforeTax =
                        (transactionPrice * updatedQuantity) - discount;
                    final totalPrice = priceBeforeTax + (priceBeforeTax * 0.13);

                    BlocProvider.of<TransactionBloc>(context).add(
                      CreateTransaction(
                        Transaction(
                          id: "",
                          merchantId: "a7657de0-3280-4884-9258-80358d83a05e",
                          inventoryId: inventory.id,
                          date: DateTime.now(),
                          quantity: updatedQuantity,
                          costPrice: inventory.costPrice,
                          price: transactionPrice,
                          totalPrice: totalPrice,
                          discount: discount,
                          discountType: isWholeDiscount
                              ? DiscountType.Whole
                              : DiscountType.Percentage,
                          createdBy: "",
                          transactionType: selectedTransactionType,
                        ),
                      ),
                    );

                    InventoryBloc inventoryBloc = BlocProvider.of(context);
                    final newInventory =
                        inventory.removeQuantity(updatedQuantity);
                    inventoryBloc.add(UpdateInventory(newInventory));

                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
    },
  );
}
