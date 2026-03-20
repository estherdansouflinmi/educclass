// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educclass/features/auth/data/repositories/auth_repository.dart';
import 'package:educclass/features/auth/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = await getCurrentUserModel();
    if (user == null) throw Exception('Utilisateur introuvable');
    return user;
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(displayName);

    final userModel = UserModel(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(cred.user!.uid)
        .set(userModel.toJson());

    return userModel;
  }

  @override
  Future<UserModel> signInWithGoogle({required UserRole role}) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Connexion Google annulée');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    final uid = cred.user!.uid;

    final existing = await _firestore.collection('users').doc(uid).get();
    if (existing.exists) {
      return UserModel.fromJson(existing.data()!);
    }

    final userModel = UserModel(
      uid: uid,
      email: cred.user!.email!,
      displayName: cred.user!.displayName ?? 'Utilisateur',
      photoUrl: cred.user!.photoURL,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(userModel.toJson());
    return userModel;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUserModel() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }
}
