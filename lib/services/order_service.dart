import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _orders => _firestore.collection('orders');
  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  Future<List<OrderModel>> fetchAllOrders() async {
    if (!await _isAdmin()) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];
      return fetchOrdersForUser(currentUser.uid);
    }
    final snapshot = await _orders.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(_orderFromDoc).toList();
  }

  Future<List<OrderModel>> fetchOrdersForUser(String userId) async {
    final snapshot = await _orders.where('userId', isEqualTo: userId).get();
    final orders = snapshot.docs.map(_orderFromDoc).toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  Future<OrderModel> createOrder({required String userId, required List<CartItemModel> items}) async {
    await _ensureOrderPermission(userId);
    final total = items.fold<double>(0, (runningTotal, item) => runningTotal + item.subTotal);
    final order = OrderModel(
      id: _orders.doc().id,
      userId: userId,
      products: items,
      totalPrice: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    await _orders.doc(order.id).set(order.toMap());
    return order;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (!await _isAdmin()) {
      throw Exception('Only admin users can update order status.');
    }
    await _orders.doc(orderId).set({'status': status.name}, SetOptions(merge: true));
  }

  Future<AppUser?> findUserById(String userId) async {
    final snapshot = await _users.doc(userId).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    final data = snapshot.data()!;
    return AppUser(
      id: snapshot.id,
      name: (data['name'] as String?) ?? 'User',
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String? ?? 'user') == 'admin' ? UserRole.admin : UserRole.user,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      profileImage: data['profileImage'] as String?,
    );
  }

  Future<bool> _isAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;
    final snapshot = await _users.doc(currentUser.uid).get();
    return snapshot.data()?['role'] == 'admin';
  }

  Future<void> _ensureOrderPermission(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Please sign in first.');
    }
    if (currentUser.uid == userId) return;
    if (await _isAdmin()) return;
    throw Exception('You can only create orders for your own account.');
  }

  OrderModel _orderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return OrderModel.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }
}
