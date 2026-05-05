import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderController extends ChangeNotifier {
  OrderController(this._orderService) : _orders = [] {
    _loadOrders();
  }

  final OrderService _orderService;
  List<OrderModel> _orders;

  List<OrderModel> get orders => List.unmodifiable(_orders);

  List<OrderModel> ordersForUser(String userId) => _orders.where((order) => order.userId == userId).toList();

  Future<void> _loadOrders() async {
    await refresh();
  }

  Future<void> refresh() async {
    _orders = await _orderService.fetchAllOrders();
    notifyListeners();
  }

  Future<OrderModel> placeOrder({required String userId, required List<CartItemModel> items}) async {
    final order = await _orderService.createOrder(userId: userId, items: items);
    await refresh();
    return order;
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _orderService.updateOrderStatus(orderId, status);
    await refresh();
  }

  Future<AppUser?> findUserById(String userId) => _orderService.findUserById(userId);
}