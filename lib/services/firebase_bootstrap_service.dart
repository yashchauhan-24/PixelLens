import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/app_user.dart';

class FirebaseBootstrapService {
  FirebaseBootstrapService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> ensureSeedData() async {
    final usersSnapshot = await _firestore.collection('users').limit(1).get();
    if (usersSnapshot.docs.isEmpty) {
      final admin = await _ensureAuthUser(
        email: 'admin@gmail.com',
        password: '123456',
        name: 'Admin User',
        role: UserRole.admin,
        phone: '000-000-0000',
        address: 'Headquarters',
      );
      final user = await _ensureAuthUser(
        email: 'user@gmail.com',
        password: '123456',
        name: 'John Camera',
        role: UserRole.user,
        phone: '555-0101',
        address: '123 Photo St, Imageland',
      );

      await _firestore.collection('users').doc(admin.id).set(admin.toMap());
      await _firestore.collection('users').doc(user.id).set(user.toMap());

      await _seedOrders(user.id);
    } else {
      await _seedOrdersFromExistingUser();
    }

    final categoriesSnapshot = await _firestore.collection('categories').limit(1).get();
    if (categoriesSnapshot.docs.isEmpty) {
      await _seedCategories();
    }

    final productsSnapshot = await _firestore.collection('products').limit(1).get();
    if (productsSnapshot.docs.isEmpty) {
      await _seedProducts();
    }

    // Backfill sample reviews for every product that has no reviews yet.
    await _seedReviews();

    await _auth.signOut();
  }

  static Future<AppUser> _ensureAuthUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? address,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AppUser(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        phone: phone,
        address: address,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        rethrow;
      }
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AppUser(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        phone: phone,
        address: address,
      );
    }
  }

  static Future<void> _seedProducts() async {
    const products = [
      ProductModel(
        id: 'p-001',
        name: 'Canon EOS R8',
        price: 1499.99,
        description: 'A compact full-frame mirrorless camera with fast autofocus and stunning video capability.',
        image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
        categoryId: 'canon',
      ),
      ProductModel(
        id: 'p-002',
        name: 'Sony Alpha a7 IV',
        price: 2499.00,
        description: 'Professional hybrid camera for creators who demand detail, speed, and reliable autofocus.',
        image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
        categoryId: 'sony',
      ),
      ProductModel(
        id: 'p-003',
        name: 'Nikon Z6 II',
        price: 1899.00,
        description: 'Versatile full-frame system built for sharp stills, smooth performance, and durable handling.',
        image: 'https://images.unsplash.com/photo-1519421680037-a6d4e26f0b4f?auto=format&fit=crop&w=1200&q=80',
        categoryId: 'nikon',
      ),
      ProductModel(
        id: 'p-004',
        name: 'Fujifilm X-T5',
        price: 1699.00,
        description: 'Classic styling with a modern sensor, premium controls, and beautiful color rendering.',
        image: 'https://images.unsplash.com/photo-1516724562728-afc824a36e84?auto=format&fit=crop&w=1200&q=80',
        categoryId: 'fujifilm',
      ),
    ];

    for (final product in products) {
      await _firestore.collection('products').doc(product.id).set(product.toMap());
    }
  }

  static Future<void> _seedReviews() async {
    final productSnapshot = await _firestore.collection('products').get();
    for (final doc in productSnapshot.docs) {
      final pid = doc.id;
      final existing = await _firestore.collection('products').doc(pid).collection('reviews').limit(1).get();
      if (existing.docs.isNotEmpty) continue;

      final samples = [
        {
          'userId': 'seed-user-1',
          'userName': 'Alice',
          'rating': 5,
          'comment': 'Excellent camera, superb image quality!',
          'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
        {
          'userId': 'seed-user-2',
          'userName': 'Bob',
          'rating': 4,
          'comment': 'Very good value for money.',
          'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        },
      ];

      for (final s in samples) {
        await _firestore.collection('products').doc(pid).collection('reviews').add(s);
      }
    }
  }

  static Future<void> _seedCategories() async {
    const categories = [
      CategoryModel(
        id: 'canon',
        name: 'Canon',
        description: 'EOS R and DSLR bodies for creators who want reliable autofocus.',
      ),
      CategoryModel(
        id: 'sony',
        name: 'Sony',
        description: 'High-speed mirrorless cameras for hybrid photo and video work.',
      ),
      CategoryModel(
        id: 'nikon',
        name: 'Nikon',
        description: 'Durable full-frame bodies with strong ergonomics and color depth.',
      ),
      CategoryModel(
        id: 'fujifilm',
        name: 'Fujifilm',
        description: 'Stylish APS-C cameras with refined color science and tactile controls.',
      ),
      CategoryModel(
        id: 'panasonic',
        name: 'Panasonic',
        description: 'Video-first mirrorless systems built for creators and filmmakers.',
      ),
    ];

    for (final category in categories) {
      await _firestore.collection('categories').doc(category.id).set(category.toMap());
    }
  }

  static Future<void> _seedOrders(String userId) async {
    final order = OrderModel(
      id: 'o-001',
      userId: userId,
      products: const [
        CartItemModel(
          product: ProductModel(
            id: 'p-001',
            name: 'Canon EOS R8',
            price: 1499.99,
            description: '',
            image: '',
            categoryId: 'canon',
          ),
          quantity: 1,
        ),
      ],
      totalPrice: 1499.99,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    await _firestore.collection('orders').doc(order.id).set(order.toMap());
  }

  static Future<void> _seedOrdersFromExistingUser() async {
    final orderSnapshot = await _firestore.collection('orders').limit(1).get();
    if (orderSnapshot.docs.isNotEmpty) return;

    final userSnapshot = await _firestore.collection('users').where('role', isEqualTo: UserRole.user.name).limit(1).get();
    if (userSnapshot.docs.isEmpty) return;

    await _seedOrders(userSnapshot.docs.first.id);
  }
}
