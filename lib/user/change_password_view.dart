// ChangePasswordView: simple form to change the signed-in user's password.
// Uses AuthController for Firebase-backed password updates.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  String _old = '';
  String _new = '';
  String _confirm = '';
  bool _hideOldPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hideOldPassword = !_hideOldPassword),
                    icon: Icon(_hideOldPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  ),
                ),
                obscureText: _hideOldPassword,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter old password' : null,
                onSaved: (v) => _old = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hideNewPassword = !_hideNewPassword),
                    icon: Icon(_hideNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  ),
                ),
                obscureText: _hideNewPassword,
                validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 chars' : null,
                onSaved: (v) => _new = v!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                    icon: Icon(_hideConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  ),
                ),
                obscureText: _hideConfirmPassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirm your new password';
                  if (v != _new) return 'Passwords do not match';
                  return null;
                },
                onSaved: (v) => _confirm = v!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        if (_new != _confirm) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Passwords do not match')),
                          );
                          return;
                        }
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final ok = await auth.changePassword(oldPassword: _old, newPassword: _new);
                        if (!mounted) return;
                        if (ok) {
                          messenger.showSnackBar(const SnackBar(content: Text('Password changed')));
                          navigator.pop();
                        } else {
                          messenger.showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Failed')));
                        }
                      },
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
