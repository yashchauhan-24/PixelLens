import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class UserService {
  UserService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  Future<List<AppUser>> fetchUsers() async {
    if (!await _isAdmin()) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];
      final current = await findUserById(currentUser.uid);
      return current == null ? [] : [current];
    }
    final snapshot = await _users.orderBy('name').get();
    return snapshot.docs.map(_userFromDoc).toList();
  }

  Future<AppUser?> findUserById(String id) async {
    final snapshot = await _users.doc(id).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return _userFromDoc(snapshot);
  }

  Future<AppUser> updateUser(AppUser user) async {
    await _users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    return user;
  }

  Future<void> deleteUser(String id) async {
    await _users.doc(id).delete();
  }

  Future<bool> _isAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;
    final snapshot = await _users.doc(currentUser.uid).get();
    return snapshot.data()?['role'] == 'admin';
  }

  AppUser _userFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      id: doc.id,
      name: (data['name'] as String?) ?? 'User',
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String? ?? 'user') == 'admin' ? UserRole.admin : UserRole.user,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      profileImage: data['profileImage'] as String?,
    );
  }
}
