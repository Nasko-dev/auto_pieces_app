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
final userSettingsRemoteDataSourceProvider =
    Provider<UserSettingsRemoteDataSource>((ref) {
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

/// Provider pour vérifier si le profil particulier nécessite des actions (nom d'affichage)
final particulierProfileStatusProvider = FutureProvider<bool>((ref) async {
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null) return false;

  final getUserSettings = ref.read(getUserSettingsProvider);
  final result = await getUserSettings(currentUser.id);

  return result.fold(
    (failure) => true, // En cas d'erreur, afficher l'alerte
    (settings) {
      // Vérifier si le nom d'affichage est défini et différent des valeurs par défaut
      if (settings == null) return true;

      final displayName = settings.displayName;
      return displayName == null ||
          displayName.isEmpty ||
          displayName == 'Utilisateur';
    },
  );
});

/// Provider pour vérifier si les paramètres nécessitent des actions (localisation + téléphone)
final particulierSettingsStatusProvider = FutureProvider<bool>((ref) async {
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null) return false;

  final getUserSettings = ref.read(getUserSettingsProvider);
  final result = await getUserSettings(currentUser.id);

  return result.fold(
    (failure) => true, // En cas d'erreur, afficher l'alerte
    (settings) {
      // Vérifier si la localisation et le téléphone sont remplis
      if (settings == null) return true;

      // Vérifier la localisation (adresse ET ville ET code postal)
      final hasLocation = settings.address != null &&
          settings.address!.isNotEmpty &&
          settings.city != null &&
          settings.city!.isNotEmpty &&
          settings.postalCode != null &&
          settings.postalCode!.isNotEmpty;

      // Vérifier le téléphone
      final hasPhone = settings.phone != null && settings.phone!.isNotEmpty;

      // Retourner true si une des informations manque
      return !hasLocation || !hasPhone;
    },
  );
});

/// Provider combiné pour vérifier si les 3 points doivent afficher l'alerte
final particulierMenuStatusProvider = FutureProvider<bool>((ref) async {
  final profileStatus =
      await ref.watch(particulierProfileStatusProvider.future);
  final settingsStatus =
      await ref.watch(particulierSettingsStatusProvider.future);

  // Afficher l'alerte sur les 3 points si profil OU paramètres nécessitent une action
  return profileStatus || settingsStatus;
});
