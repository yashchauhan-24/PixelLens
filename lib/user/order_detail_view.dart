// OrderDetailView: displays a single order with products, totals, date, and status.
import 'package:flutter/material.dart';

import '../models/order.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order ${order.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Placed: ${order.createdAt.toLocal()}'),
            const SizedBox(height: 8),
            Text('Status: ${order.status.displayName}'),
            const SizedBox(height: 16),
            const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: order.products.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = order.products[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Text('Rs ${item.subTotal.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text('Total: Rs ${order.totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
