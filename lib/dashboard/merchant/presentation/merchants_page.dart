import 'package:el_rapido_inc/core/app_router.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/create_merchants_dialog.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/list/merchant_item.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_bloc.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_event.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_grid/responsive_grid.dart';

class MerchantPage extends StatelessWidget {
  const MerchantPage({super.key});

  @override
  Widget build(BuildContext context) {
    MerchantBloc merchantBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Merchants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 4,
      ),
      body: BlocBuilder<MerchantBloc, MerchantState>(
        builder: (context, state) {
          if (state is MerchantLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MerchantSuccessState) {
            return ResponsiveGridList(
                desiredItemWidth: 200,
                children: state.merchants?.map((merchant) {
                      return MerchantItem(
                        merchant: merchant,
                        onEdit: () {
                          showCreateMerchantDialog(context, merchant,
                              (merchantUpdated) {
                            merchantBloc
                                .add(UpdateMerchantEvent(merchantUpdated));
                          });
                        },
                        onDelete: () {},
                        onManageInventory: () {
                          context.go("/merchantinventory?merchant_id=${merchant.id}");
                          // Handle inventory management for the merchant
                        },
                      );
                    }).toList() ??
                    []);
          } else if (state is MerchantErrorState) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateMerchantDialog(context, null, (merchant) {
            merchantBloc.add(CreateMerchantEvent(merchant));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
