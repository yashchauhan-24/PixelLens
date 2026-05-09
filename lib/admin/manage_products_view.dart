import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../theme/app_theme.dart';

class ManageProductsView extends StatelessWidget {
  const ManageProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products;
    final categories = context.watch<CategoryController>().categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.productForm),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: products.length,
        separatorBuilder: (context, separatorIndex) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: AppTheme.brown.withValues(alpha: 0.1),
                    child: const Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ),
              title: Text(product.name),
              subtitle: Text(
                '${categories.where((category) => category.id == product.categoryId).map((category) => category.name).firstOrNull ?? 'Unassigned'} • Rs ${product.price.toStringAsFixed(2)}',
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.editProductForm, arguments: product),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => context.read<ProductController>().deleteProduct(product.id),
                    icon: const Icon(Icons.delete_outline),
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