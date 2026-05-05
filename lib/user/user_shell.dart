import 'package:flutter/material.dart';

import '../constants/app_routes.dart';
import 'cart_view.dart';
import 'order_history_view.dart';
import 'profile_view.dart';
import 'user_home_view.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  late int _index;

  final _pages = const [
    UserHomeView(),
    CartView(),
    OrderHistoryView(),
    ProfileView(),
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
            0 => AppRoutes.userHome,
            1 => AppRoutes.userCart,
            2 => AppRoutes.userOrders,
            _ => AppRoutes.userProfile,
          };
          Navigator.pushReplacementNamed(context, route);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}