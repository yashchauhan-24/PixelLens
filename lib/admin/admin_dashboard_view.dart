import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/user_controller.dart';
import '../theme/app_theme.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final productCount = context.watch<ProductController>().products.length;
    final orderCount = context.watch<OrderController>().orders.length;
    final userCount = context.watch<UserController>().users.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.adminProducts),
            icon: const Icon(Icons.add_business_outlined),
          ),          IconButton(
            onPressed: () async {
              await context.read<AuthController>().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
            },
            icon: const Icon(Icons.logout),
          ),        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Premium camera business insights', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(title: 'Products', value: '$productCount', icon: Icons.camera_alt_rounded),
              _StatCard(title: 'Orders', value: '$orderCount', icon: Icons.receipt_long_rounded),
              _StatCard(title: 'Users', value: '$userCount', icon: Icons.people_alt_rounded),
            ],
          ),
          const SizedBox(height: 24),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionCard(
                title: 'Add Camera',
                subtitle: 'Create a new product entry',
                icon: Icons.add_circle_outline,
                onTap: () => Navigator.pushNamed(context, AppRoutes.productForm),
              ),
              _ActionCard(
                title: 'Review Orders',
                subtitle: 'Track order statuses',
                icon: Icons.local_shipping_outlined,
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.adminOrders),
              ),
              _ActionCard(
                title: 'Manage Users',
                subtitle: 'View customer list',
                icon: Icons.people_outline,
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.adminUsers),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Card(
          //   child: Padding(
          //     padding: const EdgeInsets.all(20),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       // children: [
          //       //   Text('Store Snapshot', style: Theme.of(context).textTheme.titleLarge),
          //       //   const SizedBox(height: 8),
          //       //   const Text('This local dummy setup is ready for Firebase replacement later through the service layer.'),
          //       //   const SizedBox(height: 16),
          //       //   Container(
          //       //     width: double.infinity,
          //       //     padding: const EdgeInsets.all(16),
          //       //     decoration: BoxDecoration(
          //       //       color: AppTheme.brown.withValues(alpha: 0.08),
          //       //       borderRadius: BorderRadius.circular(18),
          //       //     ),
          //       //     child: const Text('Authenticated role-based routing is simulated with local credentials.'),
          //       //   ),
          //       // ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.brown),
              const SizedBox(height: 16),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppTheme.brown, size: 30),
                const SizedBox(height: 14),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}