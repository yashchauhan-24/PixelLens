import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';
import '../constants/app_routes.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthController>().currentUser;
    final orders = currentUser == null ? <OrderModel>[] : context.watch<OrderController>().ordersForUser(currentUser.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (context, separatorIndex) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: order),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${order.id}', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text('Placed on ${order.createdAt.toLocal()}'),
                          const SizedBox(height: 6),
                          Text('Status: ${order.status.displayName}'),
                          const SizedBox(height: 6),
                          Text('Total: Rs ${order.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}