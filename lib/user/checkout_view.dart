import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  String _selectedPaymentMethod = 'Cash on Delivery';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text('Items: ${cart.items.length}'),
                  const SizedBox(height: 6),
                  Text('Total: Rs ${cart.total.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  Text('Customer: ${user?.name ?? 'Unknown'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: RadioListTile<String>(
              value: 'Cash on Delivery',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedPaymentMethod = value);
              },
              title: const Text('Cash on Delivery'),
              subtitle: const Text('Pay when your order is delivered.'),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: cart.isEmpty || user == null
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final cartController = context.read<CartController>();
                    await context.read<OrderController>().placeOrder(userId: user.id, items: cart.items);
                    cartController.clear();
                    if (!navigator.mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Order placed successfully')),
                    );
                    navigator.pushReplacementNamed(AppRoutes.userOrders);
                  },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}