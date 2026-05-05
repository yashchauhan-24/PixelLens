import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/cart_controller.dart';
import '../theme/app_theme.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const _CartEmptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                item.product.image,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 72,
                                  height: 72,
                                  color: AppTheme.brown.withValues(alpha: 0.08),
                                  child: const Icon(Icons.camera_alt_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 4),
                                  Text('Rs ${item.product.price.toStringAsFixed(2)}'),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => context.read<CartController>().decrease(item.product.id),
                                        icon: const Icon(Icons.remove_circle_outline),
                                      ),
                                      Text('${item.quantity}', style: Theme.of(context).textTheme.titleLarge),
                                      IconButton(
                                        onPressed: () => context.read<CartController>().increase(item.product.id),
                                        icon: const Icon(Icons.add_circle_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Rs ${item.subTotal.toStringAsFixed(2)}'),
                                IconButton(
                                  onPressed: () => context.read<CartController>().removeProduct(item.product.id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _SummaryRow(label: 'Subtotal', value: 'Rs ${cart.subTotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _SummaryRow(label: 'Shipping', value: 'Rs ${cart.shippingFee.toStringAsFixed(2)}'),
                        const Divider(height: 28),
                        _SummaryRow(
                          label: 'Total',
                          value: 'Rs ${cart.total.toStringAsFixed(2)}',
                          bold: true,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.bodyLarge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 54),
            SizedBox(height: 12),
            Text('Your cart is empty.'),
          ],
        ),
      ),
    );
  }
}