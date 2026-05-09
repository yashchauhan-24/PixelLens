import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../services/category_service.dart';

class CategoryController extends ChangeNotifier {
  CategoryController(this._categoryService) : _categories = [] {
    _loadCategories();
  }

  final CategoryService _categoryService;
  List<CategoryModel> _categories;

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  Future<void> _loadCategories() async {
    await refresh();
  }

  CategoryModel? findById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    _categories = await _categoryService.getCategories();
    notifyListeners();
  }

  Future<void> saveCategory(CategoryModel category) async {
    await _categoryService.saveCategory(category);
    await refresh();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryService.deleteCategory(id);
    await refresh();
  }
}