import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/category_controller.dart';
import '../models/category.dart';

class CategoryFormView extends StatefulWidget {
  const CategoryFormView({super.key, this.category});

  final CategoryModel? category;

  @override
  State<CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends State<CategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Update Brand' : 'Add Brand')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Brand Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter brand name' : null,
              ),
              const SizedBox(height: 16),
              // Removed Image URL and Description fields — only brand name is editable.
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final navigator = Navigator.of(context);
                  final category = CategoryModel(
                    id: widget.category?.id ?? 'c-${DateTime.now().millisecondsSinceEpoch}',
                    name: _nameController.text.trim(),
                    imageUrl: widget.category?.imageUrl ?? '',
                    description: widget.category?.description ?? '',
                  );
                  await context.read<CategoryController>().saveCategory(category);
                  if (!navigator.mounted) return;
                  navigator.pop();
                },
                child: Text(isEditing ? 'Update Brand' : 'Save Brand'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}