import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/create_inventory_dialog.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/list/inventory_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'inventory_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    InventoryBloc inventoryBloc = getIt<InventoryBloc>();
    inventoryBloc.add(LoadInventories());

    return BlocProvider(
      create: (context) => inventoryBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Inventories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          elevation: 4,
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InventoryLoaded) {
              return ResponsiveGridList(
                  desiredItemWidth: 200,
                  children: state.inventories.map((inven) {
                    return InventoryItem(
                      inventory: inven,
                      onEdit: () {
                        showCreateInventoryDialog(context, inven,
                            (inventoryUpdated) {
                          inventoryBloc.add(UpdateInventory(inventoryUpdated));
                        });
                      },
                      onDelete: () {},
                    );
                  }).toList());
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
      ),
    );
  }
}
