import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'firebase_options.dart';
import 'services/category_service.dart';
import 'services/auth_service.dart';
import 'services/firebase_bootstrap_service.dart';
import 'services/order_service.dart';
import 'services/product_service.dart';
import 'services/user_service.dart';
import 'services/wishlist_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseBootstrapService.ensureSeedData();
  runApp(const CameraSellingApp());
}

class CameraSellingApp extends StatelessWidget {
  const CameraSellingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final categoryService = CategoryService();
    final productService = ProductService();
    final orderService = OrderService();
    final userService = UserService();
    final wishlistService = WishlistService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryController(categoryService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductController(productService),
        ),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(
          create: (context) => WishlistController(wishlistService, context.read<AuthController>()),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderController(orderService),
        ),
        ChangeNotifierProvider(
          create: (_) => UserController(userService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PixelLens',
        theme: AppTheme.lightTheme,
        home: const App(),
      ),
    );
  }
}
