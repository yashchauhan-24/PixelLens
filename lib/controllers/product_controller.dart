import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductController extends ChangeNotifier {
  ProductController(this._productService) : _products = [] {
    _loadProducts();
  }

  final ProductService _productService;
  List<ProductModel> _products;

  List<ProductModel> get products => List.unmodifiable(_products);

  Future<void> _loadProducts() async {
    await refresh();
  }

  ProductModel? findById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    _products = await _productService.getProducts();
    notifyListeners();
  }

  Future<void> saveProduct(ProductModel product) async {
    await _productService.saveProduct(product);
    await refresh();
  }

  Future<void> deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    await refresh();
  }
}