import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/product_controller.dart';
import '../controllers/review_controller.dart';
import '../theme/app_theme.dart';

class ManageProductsView extends StatelessWidget {
  const ManageProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products;

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
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<ReviewController>(builder: (context, reviews, _) {
                    final summary = reviews.summaryFor(product.id);
                    if (summary == null) {
                      // trigger load
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) context.read<ReviewController>().loadSummary(product.id);
                      });
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        summary.count > 0 ? '${summary.average.toStringAsFixed(1)} ★ (${summary.count} reviews)' : 'No reviews yet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
                ],
              ),
              trailing: SizedBox(
                width: 108,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: const Offset(-2, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.editProductForm, arguments: product),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        ),
                        IconButton(
                          onPressed: () async {
                            await context.read<ReviewController>().loadReviews(product.id);
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Reviews for ${product.name}', style: Theme.of(context).textTheme.headlineSmall),
                                    const SizedBox(height: 8),
                                    Consumer<ReviewController>(builder: (context, reviews, _) {
                                      final list = reviews.reviewsFor(product.id);
                                      if (list.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('No reviews yet'));
                                      return Flexible(
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: list.length,
                                          separatorBuilder: (_, __) => const Divider(),
                                          itemBuilder: (context, i) {
                                            final r = list[i];
                                            return ListTile(
                                              title: Text(r.userName),
                                              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Row(children: List.generate(5, (j) => Icon(j < r.rating ? Icons.star : Icons.star_border, size: 14, color: Colors.amber))),
                                                if (r.comment.isNotEmpty) Text(r.comment),
                                                Text(r.createdAt.toLocal().toString(), style: Theme.of(context).textTheme.bodySmall),
                                              ]),
                                            );
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.rate_review_outlined, size: 20),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        ),
                        IconButton(
                          onPressed: () => context.read<ProductController>().deleteProduct(product.id),
                          icon: const Icon(Icons.delete_outline, size: 22, color: Colors.redAccent),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}