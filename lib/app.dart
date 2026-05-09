import 'package:flutter/material.dart';

import 'admin/admin_shell.dart';
import 'admin/category_form_view.dart';
import 'admin/product_form_view.dart';
import 'constants/app_routes.dart';
import 'models/category.dart';
import 'models/product.dart';
import 'models/order.dart';
import 'user/checkout_view.dart';
import 'user/change_password_view.dart';
import 'user/edit_profile_view.dart';
import 'user/order_detail_view.dart';
import 'user/product_detail_view.dart';
import 'user/wishlist_view.dart';
import 'user/user_shell.dart';
import 'views/register_view.dart';
import 'views/login_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginView(), settings: settings);
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterView(), settings: settings);
          case AppRoutes.adminHome:
            return MaterialPageRoute(builder: (_) => const AdminShell(), settings: settings);
          case AppRoutes.adminCategories:
            return MaterialPageRoute(builder: (_) => const AdminShell(initialIndex: 1), settings: settings);
          case AppRoutes.adminProducts:
            return MaterialPageRoute(builder: (_) => const AdminShell(initialIndex: 2), settings: settings);
          case AppRoutes.adminOrders:
            return MaterialPageRoute(builder: (_) => const AdminShell(initialIndex: 3), settings: settings);
          case AppRoutes.adminUsers:
            return MaterialPageRoute(builder: (_) => const AdminShell(initialIndex: 4), settings: settings);
          case AppRoutes.userHome:
            return MaterialPageRoute(builder: (_) => const UserShell(), settings: settings);
          case AppRoutes.userCart:
            return MaterialPageRoute(builder: (_) => const UserShell(initialIndex: 1), settings: settings);
          case AppRoutes.userOrders:
            return MaterialPageRoute(builder: (_) => const UserShell(initialIndex: 2), settings: settings);
          case AppRoutes.orders:
            return MaterialPageRoute(builder: (_) => const UserShell(initialIndex: 2), settings: settings);
          case AppRoutes.userProfile:
            return MaterialPageRoute(builder: (_) => const UserShell(initialIndex: 3), settings: settings);
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const UserShell(initialIndex: 3), settings: settings);
          case AppRoutes.editProfile:
            return MaterialPageRoute(builder: (_) => const EditProfileView(), settings: settings);
          case AppRoutes.changePassword:
            return MaterialPageRoute(builder: (_) => const ChangePasswordView(), settings: settings);
          case AppRoutes.orderDetails:
            return MaterialPageRoute(
              builder: (_) => OrderDetailView(order: settings.arguments as OrderModel),
              settings: settings,
            );
          case AppRoutes.productDetail:
            return MaterialPageRoute(
              builder: (_) => ProductDetailView(product: settings.arguments as ProductModel),
              settings: settings,
            );
          case AppRoutes.checkout:
            return MaterialPageRoute(builder: (_) => const CheckoutView(), settings: settings);
          case AppRoutes.wishlist:
            return MaterialPageRoute(builder: (_) => const WishlistView(), settings: settings);
          case AppRoutes.productForm:
            return MaterialPageRoute(builder: (_) => const ProductFormView(), settings: settings);
          case AppRoutes.editProductForm:
            return MaterialPageRoute(
              builder: (_) => ProductFormView(product: settings.arguments as ProductModel),
              settings: settings,
            );
          case AppRoutes.categoryForm:
            return MaterialPageRoute(builder: (_) => const CategoryFormView(), settings: settings);
          case AppRoutes.editCategoryForm:
            return MaterialPageRoute(
              builder: (_) => CategoryFormView(category: settings.arguments as CategoryModel),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginView(),
              settings: settings,
            );
        }
      },
    );
  }
}
