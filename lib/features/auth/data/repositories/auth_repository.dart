// lib/features/auth/data/repositories/auth_repository.dart
import 'package:educclass/features/auth/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  });
  Future<UserModel> signInWithGoogle({required UserRole role});
  Future<void> signOut();
  Future<UserModel?> getCurrentUserModel();
  Future<void> updateFcmToken(String token);
}
