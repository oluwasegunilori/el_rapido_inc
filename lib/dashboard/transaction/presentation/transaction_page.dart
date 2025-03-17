import 'package:data_table_2/data_table_2.dart';
import 'package:el_rapido_inc/auth/presentation/logout.dart';
import 'package:el_rapido_inc/core/data/model/user.dart';
import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:el_rapido_inc/core/screen_calc.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_bloc.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_state.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_bloc.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_state.dart';
import 'package:el_rapido_inc/dashboard/transaction/data/model/transaction_model.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/show_transactions_dialog.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_bloc.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_event.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_state.dart';
import 'package:el_rapido_inc/dashboard/user/core/excel_export.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_bloc.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_event.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_state.dart';
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
  late UserBloc userBloc;
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = "";
  String? selectedSearchOption = "merchant";
  User? selectedCreatedByOption;

  bool _isChartVisible = false;
  DateTimeRange? _selectedRange;

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange,
    );

    if (picked != null) {
      transactionBloc.add(FetchTransactions(dateRange: picked));
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  String _formatDateRange() {
    if (_selectedRange == null) return "No date selected";

    String start = DateFormat("MMM dd, yyyy").format(_selectedRange!.start);
    String end = DateFormat("MMM dd, yyyy").format(_selectedRange!.end);

    return "$start - $end";
  }

  @override
  void initState() {
    super.initState();
    userBloc = getIt<UserBloc>();
    transactionBloc = BlocProvider.of<TransactionBloc>(context);
    transactionBloc.add(FetchTransactions(dateRange: getLastTwoMonthsRange()));
    userBloc.add(FetchUsers());
    _selectedRange = getLastTwoMonthsRange();
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
      appBar: !isMobile(context)
          ? AppBar(
              title: const Text('Transactions'),
              actions: [buildLogoutButton(context)],
              elevation: 4,
            )
          : null,
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
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Column(
                              children: [
                                SwitchListTile(
                                  title: const Text('Show Chart'),
                                  value: _isChartVisible,
                                  onChanged: (value) {
                                    setState(() {
                                      _isChartVisible = value;
                                    });
                                  },
                                ),
                                const Divider()
                              ],
                            ),
                            if (!isMobile(context)) ...[
                              Row(
                                children: [
                                  Expanded(flex: 1, child: graphWidget(state)),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 400,
                                      child: Column(
                                        children: [
                                          const Text("Search by"),
                                          _buildSearchByDropDown(),
                                          const Text("Created by"),
                                          _buildCreatedByDropDown(),
                                          _buildSearchField(
                                            stateInv.inventories,
                                            stateMer.merchants,
                                            transactionsFilt,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ] else ...[
                              const SizedBox(
                                height: 10,
                              ),
                              graphWidget(state),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Search by"),
                              _buildSearchByDropDown(),
                              const Text("Created by"),
                              _buildCreatedByDropDown(),
                              _buildSearchField(
                                stateInv.inventories,
                                stateMer.merchants,
                                transactionsFilt,
                              ),
                            ],
                            const Divider(),
                            const SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: const ButtonStyle(
                                    textStyle: WidgetStatePropertyAll(TextStyle(
                                        fontWeight: FontWeight.bold))),
                                onPressed: () async {
                                  exportToExcel(transactionsFilt,
                                      stateInv.inventories, stateMer.merchants);
                                },
                                child: const Text("Export to Excel"),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            _buildTransactionTable(
                              context,
                              stateInv.inventories,
                              stateMer.merchants,
                              transactionsFilt,
                            ),
                          ],
                        ),
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

  Widget graphWidget(TransactionLoaded state) {
    return Visibility(
      visible: _isChartVisible,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _pickDateRange,
            child: Text(_selectedRange != null
                ? _formatDateRange()
                : "Select Date Range"),
          ),
          const SizedBox(height: 5),
          _buildGraph(state.transactions),
        ],
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
                hintText: 'Search for....',
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
    // Group transactions by week and calculate total price for each week
    final weeklyData = <DateTime, double>{};
    for (var transaction in transactions) {
      final weekStart = transaction.date
          .subtract(Duration(days: transaction.date.weekday - 1));
      final weekKey = DateTime(weekStart.year, weekStart.month, weekStart.day);
      weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + transaction.totalPrice;
    }

    // Convert Map<DateTime, double> to sorted list of FlSpot
    final sortedEntries = weeklyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Normalize DateTime to sequential index for x-axis
    final List<FlSpot> dataPoints = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LineChart(
          LineChartData(
            minY: 0,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 800,
                  getTitlesWidget: (value, meta) {
                    return Text('\$${value.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final weekLabel = DateFormat('MMM d')
                        .format(sortedEntries[value.toInt()].key);
                    return Text(weekLabel,
                        style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(
              border:
                  Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: dataPoints,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                    show: true, color: Colors.blue.withOpacity(0.2)),
                dotData: const FlDotData(show: false),
              ),
            ],
            clipData: const FlClipData.all(),
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
            "Merchant",
            "Inventory",
            "Quantity",
            "Price",
            "Total Price",
            "Date",
            "Actions"
          ].map((e) => dataColumnGen(e)).toList(),
          rows: transactions.map((transaction) {
            String merchantName = merchants!
                .firstWhere((e) => e.id == transaction.merchantId)
                .name;
            String inventoryName = inventories
                .firstWhere((e) => e.id == transaction.inventoryId)
                .name;

            return DataRow(
              cells: [
                DataCell(Text(merchantName)),
                DataCell(Text(inventoryName)),
                DataCell(Text(transaction.quantity.toString())),
                DataCell(Text('\$${transaction.price.toStringAsFixed(2)}')),
                DataCell(
                    Text('\$${transaction.totalPrice.toStringAsFixed(2)}')),
                DataCell(Text(_formatDate(transaction.date))),
                DataCell(
                  const Center(child: Icon(Icons.remove_red_eye)),
                  onTap: () {
                    showTransactionDetails(
                        context,
                        transaction,
                        merchants
                            .firstWhere((e) => e.id == transaction.merchantId),
                        inventories
                            .firstWhere((e) => e.id == transaction.inventoryId),
                        (userBloc.state as UserLoaded)
                            .users
                            .firstWhere((e) => e.id == transaction.createdBy));
                  },
                )
              ],
            );
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

    if (selectedCreatedByOption != null) {
      return transs.where((transaction) {
        return transaction.createdBy == selectedCreatedByOption!.id;
      }).toList();
    }
    return transs;
  }

  /// Helper function to format date
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  DataColumn2 dataColumnGen(String label) => DataColumn2(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildSearchByDropDown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(3)),
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text(
            'Search By',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: selectedSearchOption,
          items: const [
            DropdownMenuItem(value: 'merchant', child: Text('Merchant')),
            DropdownMenuItem(value: 'inventory', child: Text('Inventory')),
            DropdownMenuItem(value: "author", child: Text("Author"))
          ],
          onChanged: (value) {
            setState(() {
              selectedSearchOption = value;
              _searchController.text = "";
            });
          },
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildCreatedByDropDown() {
    return BlocProvider<UserBloc>(
      create: (context) => userBloc,
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is! UserLoaded) {
            return const Center();
          }
          List<DropdownMenuItem<User>>? items = state.users.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text("${e.firstName} ${e.lastName}"),
            );
          }).toList();
          items.insert(
              0,
              const DropdownMenuItem(
                value: null,
                child: Text("All users"),
              ));
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(), borderRadius: BorderRadius.circular(3)),
              child: DropdownButton<User>(
                isExpanded: true,
                hint: const Text(
                  'Created By',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: selectedCreatedByOption,
                items: items,
                onChanged: (value) {
                  setState(() {
                    selectedCreatedByOption = value;
                    _searchController.text = "";
                  });
                },
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        },
      ),
    );
  }
}
