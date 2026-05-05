import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    final productsSnapshot = await _firestore.collection('products').limit(1).get();
    if (productsSnapshot.docs.isEmpty) {
      await _seedProducts();
    }

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
      ),
      ProductModel(
        id: 'p-002',
        name: 'Sony Alpha a7 IV',
        price: 2499.00,
        description: 'Professional hybrid camera for creators who demand detail, speed, and reliable autofocus.',
        image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
      ),
      ProductModel(
        id: 'p-003',
        name: 'Nikon Z6 II',
        price: 1899.00,
        description: 'Versatile full-frame system built for sharp stills, smooth performance, and durable handling.',
        image: 'https://images.unsplash.com/photo-1519421680037-a6d4e26f0b4f?auto=format&fit=crop&w=1200&q=80',
      ),
      ProductModel(
        id: 'p-004',
        name: 'Fujifilm X-T5',
        price: 1699.00,
        description: 'Classic styling with a modern sensor, premium controls, and beautiful color rendering.',
        image: 'https://images.unsplash.com/photo-1516724562728-afc824a36e84?auto=format&fit=crop&w=1200&q=80',
      ),
    ];

    for (final product in products) {
      await _firestore.collection('products').doc(product.id).set(product.toMap());
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
