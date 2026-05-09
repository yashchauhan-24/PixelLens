import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../controllers/review_controller.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  String _query = '';
  String _selectedCategoryId = 'all';

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryController>().categories;

    if (_selectedCategoryId != 'all' && categories.every((category) => category.id != _selectedCategoryId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedCategoryId = 'all');
        }
      });
    }

    final products = context.watch<ProductController>().products.where((product) {
      final matchesQuery = product.name.toLowerCase().contains(_query.toLowerCase()) ||
          product.description.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory = _selectedCategoryId == 'all' || product.categoryId == _selectedCategoryId;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Cameras'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.userCart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: 'Search cameras',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Explore by Brand', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _CategoryChip(
                      label: 'All',
                      selected: _selectedCategoryId == 'all',
                      onTap: () => setState(() => _selectedCategoryId = 'all'),
                    );
                  }

                  final category = categories[index - 1];
                  return _CategoryChip(
                    label: category.name,
                    selected: _selectedCategoryId == category.id,
                    onTap: () => setState(() => _selectedCategoryId = category.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: products.isEmpty
                  ? _EmptyState(selectedCategoryId: _selectedCategoryId, query: _query)
                  : GridView.builder(
                      itemCount: products.length,
                      padding: const EdgeInsets.only(bottom: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        // Lower ratio = taller card (prevents vertical overflow and looks closer to design)
                        childAspectRatio: MediaQuery.sizeOf(context).width < 380 ? 0.60 : 0.56,
                      ),
                      itemBuilder: (context, index) {
                        return _ProductCard(product: products[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0xFFE8DCCF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? AppTheme.brown : Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: selected ? 0.12 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkBrown,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.sizeOf(context).width;
            final isNarrow = screenWidth < 380;
            final cardPadding = isNarrow ? 6.0 : 8.0;
            final nameFontSize = isNarrow ? 13.0 : 15.0;
            final priceFontSize = isNarrow ? 14.0 : 16.0;

            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Image - Keep exactly the same
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.brown.withValues(alpha: 0.08),
                              child: const Icon(Icons.camera_alt_outlined, size: 36, color: AppTheme.brown),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: nameFontSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            // Rating row (styled like screenshot)
                            Consumer<ReviewController>(builder: (context, reviews, _) {
                              final summary = reviews.summaryFor(product.id);
                              if (summary == null) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (context.mounted) context.read<ReviewController>().loadSummary(product.id);
                                });
                                return const SizedBox.shrink();
                              }

                              final avg = summary.average;
                              final count = summary.count;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < avg.round() ? Icons.star : Icons.star_border,
                                            size: 12,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        avg > 0 ? avg.toStringAsFixed(1) : '-',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '(${count.toString()} ${count == 1 ? 'review' : 'reviews'})',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              );
                            }),
                            const Spacer(),
                            Text(
                              'Rs ${product.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: priceFontSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                onPressed: () {
                                  context.read<CartController>().addProduct(product);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                                },
                                child: const Text('Add to Cart'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Card(
                    shape: const CircleBorder(),
                    child: Consumer<WishlistController>(
                      builder: (context, wishlist, _) => IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                        padding: EdgeInsets.zero,
                        onPressed: () => wishlist.toggle(product),
                        icon: Icon(
                          wishlist.contains(product.id) ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.selectedCategoryId, required this.query});

  final String selectedCategoryId;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_outlined, size: 44),
          const SizedBox(height: 12),
          Text(
            selectedCategoryId == 'all' && query.isEmpty
                ? 'No cameras available right now.'
                : 'No cameras match the selected brand or search.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}