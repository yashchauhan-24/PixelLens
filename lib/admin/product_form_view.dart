import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class ProductFormView extends StatefulWidget {
  const ProductFormView({super.key, this.product});

  final ProductModel? product;

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toStringAsFixed(2) ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _imageController = TextEditingController(text: widget.product?.image ?? '');
    _selectedCategoryId = widget.product?.categoryId.isEmpty == true ? null : widget.product?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final categories = context.watch<CategoryController>().categories;
    final selectedCategoryId = categories.any((category) => category.id == _selectedCategoryId) ? _selectedCategoryId : null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Update Camera' : 'Add Camera')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Camera Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Brand / Category'),
                items: categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
                validator: (value) {
                  if (categories.isEmpty) {
                    return 'Create a brand first';
                  }
                  if (value == null || value.isEmpty) {
                    return 'Select a brand';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter image URL' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final navigator = Navigator.of(context);
                  final product = ProductModel(
                    id: widget.product?.id ?? 'p-${DateTime.now().millisecondsSinceEpoch}',
                    name: _nameController.text.trim(),
                    price: double.parse(_priceController.text.trim()),
                    description: _descriptionController.text.trim(),
                    image: _imageController.text.trim(),
                    categoryId: _selectedCategoryId ?? '',
                  );

                  await context.read<ProductController>().saveProduct(product);
                  if (!navigator.mounted) {
                    return;
                  }
                  navigator.pop();
                },
                child: Text(isEditing ? 'Update Camera' : 'Save Camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}