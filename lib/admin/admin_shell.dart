import 'package:flutter/material.dart';

import '../constants/app_routes.dart';
import 'admin_dashboard_view.dart';
import 'manage_orders_view.dart';
import 'manage_products_view.dart';
import 'manage_users_view.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late int _index;

  final _pages = const [
    AdminDashboardView(),
    ManageProductsView(),
    ManageOrdersView(),
    ManageUsersView(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          final route = switch (value) {
            0 => AppRoutes.adminHome,
            1 => AppRoutes.adminProducts,
            2 => AppRoutes.adminOrders,
            _ => AppRoutes.adminUsers,
          };
          Navigator.pushReplacementNamed(context, route);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Users'),
        ],
      ),
    );
  }
}