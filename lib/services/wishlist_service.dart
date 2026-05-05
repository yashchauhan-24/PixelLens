import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class WishlistService {
  WishlistService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _wishlistRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('wishlist');

  Future<List<ProductModel>> fetchWishlist(String userId) async {
    if (userId.isEmpty) return [];
    final snapshot = await _wishlistRef(userId).orderBy('name').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductModel.fromMap({
        ...data,
        'id': data['id'] ?? doc.id,
        'imageUrl': data['imageUrl'] ?? data['image'],
      });
    }).toList();
  }

  Future<void> add(String userId, ProductModel product) async {
    if (userId.isEmpty) return;
    await _wishlistRef(userId).doc(product.id).set(product.toMap(), SetOptions(merge: true));
  }

  Future<void> remove(String userId, String productId) async {
    if (userId.isEmpty) return;
    await _wishlistRef(userId).doc(productId).delete();
  }

  Future<void> clear(String userId) async {
    if (userId.isEmpty) return;
    final snapshot = await _wishlistRef(userId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> contains(String userId, String productId) async {
    if (userId.isEmpty) return false;
    final snapshot = await _wishlistRef(userId).doc(productId).get();
    return snapshot.exists;
  }
}
