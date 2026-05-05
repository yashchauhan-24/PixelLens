import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/user_service.dart';

class UserController extends ChangeNotifier {
  UserController(this._userService) : _users = [] {
    _loadUsers();
  }

  final UserService _userService;
  List<AppUser> _users;

  List<AppUser> get users => List.unmodifiable(_users);

  Future<void> _loadUsers() async {
    await refresh();
  }

  Future<void> refresh() async {
    _users = await _userService.fetchUsers();
    notifyListeners();
  }

  Future<void> deleteUser(String id) async {
    await _userService.deleteUser(id);
    await refresh();
  }

  AppUser? findById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (_) {
      return null;
    }
  }
}
