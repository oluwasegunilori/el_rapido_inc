import 'package:el_rapido_inc/auth/presentation/logout.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/create_inventory_dialog.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/list/inventory_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'inventory_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    InventoryBloc inventoryBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
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
}
