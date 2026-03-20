// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:educclass/core/providers/firebase_providers.dart';
import 'package:educclass/features/auth/data/repositories/auth_repository.dart';
import 'package:educclass/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:educclass/features/auth/domain/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  if (authState == null) return null;
  return ref.read(authRepositoryProvider).getCurrentUserModel();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final authState = await ref.watch(authStateProvider.future);
    if (authState == null) return null;
    return ref.read(authRepositoryProvider).getCurrentUserModel();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).registerWithEmail(
            email: email,
            password: password,
            displayName: displayName,
            role: role,
          ),
    );
  }

  Future<void> signInWithGoogle({required UserRole role}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(role: role),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
