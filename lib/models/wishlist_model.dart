import 'product.dart';

class WishlistModel {
  WishlistModel({List<ProductModel>? products}) : products = products ?? [];

  final List<ProductModel> products;

  WishlistModel copyWith({List<ProductModel>? products}) {
    return WishlistModel(products: products ?? this.products);
  }
}
