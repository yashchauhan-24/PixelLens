import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

class LocalDataService {
  LocalDataService._internal() {
    _seed();
  }

  static final LocalDataService instance = LocalDataService._internal();

  final List<AppUser> _users = [];
  final Map<String, String> _passwordByEmail = {};
  final List<ProductModel> _products = [];
  final List<OrderModel> _orders = [];

  List<AppUser> get users => List.unmodifiable(_users);
  List<ProductModel> get products => List.unmodifiable(_products);
  List<OrderModel> get orders => List.unmodifiable(_orders);

  void _seed() {
    _users.addAll([
      const AppUser(
        id: 'u-admin',
        name: 'Admin User',
        email: 'admin@gmail.com',
        role: UserRole.admin,
        phone: '000-000-0000',
        address: 'Headquarters',
        profileImage: null,
      ),
      const AppUser(
        id: 'u-001',
        name: 'John Camera',
        email: 'user@gmail.com',
        role: UserRole.user,
        phone: '555-0101',
        address: '123 Photo St, Imageland',
        profileImage: null,
      ),
      const AppUser(
        id: 'u-002',
        name: 'Ava Lens',
        email: 'ava@example.com',
        role: UserRole.user,
        phone: '555-0202',
        address: '77 Lens Ave, Cameraville',
        profileImage: null,
      ),
    ]);

    _passwordByEmail.addAll({
      'admin@gmail.com': '123456',
      'user@gmail.com': '123456',
      'ava@example.com': '123456',
    });

    _products.addAll([
      const ProductModel(
        id: 'p-001',
        name: 'Canon EOS R8',
        price: 1499.99,
        description: 'A compact full-frame mirrorless camera with fast autofocus and stunning video capability.',
        image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
        categoryId: 'canon',
      ),
      const ProductModel(
        id: 'p-002',
        name: 'Sony Alpha a7 IV',
        price: 2499.00,
        description: 'Professional hybrid camera for creators who demand detail, speed, and reliable autofocus.',
        image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
        categoryId: 'sony',
      ),
      const ProductModel(
        id: 'p-003',
        name: 'Nikon Z6 II',
        price: 1899.00,
        description: 'Versatile full-frame system built for sharp stills, smooth performance, and durable handling.',
        image: 'https://images.unsplash.com/photo-1519421680037-a6d4e26f0b4f?auto=format&fit=crop&w=1200&q=80',
        categoryId: 'nikon',
      ),
      const ProductModel(
        id: 'p-004',
        name: 'Fujifilm X-T5',
        price: 1699.00,
        description: 'Classic styling with a modern sensor, premium controls, and beautiful color rendering.',
        image: 'https://images.unsplash.com/photo-1516724562728-afc824a36e84?auto=format&fit=crop&w=1200&q=80',
        categoryId: 'fujifilm',
      ),
    ]);

    _orders.add(
      OrderModel(
        id: 'o-001',
        userId: 'u-001',
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
      ),
    );
  }

  AppUser? authenticate(String email, String password) {
    final user = _users.where((item) => item.email.toLowerCase() == email.toLowerCase()).firstOrNull;
    if (user == null) {
      return null;
    }

    final storedPassword = _passwordByEmail[user.email.toLowerCase()];
    if (storedPassword != password) {
      return null;
    }
    return user;
  }

  AppUser updateUser(AppUser user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      _users[index] = user;
    } else {
      _users.insert(0, user);
    }
    return user;
  }

  bool changePassword(String email, String oldPassword, String newPassword) {
    final emailKey = email.toLowerCase();
    final stored = _passwordByEmail[emailKey];
    if (stored == null || stored != oldPassword) return false;
    _passwordByEmail[emailKey] = newPassword;
    return true;
  }

  AppUser? findUserById(String id) => _users.where((item) => item.id == id).firstOrNull;

  ProductModel? findProductById(String id) => _products.where((item) => item.id == id).firstOrNull;

  ProductModel saveProduct(ProductModel product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _products[index] = product;
    } else {
      _products.insert(0, product);
    }
    return product;
  }

  void deleteProduct(String id) {
    _products.removeWhere((item) => item.id == id);
  }

  OrderModel addOrder(OrderModel order) {
    _orders.insert(0, order);
    return order;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((item) => item.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: status);
    }
  }

  List<OrderModel> ordersForUser(String userId) => _orders.where((item) => item.userId == userId).toList();
}

extension FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
