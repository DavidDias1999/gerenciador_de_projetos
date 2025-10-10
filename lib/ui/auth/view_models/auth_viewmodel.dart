import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/user_model.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  AuthViewModel({required AuthRepository repository})
      : _repository = repository;

  AuthState _authState = AuthState.unknown;
  AuthState get authState => _authState;

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> checkSession() async {
    final user = await _repository.getLoggedInUser();
    if (user != null) {
      _currentUser = user;
      _authState = AuthState.authenticated;
    } else {
      _authState = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final user = await _repository.login(username, password);
    if (user != null) {
      _currentUser = user;
      _authState = AuthState.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    final user = await _repository.register(username, password);
    if (user != null) {
      _currentUser = user;
      _authState = AuthState.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _authState = AuthState.unauthenticated;
    notifyListeners();
  }
}
