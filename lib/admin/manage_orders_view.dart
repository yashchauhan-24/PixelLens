import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import '../controllers/user_controller.dart';
import '../models/order.dart';

class ManageOrdersView extends StatelessWidget {
  const ManageOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderController>().orders;
    final userController = context.watch<UserController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        separatorBuilder: (context, separatorIndex) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          final user = userController.findById(order.userId);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order #${order.id}', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(user?.email ?? order.userId),
                          ],
                        ),
                      ),
                      Text('Rs ${order.totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Items: ${order.products.length}'),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Order Status'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<OrderStatus>(
                        value: order.status,
                        isExpanded: true,
                        items: OrderStatus.values
                            .map(
                              (status) => DropdownMenuItem<OrderStatus>(
                                value: status,
                                child: Text(status.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            await context.read<OrderController>().updateStatus(order.id, value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
