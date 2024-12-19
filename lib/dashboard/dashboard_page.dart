import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_page.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_page.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InventoryPage(),
    const MerchantPage(),
    const TransactionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          // Sidebar menu with theme-based styling
          NavigationRail(
            backgroundColor:
                theme.colorScheme.surface, // Use theme surface color
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: IconThemeData(
              color:
                  theme.colorScheme.primary, // Primary color for selected icons
              size: 28,
            ),
            unselectedIconTheme: IconThemeData(
              color: theme.colorScheme.onSurface
                  .withOpacity(0.6), // Muted text color
              size: 24,
            ),
            selectedLabelTextStyle: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            leading: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 30,
                )
              ],
            ),
            trailing: Divider(
              color: theme.dividerColor,
              thickness: 5,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                selectedIcon: Icon(Icons.inventory_outlined),
                label: Text('Inventories'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.store),
                selectedIcon: Icon(Icons.storefront),
                label: Text('Merchants'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.trending_up),
                selectedIcon: Icon(Icons.storefront),
                label: Text('Transactions'),
              ),
            ],
          ),

          VerticalDivider(
            width: 2,
            thickness: 3,
            color: theme.dividerColor,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
