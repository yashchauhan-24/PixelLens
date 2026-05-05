import 'app_user.dart';
import 'cart_item.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final List<CartItemModel> products;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? products,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'products': products.map((item) => item.toMap()).toList(),
        'totalPrice': totalPrice,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    return OrderModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      products: (map['products'] as List<dynamic>)
          .map((item) => CartItemModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: OrderStatus.values.firstWhere((element) => element.name == map['status']),
      createdAt: createdAtRaw is String
          ? DateTime.parse(createdAtRaw)
          : createdAtRaw is DateTime
              ? createdAtRaw
              : DateTime.now(),
    );
  }
}


class OrderLookup {
  const OrderLookup({required this.order, required this.user});

  final OrderModel order;
  final AppUser user;
}
