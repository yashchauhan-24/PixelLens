// EditProfileView: allows the user to update name, phone, and address.
// Uses AuthController to persist changes via the service layer.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  String? _phone;
  String? _address;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _name = user?.name ?? '';
    _phone = user?.phone;
    _address = user?.address;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) => _phone = v?.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (v) => _address = v?.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final updated = await auth.updateProfile(name: _name, phone: _phone, address: _address);
                        if (!mounted) return;
                        if (updated != null) {
                          messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
                          navigator.pop();
                        } else {
                          messenger.showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Failed')));
                        }
                      },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
