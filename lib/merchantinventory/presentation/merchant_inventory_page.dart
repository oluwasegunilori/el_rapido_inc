import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_bloc.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_event.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_state.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_bloc.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_event.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_state.dart';
import 'package:el_rapido_inc/dashboard/transaction/data/model/transaction_model.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_bloc.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_event.dart';
import 'package:el_rapido_inc/merchantinventory/data/model/merchant_inventory.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/create_merchant_inventory_dialog.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_bloc.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_event.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_grid/responsive_grid.dart';

class MerchantInventoryPage extends StatefulWidget {
  final String merchantId;
  const MerchantInventoryPage({super.key, required this.merchantId});

  @override
  _MerchantInventoryPageState createState() => _MerchantInventoryPageState();
}

class _MerchantInventoryPageState extends State<MerchantInventoryPage> {
  String? selectedMerchantId;
  String? selectedInventoryId;
  final merchantIventoryBloc = getIt<MerchantInventoryBloc>();
  List<Inventory> cachedInventories = [];
  List<Merchant?> cachedMerchants = [];

  @override
  void initState() {
    super.initState();
    merchantIventoryBloc
        .add(FetchMerchantInventoriesByMerchantId(widget.merchantId));
    InventoryBloc inventoryBloc = BlocProvider.of<InventoryBloc>(context);
    if (inventoryBloc.state is! InventoryLoaded) {
      inventoryBloc.add(LoadInventories());
    } else {
      cachedInventories = (inventoryBloc.state as InventoryLoaded).inventories;
    }

    MerchantBloc merchantBloc = BlocProvider.of<MerchantBloc>(context);
    if (merchantBloc.state is! MerchantSuccessState) {
      merchantBloc.add(FetchMerchantsEvent());
    } else {
      cachedMerchants =
          (merchantBloc.state as MerchantSuccessState).merchants ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => merchantIventoryBloc,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Merchant Inventory'),
            elevation: 5,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MultiBlocListener(
                          listeners: [
                            BlocListener<InventoryBloc, InventoryState>(
                              listener: (context, state) {
                                if (state is InventoryLoaded) {
                                  setState(() {
                                    cachedInventories = state.inventories;
                                  });
                                }
                              },
                            ),
                            BlocListener<MerchantBloc, MerchantState>(
                              listener: (context, state) {
                                if (state is MerchantSuccessState) {
                                  setState(() {
                                    cachedMerchants = state.merchants ?? [];
                                  });
                                }
                              },
                            ),
                          ],
                          child: const Center(),
                        ),
                        BlocBuilder<MerchantBloc, MerchantState>(
                          builder: (context, state) {
                            if (state is MerchantSuccessState) {
                              Merchant? merchant = state.merchants?.firstWhere(
                                  (e) => e.id == widget.merchantId);
                              if (merchant != null) {
                                return Center(
                                    child: _buildMerchantDetails(merchant));
                              }
                            }
                            return const Center();
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: BlocBuilder<MerchantInventoryBloc,
                              MerchantInventoryState>(
                            builder: (context, state) {
                              InventoryBloc inventoryBloc =
                                  BlocProvider.of<InventoryBloc>(context);
                              if (state is MerchantInventorySuccess &&
                                  inventoryBloc.state is InventoryLoaded) {
                                if (state.inventories.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "No assigned inventory",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    // Inventories List
                                    Expanded(
                                        child: ResponsiveGridList(
                                      desiredItemWidth: 300,
                                      children: state.inventories.map((invs) {
                                        final inventory = (inventoryBloc.state
                                                as InventoryLoaded)
                                            .inventories
                                            .firstWhere((e) =>
                                                e.id == invs.inventoryId);
                                        return _buildInventoryItem(
                                            inventory, invs);
                                      }).toList(),
                                    )),
                                    const SizedBox(height: 16),

                                    // Dropdown for Merchants
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              MerchantInventoryState state = merchantIventoryBloc.state;
              if (state is MerchantInventorySuccess) {
                Merchant? merchant = cachedMerchants.firstWhere(
                  (e) => e?.id == widget.merchantId,
                );
                if (merchant != null) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BlocProvider.value(
                          value: merchantIventoryBloc, // Pass the existing bloc
                          child: MerchantInventoryDialog(
                              inventoryList: cachedInventories
                                  .where((e) => !state.inventories
                                      .map((e) => e.inventoryId)
                                      .contains(e.id))
                                  .toList(),
                              merchant: merchant),
                        );
                      });
                }
              }
            },
            child: const Icon(Icons.add),
          )),
    );
  }

  Widget _buildMerchantDetails(Merchant merchant) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${merchant.name}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Location: ${merchant.location}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryItem(
      Inventory inventory, MerchantInventory merchantInventory) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    return Column(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with label styled differently
                    Row(
                      children: [
                        Text(
                          'Name: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .primaryColor, // Primary color for label
                          ),
                        ),
                        Text(
                          inventory.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // Price with label styled differently
                    Row(
                      children: [
                        Text(
                          'Price: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .primaryColor, // Primary color for label
                          ),
                        ),
                        Text(
                          '\$${inventory.costPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    // Quantity Available with label styled differently
                    Row(
                      children: [
                        Text(
                          'Quantity Available: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .primaryColor, // Primary color for label
                          ),
                        ),
                        Text(
                          '${merchantInventory.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                // Popup Menu Button
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'updateQuantity') {
                      _showQuantityDialog(context, merchantInventory);
                    } else if (value == 'updatePrice') {
                      _showPriceDialog(context, merchantInventory);
                    } else if (value == 'createTransaction') {
                      _showAddTransactionDialog(
                          context, inventory, merchantInventory);
                    } else if (value == 'returnInventory') {
                      _showQuantityDialog(context, merchantInventory);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'updateQuantity',
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Add Quantity'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'updatePrice',
                      child: Row(
                        children: [
                          Icon(Icons.money),
                          SizedBox(width: 8),
                          Text('Update Price'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'createTransaction',
                      child: Row(
                        children: [
                          Icon(Icons.trending_up),
                          SizedBox(width: 8),
                          Text('Create transaction'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'returnInventory',
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2),
                          SizedBox(width: 8),
                          Text('Return Inventory'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void _showQuantityDialog(
      BuildContext context, MerchantInventory merchantInventory,
      {bool isReturn = false}) {
    final TextEditingController quantityController =
        TextEditingController(text: merchantInventory.quantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isReturn != true ? 'Add Quantity' : "Return Inventory"),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
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
                int? updatedQuantity = int.tryParse(quantityController.text);
                if (updatedQuantity != null) {
                  // Handle update logic for quantity
                  print("Updated quantity: $updatedQuantity");
                  if (isReturn) {
                    updatedQuantity = -updatedQuantity;
                  }
                  merchantIventoryBloc.add(UpdateMerchantInventoryQuantity(
                      merchantInventory, updatedQuantity));
                  // Add the update logic here, such as sending the updated quantity to Firestore
                }
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context, Inventory inventory,
      MerchantInventory merchantInventory) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController wholeDiscountController =
        TextEditingController();
    double percentageDiscount = 0.0;
    bool isWholeDiscount = true;
    TransactionType selectedTransactionType = TransactionType.Cash;

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Transaction'),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity.';
                        }
                        final int? enteredQuantity = int.tryParse(value);
                        if (enteredQuantity == null) {
                          return 'Please enter a valid number.';
                        }
                        if (enteredQuantity > merchantInventory.quantity) {
                          return 'Quantity cannot exceed ${merchantInventory.quantity}.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price.';
                        }
                        final double? enteredPrice = double.tryParse(value);
                        if (enteredPrice == null) {
                          return 'Please enter a valid number.';
                        }
                        return null;
                      },
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
                              });
                            },
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
                      final double transactionPrice =
                          double.parse(priceController.text);
                      double discount = 0.0;

                      if (isWholeDiscount) {
                        discount =
                            double.tryParse(wholeDiscountController.text) ??
                                0.0;
                      } else {
                        discount = (percentageDiscount / 100) *
                            (transactionPrice * updatedQuantity);
                      }

                      final priceWithoutTax =
                          (transactionPrice * updatedQuantity) - discount;

                      final double totalPrice =
                          priceWithoutTax + (priceWithoutTax * 0.13);

                      BlocProvider.of<TransactionBloc>(context).add(
                        CreateTransaction(
                          Transaction(
                            id: "",
                            merchantId: merchantInventory.merchantId,
                            inventoryId: merchantInventory.inventoryId,
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

                      getIt.get<MerchantInventoryBloc>().add(
                            ReduceMerchantInventoryQuantityEvent(
                              merchantInventoryId: merchantInventory.id,
                              quantity: updatedQuantity,
                            ),
                          );

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

  void _showPriceDialog(
      BuildContext context, MerchantInventory merchantInventory) {
    final TextEditingController priceController =
        TextEditingController(text: merchantInventory.price.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Price'),
          content: TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+\.?\d{0,2}')), // Allows up to two decimals
            ],
            decoration: const InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(),
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
                double? updatedPrice = double.tryParse(priceController.text);
                if (updatedPrice != null) {
                  // Handle update logic for price
                  print("Updated price: \$${updatedPrice.toStringAsFixed(2)}");
                  // Add the update logic here, such as sending the updated price to Firestore
                }
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<Merchant> fetchMerchantDetails(String merchantId) async {
    // Fetch merchant details by ID
    return Merchant(
      id: merchantId,
      name: 'Sample Merchant',
      location: 'Sample Location',
    );
  }

  void assignInventoryToMerchant(
      String inventoryId, String merchantId, int quantity) {
    // Handle assignment logic
  }
}
