import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products.where((product) {
      return product.name.toLowerCase().contains(_query.toLowerCase()) ||
          product.description.toLowerCase().contains(_query.toLowerCase());
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Premium camera collections', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Discover high-end mirrorless and DSLR products with a clean, luxurious shopping flow.'),
            const SizedBox(height: 18),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search cameras',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: _EmptyState())
                  : GridView.builder(
                      itemCount: products.length,
                      padding: const EdgeInsets.only(bottom: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: MediaQuery.sizeOf(context).width < 380 ? 0.7 : 0.64,
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
                      // Name and Price - Expanded to fill middle space
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: nameFontSize,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs ${product.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: priceFontSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Button - Full width and bigger
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_outlined, size: 44),
          SizedBox(height: 12),
          Text('No cameras match the current search.'),
        ],
      ),
    );
  }
}