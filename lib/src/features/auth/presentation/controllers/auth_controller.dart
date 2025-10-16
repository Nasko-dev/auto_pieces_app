import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_as_particulier.dart';
import '../../../../core/services/notification_manager.dart';

// Providers for data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

// Provider for repository
final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
  );
});

// Provider for use cases
final loginAsParticulierProvider = Provider((ref) {
  return LoginAsParticulier(ref.read(authRepositoryProvider));
});

// State providers
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(
    loginAsParticulier: ref.read(loginAsParticulierProvider),
    repository: ref.read(authRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final LoginAsParticulier loginAsParticulier;
  final AuthRepositoryImpl repository;

  AuthNotifier({
    required this.loginAsParticulier,
    required this.repository,
  }) : super(const AsyncValue.data(null));

  Future<void> loginParticulier() async {
    state = const AsyncValue.loading();
    final result = await loginAsParticulier();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) async {
        state = AsyncValue.data(user);

        // Synchroniser le Player ID après une connexion réussie
        await NotificationManager.instance.forceSyncPlayerId();
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await repository.logout();
    state = const AsyncValue.data(null);
  }
}
