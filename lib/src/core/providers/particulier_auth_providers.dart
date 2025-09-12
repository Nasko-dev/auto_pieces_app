import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/particulier_auth_local_datasource.dart';
import '../../features/auth/data/datasources/particulier_auth_remote_datasource.dart';
import '../../features/auth/data/repositories/particulier_auth_repository_impl.dart';
import '../../features/auth/domain/repositories/particulier_auth_repository.dart';
import '../../features/auth/domain/usecases/particulier_anonymous_auth.dart';
import '../../features/auth/domain/usecases/particulier_logout.dart';
import '../../features/auth/domain/usecases/get_current_particulier.dart';
import '../../features/auth/presentation/controllers/particulier_auth_controller.dart';
import '../services/device_service.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Device service provider
final deviceServiceProvider = Provider<DeviceService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return DeviceService(sharedPreferences);
});

// Data sources
final particulierAuthRemoteDataSourceProvider = Provider<ParticulierAuthRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final deviceService = ref.watch(deviceServiceProvider);
  return ParticulierAuthRemoteDataSourceImpl(
    supabaseClient: supabaseClient,
    deviceService: deviceService,
  );
});

final particulierAuthLocalDataSourceProvider = Provider<ParticulierAuthLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ParticulierAuthLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

// Repository
final particulierAuthRepositoryProvider = Provider<ParticulierAuthRepository>((ref) {
  final remoteDataSource = ref.watch(particulierAuthRemoteDataSourceProvider);
  final localDataSource = ref.watch(particulierAuthLocalDataSourceProvider);
  
  return ParticulierAuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Use cases
final particulierAnonymousAuthProvider = Provider<ParticulierAnonymousAuth>((ref) {
  final repository = ref.watch(particulierAuthRepositoryProvider);
  return ParticulierAnonymousAuth(repository);
});

final particulierLogoutProvider = Provider<ParticulierLogout>((ref) {
  final repository = ref.watch(particulierAuthRepositoryProvider);
  return ParticulierLogout(repository);
});

final getCurrentParticulierProvider = Provider<GetCurrentParticulier>((ref) {
  final repository = ref.watch(particulierAuthRepositoryProvider);
  return GetCurrentParticulier(repository);
});

// Controller
final particulierAuthControllerProvider = StateNotifierProvider<ParticulierAuthController, ParticulierAuthState>((ref) {
  final particulierAnonymousAuth = ref.watch(particulierAnonymousAuthProvider);
  final particulierLogout = ref.watch(particulierLogoutProvider);
  final getCurrentParticulier = ref.watch(getCurrentParticulierProvider);

  return ParticulierAuthController(
    particulierAnonymousAuth: particulierAnonymousAuth,
    particulierLogout: particulierLogout,
    getCurrentParticulier: getCurrentParticulier,
  );
});