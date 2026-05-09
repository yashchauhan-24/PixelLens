import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/user_controller.dart';
import '../theme/app_theme.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final productCount = context.watch<ProductController>().products.length;
    final categoryCount = context.watch<CategoryController>().categories.length;
    final orderCount = context.watch<OrderController>().orders.length;
    final userCount = context.watch<UserController>().users.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 20.0;
    final spacingForStats = 16.0;
    final cardWidth = (screenWidth - horizontalPadding * 2 - spacingForStats) / 2;

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 20, bottom: MediaQuery.of(context).viewPadding.bottom + kBottomNavigationBarHeight + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Premium camera business insights', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: spacingForStats,
                runSpacing: spacingForStats,
                children: [
                  SizedBox(width: cardWidth, child: _StatCard(title: 'Brands', value: '$categoryCount', icon: Icons.sell_outlined)),
                  SizedBox(width: cardWidth, child: _StatCard(title: 'Products', value: '$productCount', icon: Icons.camera_alt_rounded)),
                  SizedBox(width: cardWidth, child: _StatCard(title: 'Orders', value: '$orderCount', icon: Icons.receipt_long_rounded)),
                  SizedBox(width: cardWidth, child: _StatCard(title: 'Users', value: '$userCount', icon: Icons.people_alt_rounded)),
                ],
              ),
            const SizedBox(height: 24),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(width: cardWidth, child: _ActionCard(
                  title: 'Manage Brands',
                  subtitle: 'Create and edit camera categories',
                  icon: Icons.sell_outlined,
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.adminCategories),
                )),
                SizedBox(width: cardWidth, child: _ActionCard(
                  title: 'Add Camera',
                  subtitle: 'Create a new product entry',
                  icon: Icons.add_circle_outline,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.productForm),
                )),
                SizedBox(width: cardWidth, child: _ActionCard(
                  title: 'Review Orders',
                  subtitle: 'Track order statuses',
                  icon: Icons.local_shipping_outlined,
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.adminOrders),
                )),
                SizedBox(width: cardWidth, child: _ActionCard(
                  title: 'Manage Users',
                  subtitle: 'View customer list',
                  icon: Icons.people_outline,
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.adminUsers),
                )),
              ],
            ),
                const SizedBox(height: 24),
              ],
            ),
          ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.brown),
            const SizedBox(height: 16),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(title, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.brown, size: 30),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}