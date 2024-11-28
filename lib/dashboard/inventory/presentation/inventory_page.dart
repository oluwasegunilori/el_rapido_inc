import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/create_inventory_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InventoryBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Inventories',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Bold text
              fontSize: 20, // Larger font size if needed
            ),
          ),
          elevation: 4, // Add elevation for a shadow effect
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InventoryLoaded) {
              return ListView.builder(
                itemCount: state.inventories.length,
                itemBuilder: (context, index) {
                  final inventory = state.inventories[index];
                  return ListTile(
                    title: Text(inventory.name),
                    subtitle: Text(
                        'Quantity: ${inventory.quantity}, Price: \$${inventory.price}'),
                  );
                },
              );
            } else if (state is InventoryError) {
              return Center(child: Text(state.error));
            }
            return const Center(child: Text('No data available'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showCreateInventoryDialog(
              context,
              (inventory) =>
                  context.read<InventoryBloc>().add(AddInventory(inventory)),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
