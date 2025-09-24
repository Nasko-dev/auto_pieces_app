import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/device_service.dart';
import '../models/user_settings_model.dart';

abstract class UserSettingsRemoteDataSource {
  Future<UserSettingsModel?> getUserSettings(String userId);
  Future<UserSettingsModel> saveUserSettings(UserSettingsModel settings);
  Future<void> deleteUserSettings(String userId);
}

class UserSettingsRemoteDataSourceImpl implements UserSettingsRemoteDataSource {
  final SupabaseClient _supabaseClient;
  final DeviceService _deviceService;

  UserSettingsRemoteDataSourceImpl(this._supabaseClient, this._deviceService);

  @override
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    try {
      // Obtenir le device_id pour rechercher les paramètres persistants
      final deviceId = await _deviceService.getDeviceId();

      // Récupérer depuis la table particuliers en utilisant le device_id
      final response = await _supabaseClient
          .from('particuliers')
          .select()
          .eq('device_id', deviceId)
          .eq('is_anonymous', true)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Adapter les données de la table particuliers vers le modèle UserSettings
      final adaptedData = {
        'userId': response['id'],
        'displayName': response['first_name']?.isNotEmpty == true
            ? response['first_name']
            : (response['email']?.isNotEmpty == true ? response['email'] : 'Utilisateur'),
        'address': response['address'],
        'city': response['city'],
        'postalCode': response['zip_code'],
        // Utiliser des valeurs par défaut si les colonnes n'existent pas
        'country': response['country'] ?? 'France',
        'phone': response['phone'],
        'avatarUrl': response['avatar_url'],
        'notificationsEnabled': response['notifications_enabled'] ?? true,
        'emailNotificationsEnabled': response['email_notifications_enabled'] ?? true,
        'createdAt': response['created_at'] != null ?
            (response['created_at'] is String ? response['created_at'] : response['created_at'].toString()) : null,
        'updatedAt': response['updated_at'] != null ?
            (response['updated_at'] is String ? response['updated_at'] : response['updated_at'].toString()) : null,
      };

      return UserSettingsModel.fromJson(adaptedData);
    } on PostgrestException catch (e) {
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      throw ServerFailure('Erreur lors de la récupération des paramètres: $e');
    }
  }

  @override
  Future<UserSettingsModel> saveUserSettings(UserSettingsModel settings) async {
    try {
      // Obtenir le device_id pour la sauvegarde persistante
      final deviceId = await _deviceService.getDeviceId();

      final now = DateTime.now().toIso8601String();

      // D'abord, récupérer l'enregistrement complet existant avec ce device_id
      final existingRecord = await _supabaseClient
          .from('particuliers')
          .select()
          .eq('device_id', deviceId)
          .eq('is_anonymous', true)
          .maybeSingle();

      final Map<String, dynamic> dataToSave;

      if (existingRecord != null) {
        // Mise à jour de l'enregistrement existant en préservant les valeurs existantes

        // Construire les données en préservant les valeurs existantes si les nouvelles sont nulles
        dataToSave = {
          'first_name': settings.displayName ?? existingRecord['first_name'],
          'address': settings.address ?? existingRecord['address'],
          'city': settings.city ?? existingRecord['city'],
          'zip_code': settings.postalCode ?? existingRecord['zip_code'],
          'phone': settings.phone ?? existingRecord['phone'],
          'avatar_url': settings.avatarUrl ?? existingRecord['avatar_url'],
          'country': settings.country,
          'notifications_enabled': settings.notificationsEnabled,
          'email_notifications_enabled': settings.emailNotificationsEnabled,
          'updated_at': now,
        };

        final response = await _supabaseClient
            .from('particuliers')
            .update(dataToSave)
            .eq('id', existingRecord['id'])
            .select()
            .maybeSingle();

        if (response == null) {
          return settings;
        }

        // Adapter la réponse
        final adaptedResponse = {
          'userId': response['id'],
          'displayName': response['first_name']?.isNotEmpty == true
            ? response['first_name']
            : (response['email']?.isNotEmpty == true ? response['email'] : 'Utilisateur'),
          'address': response['address'],
          'city': response['city'],
          'postalCode': response['zip_code'],
          'country': response['country'] ?? settings.country,
          'phone': response['phone'],
          'avatarUrl': response['avatar_url'],
          'notificationsEnabled': response['notifications_enabled'] ?? settings.notificationsEnabled,
          'emailNotificationsEnabled': response['email_notifications_enabled'] ?? settings.emailNotificationsEnabled,
          'createdAt': response['created_at'] != null ?
              (response['created_at'] is String ? response['created_at'] : response['created_at'].toString()) : null,
          'updatedAt': response['updated_at'] != null ?
              (response['updated_at'] is String ? response['updated_at'] : response['updated_at'].toString()) : null,
        };

        return UserSettingsModel.fromJson(adaptedResponse);
      } else {
        // Créer un nouvel enregistrement avec l'ID actuel et le device_id
        dataToSave = {
          'id': settings.userId,
          'device_id': deviceId,
          'is_anonymous': true,
          'first_name': settings.displayName,
          'address': settings.address,
          'city': settings.city,
          'zip_code': settings.postalCode,
          'phone': settings.phone,
          'avatar_url': settings.avatarUrl,
          'country': settings.country,
          'notifications_enabled': settings.notificationsEnabled,
          'email_notifications_enabled': settings.emailNotificationsEnabled,
          'created_at': now,
          'updated_at': now,
        };

        final response = await _supabaseClient
            .from('particuliers')
            .upsert(dataToSave, onConflict: 'id')
            .select()
            .maybeSingle();

        if (response == null) {
          return settings;
        }

        // Adapter la réponse
        final adaptedResponse = {
          'userId': response['id'],
          'displayName': response['first_name']?.isNotEmpty == true
            ? response['first_name']
            : (response['email']?.isNotEmpty == true ? response['email'] : 'Utilisateur'),
          'address': response['address'],
          'city': response['city'],
          'postalCode': response['zip_code'],
          'country': response['country'] ?? settings.country,
          'phone': response['phone'],
          'avatarUrl': response['avatar_url'],
          'notificationsEnabled': response['notifications_enabled'] ?? settings.notificationsEnabled,
          'emailNotificationsEnabled': response['email_notifications_enabled'] ?? settings.emailNotificationsEnabled,
          'createdAt': response['created_at'] != null ?
              (response['created_at'] is String ? response['created_at'] : response['created_at'].toString()) : null,
          'updatedAt': response['updated_at'] != null ?
              (response['updated_at'] is String ? response['updated_at'] : response['updated_at'].toString()) : null,
        };

        return UserSettingsModel.fromJson(adaptedResponse);
      }
    } on PostgrestException catch (e) {
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      throw ServerFailure('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  @override
  Future<void> deleteUserSettings(String userId) async {
    try {
      // Effacer seulement les colonnes de localisation dans la table particuliers
      final dataToUpdate = {
        'address': null,
        'city': null,
        'zip_code': null,
        'phone': null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('particuliers')
          .update(dataToUpdate)
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      throw ServerFailure('Erreur lors de la suppression des paramètres: $e');
    }
  }
}