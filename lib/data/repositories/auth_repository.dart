import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/models/user_model.dart';

class AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;

  AuthRepository({firebase.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance;

  User? _userFromFirebase(firebase.User? user) {
    if (user == null) {
      return null;
    }
    return User(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
    );
  }

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(credential.user);
    } on firebase.FirebaseAuthException {
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final defaultName = email.split('@').first;
      await credential.user?.updateDisplayName(defaultName);

      await credential.user?.reload();
      final updatedUser = _firebaseAuth.currentUser;

      return _userFromFirebase(updatedUser);
    } on firebase.FirebaseAuthException {
      return null;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  User? getLoggedInUser() {
    return _userFromFirebase(_firebaseAuth.currentUser);
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(newName);

      await _firebaseAuth.currentUser?.reload();
    } on firebase.FirebaseAuthException catch (e) {
      throw Exception('Erro ao atualizar o nome: ${e.message}');
    }
  }
}
