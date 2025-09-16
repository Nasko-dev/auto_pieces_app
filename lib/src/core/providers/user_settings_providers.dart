import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/network_info.dart';
import '../services/device_service.dart';
import './particulier_auth_providers.dart' show sharedPreferencesProvider;
import '../../features/parts/data/datasources/user_settings_remote_datasource.dart';
import '../../features/parts/data/repositories/user_settings_repository_impl.dart';
import '../../features/parts/domain/repositories/user_settings_repository.dart';
import '../../features/parts/domain/usecases/get_user_settings.dart';
import '../../features/parts/domain/usecases/save_user_settings.dart';

// DeviceService Provider
final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService(ref.watch(sharedPreferencesProvider));
});

// DataSource
final userSettingsRemoteDataSourceProvider = Provider<UserSettingsRemoteDataSource>((ref) {
  return UserSettingsRemoteDataSourceImpl(
    Supabase.instance.client,
    ref.watch(deviceServiceProvider),
  );
});

// Repository
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return UserSettingsRepositoryImpl(
    remoteDataSource: ref.watch(userSettingsRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use Cases
final getUserSettingsProvider = Provider<GetUserSettings>((ref) {
  return GetUserSettings(ref.watch(userSettingsRepositoryProvider));
});

final saveUserSettingsProvider = Provider<SaveUserSettings>((ref) {
  return SaveUserSettings(ref.watch(userSettingsRepositoryProvider));
});