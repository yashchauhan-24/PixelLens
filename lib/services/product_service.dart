import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore, FirebaseStorage? storage, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _products => _firestore.collection('products');

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _products.orderBy('name').get();
    return snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
  }

  Future<ProductModel?> findById(String id) async {
    final snapshot = await _products.doc(id).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return _productFromDoc(snapshot);
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    await _ensureAdmin();
    final saved = await _saveProduct(product);
    return saved;
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    await _ensureAdmin();
    final saved = await _saveProduct(product);
    return saved;
  }

  Future<ProductModel> saveProduct(ProductModel product) async {
    if (await _productExists(product.id)) {
      return updateProduct(product);
    }
    return addProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _ensureAdmin();
    await _products.doc(id).delete();
  }

  Future<ProductModel> _saveProduct(ProductModel product) async {
    final imageUrl = await _uploadImageIfNeeded(product.image, product.id);
    final saved = product.copyWith(image: imageUrl);
    await _products.doc(saved.id).set(saved.toMap(), SetOptions(merge: true));
    return saved;
  }

  Future<bool> _productExists(String id) async => (await _products.doc(id).get()).exists;

  Future<void> _ensureAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Admin access required.');
    }
    final userSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
    final roleValue = userSnapshot.data()?['role'] as String?;
    if (roleValue != 'admin') {
      throw Exception('Only admin users can manage products.');
    }
  }

  Future<String> _uploadImageIfNeeded(String imageSource, String productId) async {
    try {
      final uri = Uri.tryParse(imageSource);
      if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return imageSource;
      }

      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return imageSource;
      }

      final storageRef = _storage.ref().child('products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final metadata = SettableMetadata(contentType: response.headers['content-type'] ?? 'image/jpeg');
      await storageRef.putData(response.bodyBytes, metadata);
      return storageRef.getDownloadURL();
    } catch (_) {
      return imageSource;
    }
  }

  ProductModel _productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ProductModel.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
      'imageUrl': data['imageUrl'] ?? data['image'],
    });
  }
}
