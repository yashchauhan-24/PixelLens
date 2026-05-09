import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category.dart';

class CategoryService {
  CategoryService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _categories => _firestore.collection('categories');
  CollectionReference<Map<String, dynamic>> get _products => _firestore.collection('products');

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _categories.orderBy('name').get();
    return snapshot.docs.map(_categoryFromDoc).toList();
  }

  Future<CategoryModel?> findById(String id) async {
    final snapshot = await _categories.doc(id).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return _categoryFromDoc(snapshot);
  }

  Future<CategoryModel> saveCategory(CategoryModel category) async {
    await _ensureAdmin();
    final saved = category.copyWith(imageUrl: category.imageUrl.trim());
    await _categories.doc(saved.id).set(saved.toMap(), SetOptions(merge: true));
    return saved;
  }

  Future<void> deleteCategory(String id) async {
    await _ensureAdmin();
    final products = await _products.where('categoryId', isEqualTo: id).get();
    final batch = _firestore.batch();
    for (final doc in products.docs) {
      batch.update(doc.reference, {'categoryId': ''});
    }
    batch.delete(_categories.doc(id));
    await batch.commit();
  }

  Future<void> _ensureAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Admin access required.');
    }
    final userSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
    final roleValue = userSnapshot.data()?['role'] as String?;
    if (roleValue != 'admin') {
      throw Exception('Only admin users can manage brands.');
    }
  }

  CategoryModel _categoryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CategoryModel.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }
}