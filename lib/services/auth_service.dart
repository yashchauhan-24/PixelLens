import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  Future<AppUser?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return await _fetchUserByUid(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthMessage(e));
    } catch (_) {
      throw Exception('Unable to sign in right now. Please try again.');
    }
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = AppUser(
        id: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        role: role == 'admin' ? UserRole.admin : UserRole.user,
        phone: phone,
        address: address,
        profileImage: profileImage,
      );
      await _users.doc(user.id).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthMessage(e));
    } catch (_) {
      throw Exception('Unable to create account right now. Please try again.');
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      return await _fetchUserByUid(userCred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthMessage(e));
    } catch (_) {
      throw Exception('Unable to sign in with Google right now.');
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<AppUser?> fetchCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    return _fetchUserByUid(currentUser.uid);
  }

  Future<AppUser?> updateUserProfile(AppUser user) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is signed in.');
    }

    final updated = user.copyWith(
      id: currentUser.uid,
      email: currentUser.email ?? user.email,
    );

    await _users.doc(currentUser.uid).set(updated.toMap(), SetOptions(merge: true));
    return _fetchUserByUid(currentUser.uid);
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.email == null) {
      throw Exception('No user is signed in.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: oldPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthMessage(e));
    } catch (_) {
      throw Exception('Unable to change password right now.');
    }
  }

  Future<AppUser?> _fetchUserByUid(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      final authUser = _auth.currentUser;
      if (authUser == null) return null;
      final fallback = AppUser(
        id: authUser.uid,
        name: authUser.displayName ?? authUser.email?.split('@').first ?? 'User',
        email: authUser.email ?? '',
        role: UserRole.user,
      );
      await _users.doc(uid).set(fallback.toMap(), SetOptions(merge: true));
      return fallback;
    }

    final data = snapshot.data()!;
    final roleValue = (data['role'] as String?) ?? UserRole.user.name;
    return AppUser(
      id: snapshot.id,
      name: (data['name'] as String?) ?? 'User',
      email: (data['email'] as String?) ?? '',
      role: roleValue == UserRole.admin.name ? UserRole.admin : UserRole.user,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      profileImage: data['profileImage'] as String?,
    );
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'requires-recent-login':
        return 'Please login again and retry.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
