import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/user_model.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  late final StreamSubscription<User?> _userSubscription;

  AuthViewModel({required AuthRepository repository})
      : _repository = repository {
    _userSubscription = _repository.user.listen((user) {
      _currentUser = user;
      _authState =
          user != null ? AuthState.authenticated : AuthState.unauthenticated;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  AuthState _authState = AuthState.unknown;
  AuthState get authState => _authState;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isAuthorized => _currentUser?.isAuthorized ?? false;

  void checkSession() {
    final user = _repository.getLoggedInUser();
    if (user != null) {
      _currentUser = user;
      _authState = AuthState.authenticated;
    } else {
      _authState = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final user = await _repository.login(email, password);
    return user != null;
  }

  Future<bool> register(String email, String password) async {
    final user = await _repository.register(email, password);
    return user != null;
  }

  Future<void> logout() async {
    try {
      await updatePresence(false);
    } catch (_) {}
    await _repository.logout();
  }

  Future<void> updateDisplayName(String newName) async {
    await _repository.updateDisplayName(newName);
    final user = await _repository.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  Stream<List<User>> getPendingUsers() {
    return _repository.getPendingUsers();
  }

  Future<void> authorizeUser(String uid) async {
    await _repository.authorizeUser(uid);
  }

  Stream<List<User>> getAuthorizedUsers() {
    return _repository.getAuthorizedUsers();
  }

  Future<void> changeUserRole(String uid, UserRole newRole) async {
    await _repository.changeUserRole(uid, newRole);
  }

  Future<void> deleteUser(String uid) async {
    await _repository.deleteUser(uid);
  }

  Future<void> denyUser(String uid) async {
    await _repository.denyUser(uid);
  }

  Future<void> updatePresence(bool isOnline) async {
    await _repository.updatePresence(isOnline);
  }
}
