import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../models/app_user.dart';
import '../theme/app_theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F3EA), Color(0xFFE7D5BC)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.brown.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 34, color: AppTheme.brown),
                        ),
                        const SizedBox(height: 20),
                        Text('PixelLens', style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 8),
                        // const Text(
                        //   'Sign in once and the app routes you to the correct admin or user experience based on the stored role.',
                        // ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _hidePassword = !_hidePassword),
                              icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Enter password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (authController.errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              authController.errorMessage!,
                              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                            ),
                          ),
                        if (authController.errorMessage != null) const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: authController.isLoading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final success = await context.read<AuthController>().login(
                                        _emailController.text,
                                        _passwordController.text,
                                      );

                                  if (!context.mounted || !success) {
                                    return;
                                  }

                                  final user = context.read<AuthController>().currentUser;
                                  if (user?.role == UserRole.admin) {
                                    Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
                                  } else {
                                    Navigator.pushReplacementNamed(context, AppRoutes.userHome);
                                  }
                                },
                          child: authController.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Login'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: authController.isLoading
                              ? null
                              : () async {
                                  final success = await context.read<AuthController>().signInWithGoogle();

                                  if (!context.mounted || !success) return;

                                  final user = context.read<AuthController>().currentUser;
                                  if (user?.role == UserRole.admin) {
                                    Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
                                  } else {
                                    Navigator.pushReplacementNamed(context, AppRoutes.userHome);
                                  }
                                },
                          icon: Image.asset('image/google_logo.png', height: 20, width: 20),
                          label: const Text('Sign in with Google'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                          child: const Text('Create a new account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

