import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    firebase.FirebaseAuth? firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _firestore = firestore;

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      return await _fetchUserFromFirestore(firebaseUser);
    });
  }

  Future<User?> _fetchUserFromFirestore(firebase.User? firebaseUser) async {
    if (firebaseUser == null) return null;
    
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data()!);
      }
      
      // Se o usuário existir no Firebase Auth mas não no Firestore (Legado da Produção)
      // Nós o criamos agora no Firestore com a mesma regra do registro
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      final role = usersSnapshot.docs.isEmpty ? UserRole.admin : UserRole.collaborator;
      final isAuthorized = usersSnapshot.docs.isEmpty ? true : false;

      final newUser = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
        role: role,
        isAuthorized: isAuthorized,
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
      return newUser;
      
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      );
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _fetchUserFromFirestore(credential.user);
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

      final updatedUser = credential.user;

      if (updatedUser == null) return null;

      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      final role = usersSnapshot.docs.isEmpty ? UserRole.admin : UserRole.collaborator;
      final isAuthorized = usersSnapshot.docs.isEmpty ? true : false;

      final newUser = User(
        id: updatedUser.uid,
        email: email,
        name: null,
        role: role,
        isAuthorized: isAuthorized,
        isActive: true,
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());

      return newUser;
    } on firebase.FirebaseAuthException {
      return null;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<User?> getCurrentUser() async {
    return await _fetchUserFromFirestore(_firebaseAuth.currentUser);
  }

  User? getLoggedInUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return User(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
    );
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(newName);
      await _firebaseAuth.currentUser?.reload();
      
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({'name': newName});
      }
    } on firebase.FirebaseAuthException catch (e) {
      throw Exception('Erro ao atualizar o nome: ${e.message}');
    }
  }

  Stream<List<User>> getPendingUsers() {
    return _firestore
        .collection('users')
        .where('isAuthorized', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          .where((user) => user.isActive)
          .toList();
    });
  }

  Future<void> authorizeUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isAuthorized': true});
  }

  Future<void> updatePresence(bool isOnline) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<User>> getAuthorizedUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          // Garante que o admin primário apareça, mesmo se estiver sem a flag isAuthorized no BD (legado)
          .where((user) => user.isAuthorized || user.role == UserRole.admin)
          // Também podemos filtrar por isActive caso existam deletados sem isAuthorized=false
          .where((user) => user.isActive)
          .toList();
    });
  }

  Future<void> changeUserRole(String uid, UserRole newRole) async {
    final roleString = newRole == UserRole.admin ? 'admin' : 'collaborator';
    await _firestore.collection('users').doc(uid).update({'role': roleString});
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': false,
      'isAuthorized': false,
    });
  }

  Future<void> denyUser(String uid) async {
    // Removemos o documento do usuário. Ele continuará existindo no Firebase Auth, 
    // mas sumirá da lista de pendentes.
    await _firestore.collection('users').doc(uid).delete();
  }
}
