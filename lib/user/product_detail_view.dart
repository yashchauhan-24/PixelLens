import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../controllers/review_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key, required this.product});

  final Object? product;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  @override
  void initState() {
    super.initState();
    // load reviews and summary after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final camera = widget.product as ProductModel;
      if (mounted) {
        context.read<ReviewController>().loadSummary(camera.id);
        context.read<ReviewController>().loadReviews(camera.id);
      }
    });
  }

  Future<void> _showAddReview(ProductModel camera) async {
    final auth = context.read<AuthController>();
    if (!auth.isLoggedIn || auth.currentUser == null) {
      // Ask user to login first
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to submit a review.')));
      return;
    }

    int rating = 5;
    final commentController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Write a review', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (i) {
                    final idx = i + 1;
                    return IconButton(
                      onPressed: () => setState(() => rating = idx),
                      icon: Icon(idx <= rating ? Icons.star : Icons.star_border, color: Colors.amber),
                    );
                  }),
                ),
                TextField(controller: commentController, maxLines: 4, decoration: const InputDecoration(hintText: 'Write your review...')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final user = auth.currentUser!;
                    final cameraLocal = camera;
                    final review = ReviewModel(
                      id: '',
                      productId: cameraLocal.id,
                      userId: user.id,
                      userName: user.name,
                      rating: rating,
                      comment: commentController.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    await context.read<ReviewController>().submitReview(review);
                    Navigator.pop(context, true);
                  },
                  child: const Text('Submit Review'),
                ),
              ],
            ),
          );
        }),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your review')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = widget.product as ProductModel;
    final cartController = context.watch<CartController>();
    final quantity = cartController.quantityFor(camera.id);
    final reviewController = context.watch<ReviewController>();
    final summary = reviewController.summaryFor(camera.id);
    final reviews = reviewController.reviewsFor(camera.id);

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
          Row(children: [
            if (summary != null)
              Row(children: List.generate(5, (i) => Icon(i < summary.average.round() ? Icons.star : Icons.star_border, color: Colors.amber, size: 18))),
            const SizedBox(width: 8),
            if (summary != null) Text('${summary.average.toStringAsFixed(1)} (${summary.count})'),
          ]),
          const SizedBox(height: 8),
          Text('Rs ${camera.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(camera.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: () => _showAddReview(camera), icon: const Icon(Icons.rate_review), label: const Text('Write a review')),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text('Reviews', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const Text('No reviews yet. Be the first to review this product!')
          else
            ...reviews.map((r) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(width: 8), ...List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14))]),
                      if (r.comment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(r.comment),
                      ],
                      const SizedBox(height: 6),
                      Text(r.createdAt.toLocal().toString(), style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                ))
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${camera.name} added to cart')));
              },
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: Text(quantity > 0 ? 'Add More ($quantity)' : 'Add to Cart'),
            ),
          ),
        ]),
      ),
    );
  }
}