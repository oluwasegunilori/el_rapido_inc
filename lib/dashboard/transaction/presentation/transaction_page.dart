import 'package:data_table_2/data_table_2.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_bloc.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_state.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_bloc.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_state.dart';
import 'package:el_rapido_inc/dashboard/transaction/data/model/transaction_model.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_bloc.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_event.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TransactionBloc transactionBloc;
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = "";
  String? selectedSearchOption = "merchant";

  @override
  void initState() {
    super.initState();
    transactionBloc = BlocProvider.of<TransactionBloc>(context);
    transactionBloc.add(FetchTransactions());
    _searchController.addListener(() {
      _filterQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        bloc: transactionBloc,
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            return BlocConsumer<InventoryBloc, InventoryState>(
              listener: (context, state) {},
              builder: (context, stateInv) {
                return BlocBuilder<MerchantBloc, MerchantState>(
                  builder: (context, stateMer) {
                    if (stateMer is MerchantSuccessState &&
                        stateInv is InventoryLoaded) {
                      final transactionsFilt = _filterTransactions(
                        stateInv.inventories,
                        stateMer.merchants ?? [],
                        state.transactions,
                      );
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: _buildGraph(state.transactions)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 400,
                                  child: Column(
                                    children: [
                                      _buildSearchField(
                                        stateInv.inventories,
                                        stateMer.merchants,
                                        transactionsFilt,
                                      ),
                                      Text("Search by"),
                                      _buildDropDown(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 20,
                          ),
                          _buildTransactionTable(
                            context,
                            stateInv.inventories,
                            stateMer.merchants,
                            transactionsFilt,
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              },
            );
          } else if (state is TransactionError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No Transactions Found'));
        },
      ),
    );
  }

  Widget _buildSearchField(
    List<Inventory> inventories,
    List<Merchant>? merchants,
    List<Transaction> transactions,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
                hintText: 'Search ',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                isDense: true, // Reduce size
                border: OutlineInputBorder()),
            onChanged: (value) {
              setState(() {
                _filterQuery = _searchController.text;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGraph(List<Transaction> transactions) {
    // Group transactions by date and calculate total price for each day
    final data = <DateTime, double>{};
    for (var transaction in transactions) {
      final date = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      data[date] = (data[date] ?? 0) + transaction.totalPrice;
    }

    final barGroups = data.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.millisecondsSinceEpoch,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 16,
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: 50),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(
                      "${date.month}/${date.day}",
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                  interval: (data.keys.length / 6).ceil().toDouble(),
                ),
              ),
            ),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTable(
    BuildContext context,
    List<Inventory> inventories,
    List<Merchant>? merchants,
    List<Transaction> transactions,
  ) {
    return Expanded(
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
            "Merchant",
            "Inventory",
            "Quantity",
            "Price",
            "Total Price",
            "Date"
          ].map((e) => dataColumnGen(e)).toList(),
          rows: transactions.map((transaction) {
            String merchantName = merchants!
                .firstWhere((e) => e.id == transaction.merchantId)
                .name;
            String inventoryName = inventories
                .firstWhere((e) => e.id == transaction.inventoryId)
                .name;

            return DataRow(cells: [
              DataCell(Text(merchantName)),
              DataCell(Text(inventoryName)),
              DataCell(Text(transaction.quantity.toString())),
              DataCell(Text('\$${transaction.price.toStringAsFixed(2)}')),
              DataCell(Text('\$${transaction.totalPrice.toStringAsFixed(2)}')),
              DataCell(Text(_formatDate(transaction.date))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  List<Transaction> _filterTransactions(
    List<Inventory> inventories,
    List<Merchant> merchants,
    List<Transaction> transactions,
  ) {
    // final bloc = BlocProvider.of<TransactionBloc>(context);
    // if(selectedSearchOption == "merchant")  {
    //   final merchantId = merchants.where((e) => e.)
    //   bloc.add(FetchTransactions())
    // }
    // bloc.add(FetchTransactions());
    if (_filterQuery.isEmpty) return transactions;

    final transs = transactions.where((transaction) {
      if (selectedSearchOption == "merchant") {
        return merchants.any((e) =>
            e.name.toLowerCase().contains(_filterQuery.toLowerCase()) &&
            e.id == transaction.merchantId);
      }
      return inventories.any((e) =>
          e.name.toLowerCase().contains(_filterQuery.toLowerCase()) &&
          e.id == transaction.inventoryId);
    }).toList();
    return transs;
  }

  /// Helper function to format date
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  DataColumn2 dataColumnGen(String label) => DataColumn2(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildDropDown() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(3)),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: const Text('Search By'),
        value: selectedSearchOption,
        items: const [
          DropdownMenuItem(value: 'merchant', child: Text('Merchant')),
          DropdownMenuItem(value: 'inventory', child: Text('Inventory')),
        ],
        onChanged: (value) {
          setState(() {
            selectedSearchOption = value;
            _searchController.text = "";
          });
        },
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
