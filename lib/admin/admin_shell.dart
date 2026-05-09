import 'package:flutter/material.dart';

import '../constants/app_routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'admin_dashboard_view.dart';
import 'manage_categories_view.dart';
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
    ManageCategoriesView(),
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _index,
        onTap: (value) {
          final route = switch (value) {
            0 => AppRoutes.adminHome,
            1 => AppRoutes.adminCategories,
            2 => AppRoutes.adminProducts,
            3 => AppRoutes.adminOrders,
            _ => AppRoutes.adminUsers,
          };
          Navigator.pushReplacementNamed(context, route);
        },
        items: const [
          BottomNavItem(icon: Icons.space_dashboard_outlined, label: 'Dashboard'),
          BottomNavItem(icon: Icons.sell_outlined, label: 'Brands'),
          BottomNavItem(icon: Icons.camera_alt_outlined, label: 'Products'),
          BottomNavItem(icon: Icons.receipt_long_outlined, label: 'Orders'),
          BottomNavItem(icon: Icons.people_alt_outlined, label: 'Users'),
        ],
      ),
    );
  }
}