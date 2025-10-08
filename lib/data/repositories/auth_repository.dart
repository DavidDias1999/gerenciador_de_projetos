import 'package:drift/isolate.dart';
import '../../domain/models/user_model.dart';
import '../local/database.dart';
import '../services/session_service.dart';

class AuthRepository {
  final AppDatabase _db;
  final SessionService _sessionService;

  AuthRepository(
      {required AppDatabase database, required SessionService sessionService})
      : _db = database,
        _sessionService = sessionService;

  Future<User?> login(String username, String password) async {
    final user = await _db.getUserByUsername(username);
    if (user != null && user.password == password) {
      await _sessionService.saveSession(user.id);
      return User(id: user.id, username: user.username);
    }
    return null;
  }

  Future<User?> register(String username, String password) async {
    try {
      final newUser =
          UsersCompanion.insert(username: username, password: password);
      final id = await _db.createUser(newUser);
      await _sessionService.saveSession(id);
      return User(id: id, username: username);
    } on DriftRemoteException catch (e) {
      if (e.remoteCause.toString().contains('UNIQUE constraint failed')) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
  }

  Future<User?> getLoggedInUser() async {
    final userId = await _sessionService.getSessionUserId();
    if (userId != null) {
      final userData = await _db.getUserById(userId);
      if (userData != null) {
        return User(id: userData.id, username: userData.username);
      }
    }
    return null;
  }
}
