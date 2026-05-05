import 'package:flutter/foundation.dart';

import '../controllers/auth_controller.dart';
import '../models/product.dart';
import '../services/wishlist_service.dart';

class WishlistController extends ChangeNotifier {
  WishlistController(this._wishlistService, this._authController) {
    _authController.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  final WishlistService _wishlistService;
  final AuthController _authController;
  List<ProductModel> _items = [];

  List<ProductModel> get items => List.unmodifiable(_items);

  String? get _userId => _authController.currentUser?.id;

  Future<void> _handleAuthChanged() async {
    await refresh();
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) {
      _items = [];
      notifyListeners();
      return;
    }
    _items = await _wishlistService.fetchWishlist(userId);
    notifyListeners();
  }

  bool contains(String productId) => _items.any((item) => item.id == productId);

  Future<void> add(ProductModel product) async {
    final userId = _userId;
    if (userId == null) return;
    await _wishlistService.add(userId, product);
    await refresh();
  }

  Future<void> remove(String productId) async {
    final userId = _userId;
    if (userId == null) return;
    await _wishlistService.remove(userId, productId);
    await refresh();
  }

  Future<void> toggle(ProductModel product) async {
    if (contains(product.id)) {
      await remove(product.id);
    } else {
      await add(product);
    }
  }

  Future<void> clear() async {
    final userId = _userId;
    if (userId == null) return;
    await _wishlistService.clear(userId);
    await refresh();
  }
}

