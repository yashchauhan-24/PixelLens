import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key, required this.product});

  final Object? product;

  @override
  Widget build(BuildContext context) {
    final camera = product as ProductModel;
    final cartController = context.watch<CartController>();
    final quantity = cartController.quantityFor(camera.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AspectRatio(
              aspectRatio: 1.15,
              child: Image.network(
                camera.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.brown.withValues(alpha: 0.08),
                  child: const Icon(Icons.camera_alt_outlined, size: 60, color: AppTheme.brown),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(camera.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Rs ${camera.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(camera.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<CartController>().addProduct(camera);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${camera.name} added to cart')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                  label: Text(quantity > 0 ? 'Add More ($quantity)' : 'Add to Cart'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}