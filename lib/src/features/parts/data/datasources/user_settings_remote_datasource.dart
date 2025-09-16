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
      print('🔍 [UserSettingsDataSource] Récupération paramètres pour userId: $userId');

      // Obtenir le device_id pour rechercher les paramètres persistants
      final deviceId = await _deviceService.getDeviceId();
      print('📱 [UserSettingsDataSource] Recherche avec device_id: $deviceId');

      // Récupérer depuis la table particuliers en utilisant le device_id
      final response = await _supabaseClient
          .from('particuliers')
          .select()
          .eq('device_id', deviceId)
          .eq('is_anonymous', true)
          .maybeSingle();

      if (response == null) {
        print('ℹ️ [UserSettingsDataSource] Aucun particulier trouvé pour cet utilisateur');
        return null;
      }

      print('✅ [UserSettingsDataSource] Paramètres récupérés depuis particuliers: $response');

      // Adapter les données de la table particuliers vers le modèle UserSettings
      final adaptedData = {
        'userId': response['id'],
        'displayName': response['first_name'] ?? response['email'],
        'address': response['address'],
        'city': response['city'],
        'postalCode': response['zip_code'],
        // Utiliser des valeurs par défaut si les colonnes n'existent pas
        'country': response['country'] ?? 'France',
        'phone': response['phone'],
        'notificationsEnabled': response['notifications_enabled'] ?? true,
        'emailNotificationsEnabled': response['email_notifications_enabled'] ?? true,
        'createdAt': response['created_at'] != null ? DateTime.parse(response['created_at']) : null,
        'updatedAt': response['updated_at'] != null ? DateTime.parse(response['updated_at']) : null,
      };

      return UserSettingsModel.fromJson(adaptedData);
    } on PostgrestException catch (e) {
      print('❌ [UserSettingsDataSource] Erreur PostgreSQL: ${e.message}');
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      print('❌ [UserSettingsDataSource] Erreur inattendue: $e');
      throw ServerFailure('Erreur lors de la récupération des paramètres: $e');
    }
  }

  @override
  Future<UserSettingsModel> saveUserSettings(UserSettingsModel settings) async {
    try {
      print('💾 [UserSettingsDataSource] Sauvegarde paramètres dans particuliers pour: ${settings.userId}');

      // Obtenir le device_id pour la sauvegarde persistante
      final deviceId = await _deviceService.getDeviceId();
      print('📱 [UserSettingsDataSource] Sauvegarde avec device_id: $deviceId');

      final now = DateTime.now().toIso8601String();

      // D'abord, chercher si un enregistrement existe avec ce device_id
      final existingRecord = await _supabaseClient
          .from('particuliers')
          .select('id')
          .eq('device_id', deviceId)
          .eq('is_anonymous', true)
          .maybeSingle();

      final Map<String, dynamic> dataToSave;

      if (existingRecord != null) {
        // Mise à jour de l'enregistrement existant
        print('📝 [UserSettingsDataSource] Mise à jour enregistrement existant: ${existingRecord['id']}');
        dataToSave = {
          'address': settings.address,
          'city': settings.city,
          'zip_code': settings.postalCode,
          'phone': settings.phone,
          'updated_at': now,
        };

        final response = await _supabaseClient
            .from('particuliers')
            .update(dataToSave)
            .eq('id', existingRecord['id'])
            .select()
            .maybeSingle();

        if (response == null) {
          print('⚠️ [UserSettingsDataSource] Aucune ligne retournée après update');
          return settings;
        }

        print('✅ [UserSettingsDataSource] Paramètres mis à jour: $response');

        // Adapter la réponse
        final adaptedResponse = {
          'userId': response['id'],
          'displayName': response['first_name'] ?? response['email'],
          'address': response['address'],
          'city': response['city'],
          'postalCode': response['zip_code'],
          'country': response['country'] ?? settings.country,
          'phone': response['phone'],
          'notificationsEnabled': response['notifications_enabled'] ?? settings.notificationsEnabled,
          'emailNotificationsEnabled': response['email_notifications_enabled'] ?? settings.emailNotificationsEnabled,
          'createdAt': response['created_at'] != null ? DateTime.parse(response['created_at']) : null,
          'updatedAt': response['updated_at'] != null ? DateTime.parse(response['updated_at']) : null,
        };

        return UserSettingsModel.fromJson(adaptedResponse);
      } else {
        // Créer un nouvel enregistrement avec l'ID actuel et le device_id
        print('🆕 [UserSettingsDataSource] Création nouvel enregistrement');
        dataToSave = {
          'id': settings.userId,
          'device_id': deviceId,
          'is_anonymous': true,
          'address': settings.address,
          'city': settings.city,
          'zip_code': settings.postalCode,
          'phone': settings.phone,
          'created_at': now,
          'updated_at': now,
        };

        final response = await _supabaseClient
            .from('particuliers')
            .upsert(dataToSave, onConflict: 'id')
            .select()
            .maybeSingle();

        if (response == null) {
          print('⚠️ [UserSettingsDataSource] Aucune ligne retournée après création');
          return settings;
        }

        print('✅ [UserSettingsDataSource] Nouvel enregistrement créé: $response');

        // Adapter la réponse
        final adaptedResponse = {
          'userId': response['id'],
          'displayName': response['first_name'] ?? response['email'],
          'address': response['address'],
          'city': response['city'],
          'postalCode': response['zip_code'],
          'country': response['country'] ?? settings.country,
          'phone': response['phone'],
          'notificationsEnabled': response['notifications_enabled'] ?? settings.notificationsEnabled,
          'emailNotificationsEnabled': response['email_notifications_enabled'] ?? settings.emailNotificationsEnabled,
          'createdAt': response['created_at'] != null ? DateTime.parse(response['created_at']) : null,
          'updatedAt': response['updated_at'] != null ? DateTime.parse(response['updated_at']) : null,
        };

        return UserSettingsModel.fromJson(adaptedResponse);
      }
    } on PostgrestException catch (e) {
      print('❌ [UserSettingsDataSource] Erreur PostgreSQL: ${e.message}');
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      print('❌ [UserSettingsDataSource] Erreur inattendue: $e');
      throw ServerFailure('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  @override
  Future<void> deleteUserSettings(String userId) async {
    try {
      print('🗑️ [UserSettingsDataSource] Effacement des paramètres de localisation pour: $userId');

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

      print('✅ [UserSettingsDataSource] Paramètres de localisation effacés dans particuliers');
    } on PostgrestException catch (e) {
      print('❌ [UserSettingsDataSource] Erreur PostgreSQL: ${e.message}');
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      print('❌ [UserSettingsDataSource] Erreur inattendue: $e');
      throw ServerFailure('Erreur lors de la suppression des paramètres: $e');
    }
  }
}