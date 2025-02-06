import 'package:data_table_2/data_table_2.dart';
import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_bloc.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_event.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_state.dart';
import 'package:el_rapido_inc/merchantinventory/data/model/merchant_inventory.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_bloc.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_event.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MerchantsUnderInventory extends StatelessWidget {
  final String inventoryId;

  MerchantInventoryBloc merchantInventoryBloc = getIt<MerchantInventoryBloc>();

  MerchantsUnderInventory({super.key, required this.inventoryId});

  @override
  Widget build(BuildContext context) {
    merchantInventoryBloc
        .add(FetchMerchantInventoriesByInventoryId(inventoryId));
    return BlocProvider<MerchantInventoryBloc>(
      create: (context) => merchantInventoryBloc,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), // Adjust height as needed
          child: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Merchants - ", style: TextStyle(fontSize: 18)),
              ],
            ),
            elevation: 4,
          ),
        ),
        body: BlocBuilder<MerchantInventoryBloc, MerchantInventoryState>(
          builder: (context, state) {
            if (state is! MerchantInventorySuccess) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return _buildDataTable(state, context);
          },
        ),
      ),
    );
  }

  DataColumn2 dataColumnGen(String label) => DataColumn2(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildDataTable(MerchantInventorySuccess state, BuildContext context) {
    MerchantBloc merchantBloc = context.watch<MerchantBloc>();
    if (merchantBloc.state is! MerchantSuccessState) {
      merchantBloc.add(FetchMerchantsEvent());
      return const Center();
    }
    MerchantSuccessState merchantState =
        merchantBloc.state as MerchantSuccessState;

    return SizedBox(
      height: 1000,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
          border: TableBorder.all(color: Colors.grey, width: 1),
          columns: [
            "Name",
            "Quantity Remaining",
            "Price",
            "Total Price",
            "Last Updated",
            "Actions",
          ].map((e) => dataColumnGen(e)).toList(),
          rows: state.inventories
              .where((inv) =>
                  inv.inventoryId == inventoryId &&
                  inv.status != InventoryStatus.completed)
              .map((inv) {
            Merchant merchant = merchantState.merchants!
                .firstWhere((e) => e.id == inv.merchantId);

            return DataRow(
              cells: [
                DataCell(Text(merchant.name)),
                DataCell(Text(inv.quantity.toString())),
                DataCell(Text(inv.price.toString())),
                DataCell(Text((inv.price * inv.quantity).toString())),
                DataCell(Text(DateFormat("MMM dd, yyyy")
                    .format(inv.lastUpdated!.toDate()))),
                DataCell(
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'clear':
                          merchantInventoryBloc.add(
                              ClearQuantitiesEvent(merchantInventory: inv));
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'clear',
                        child: Text('Clear Quantity'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
