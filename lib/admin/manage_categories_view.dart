import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class ManageCategoriesView extends StatelessWidget {
  const ManageCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryController>().categories;
    final products = context.watch<ProductController>().products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Brands'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.categoryForm),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.categoryForm),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Brand categories', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Create the brand chips that users tap to filter cameras on the home screen.'),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No brands created yet. Add Canon, Sony, Nikon, or any custom camera brand.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else
            ...categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: _BrandAvatar(category: category),
                    title: Text(category.name),
                    subtitle: Text(
                      '${products.where((product) => product.categoryId == category.id).length} products${category.description.isEmpty ? '' : '\n${category.description}'}',
                    ),
                    isThreeLine: category.description.isNotEmpty,
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.editCategoryForm, arguments: category),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Delete brand?'),
                                content: Text('Remove ${category.name} from the store?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete != true || !context.mounted) return;
                            await context.read<CategoryController>().deleteCategory(category.id);
                          },
                          icon: const Icon(Icons.delete_outline),
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandAvatar extends StatelessWidget {
  const _BrandAvatar({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl.trim();
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: AppTheme.brown.withValues(alpha: 0.12),
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return CircleAvatar(
      backgroundColor: AppTheme.brown.withValues(alpha: 0.12),
      child: Text(
        category.name.characters.isEmpty ? '?' : category.name.characters.first.toUpperCase(),
        style: const TextStyle(color: AppTheme.brown, fontWeight: FontWeight.w700),
      ),
    );
  }
}