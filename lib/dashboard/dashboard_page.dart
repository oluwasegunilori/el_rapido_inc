import 'package:el_rapido_inc/auth/presentation/logout.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/inventory_page.dart';
import 'package:el_rapido_inc/dashboard/merchant/presentation/merchants_page.dart';
import 'package:el_rapido_inc/dashboard/transaction/presentation/transaction_page.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_screen.dart';
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
    const UserPage(),
  ];

  final List<String> _pagesTitle = [
    "Inventories",
    "Merchants",
    "Transactions",
    "Users",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  title: Text(
                    _pagesTitle[_selectedIndex],
                    style: const TextStyle(
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
          drawer: isMobile ? _buildDrawer(theme) : null,
          body: isMobile ? _buildMobileView() : _buildDesktopView(theme),
        );
      },
    );
  }

  Widget _buildMobileView() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _pages[_selectedIndex],
    );
  }

  Widget _buildDesktopView(ThemeData theme) {
    return Row(
      children: [
        NavigationRail(
          backgroundColor: theme.colorScheme.surface,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          selectedIconTheme: IconThemeData(
            color: theme.colorScheme.primary,
            size: 28,
          ),
          unselectedIconTheme: IconThemeData(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
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
              const SizedBox(height: 30),
            ],
          ),
          trailing: Divider(color: theme.dividerColor, thickness: 5),
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
              selectedIcon: Icon(Icons.trending_up),
              label: Text('Transactions'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people),
              selectedIcon: Icon(Icons.people),
              label: Text('Users'),
            ),
          ],
        ),
        VerticalDivider(width: 2, thickness: 3, color: theme.dividerColor),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_selectedIndex],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.onPrimary,
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.inventory, 'Inventories', 0),
          _drawerItem(Icons.store, 'Merchants', 1),
          _drawerItem(Icons.trending_up, 'Transactions', 2),
          _drawerItem(Icons.people, 'Users', 3),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Close drawer after selecting
      },
    );
  }
}

// Dummy Page
