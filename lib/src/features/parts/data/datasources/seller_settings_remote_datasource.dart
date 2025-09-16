import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../models/seller_settings_model.dart';

abstract class SellerSettingsRemoteDataSource {
  Future<SellerSettingsModel?> getSellerSettings(String sellerId);
  Future<SellerSettingsModel> saveSellerSettings(SellerSettingsModel settings);
  Future<void> deleteSellerSettings(String sellerId);
}

class SellerSettingsRemoteDataSourceImpl implements SellerSettingsRemoteDataSource {
  final SupabaseClient _supabaseClient;

  SellerSettingsRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<SellerSettingsModel?> getSellerSettings(String sellerId) async {
    try {
      print('🔍 [SellerSettingsDataSource] Récupération paramètres pour sellerId: $sellerId');

      // Récupérer depuis la table sellers en utilisant l'ID du vendeur
      final response = await _supabaseClient
          .from('sellers')
          .select()
          .eq('id', sellerId)
          .maybeSingle();

      if (response == null) {
        print('ℹ️ [SellerSettingsDataSource] Aucun vendeur trouvé pour cet utilisateur');
        return null;
      }

      print('✅ [SellerSettingsDataSource] Paramètres récupérés depuis sellers: $response');

      // Adapter les données de la table sellers vers le modèle SellerSettings
      final adaptedData = {
        'sellerId': response['id'],
        'email': response['email'],
        'firstName': response['first_name'],
        'lastName': response['last_name'],
        'companyName': response['company_name'],
        'phone': response['phone'],
        'address': response['address'],
        'city': response['city'],
        'postalCode': response['zip_code'],
        'siret': response['siret'],
        'avatarUrl': response['avatar_url'],
        'notificationsEnabled': response['notifications_enabled'] ?? true,
        'emailNotificationsEnabled': response['email_notifications_enabled'] ?? true,
        'isActive': response['is_active'] ?? true,
        'isVerified': response['is_verified'] ?? false,
        'emailVerifiedAt': response['email_verified_at'],
        'createdAt': response['created_at'],
        'updatedAt': response['updated_at'],
      };

      return SellerSettingsModel.fromJson(adaptedData);
    } on PostgrestException catch (e) {
      print('❌ [SellerSettingsDataSource] Erreur PostgreSQL: ${e.message}');
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      print('❌ [SellerSettingsDataSource] Erreur inattendue: $e');
      throw ServerFailure('Erreur lors de la récupération des paramètres: $e');
    }
  }

  @override
  Future<SellerSettingsModel> saveSellerSettings(SellerSettingsModel settings) async {
    try {
      print('💾 [SellerSettingsDataSource] Sauvegarde paramètres dans sellers pour: ${settings.sellerId}');

      final now = DateTime.now().toIso8601String();

      // D'abord, récupérer l'enregistrement complet existant
      final existingRecord = await _supabaseClient
          .from('sellers')
          .select()
          .eq('id', settings.sellerId)
          .maybeSingle();

      if (existingRecord != null) {
        // Mise à jour de l'enregistrement existant en préservant les valeurs existantes
        print('📝 [SellerSettingsDataSource] Mise à jour enregistrement existant: ${existingRecord['id']}');

        // Construire les données en préservant les valeurs existantes si les nouvelles sont nulles
        final dataToSave = {
          'first_name': settings.firstName ?? existingRecord['first_name'],
          'last_name': settings.lastName ?? existingRecord['last_name'],
          'company_name': settings.companyName ?? existingRecord['company_name'],
          'phone': settings.phone ?? existingRecord['phone'],
          'address': settings.address ?? existingRecord['address'],
          'city': settings.city ?? existingRecord['city'],
          'zip_code': settings.postalCode ?? existingRecord['zip_code'],
          'siret': settings.siret ?? existingRecord['siret'],
          'avatar_url': settings.avatarUrl ?? existingRecord['avatar_url'],
          'notifications_enabled': settings.notificationsEnabled,
          'email_notifications_enabled': settings.emailNotificationsEnabled,
          'updated_at': now,
        };

        final response = await _supabaseClient
            .from('sellers')
            .update(dataToSave)
            .eq('id', existingRecord['id'])
            .select()
            .maybeSingle();

        if (response == null) {
          print('⚠️ [SellerSettingsDataSource] Aucune ligne retournée après update');
          return settings;
        }

        print('✅ [SellerSettingsDataSource] Paramètres mis à jour: $response');

        // Adapter la réponse
        final adaptedResponse = {
          'sellerId': response['id'],
          'email': response['email'],
          'firstName': response['first_name'],
          'lastName': response['last_name'],
          'companyName': response['company_name'],
          'phone': response['phone'],
          'address': response['address'],
          'city': response['city'],
          'postalCode': response['zip_code'],
          'siret': response['siret'],
          'avatarUrl': response['avatar_url'],
          'notificationsEnabled': response['notifications_enabled'] ?? settings.notificationsEnabled,
          'emailNotificationsEnabled': response['email_notifications_enabled'] ?? settings.emailNotificationsEnabled,
          'isActive': response['is_active'] ?? settings.isActive,
          'isVerified': response['is_verified'] ?? settings.isVerified,
          'emailVerifiedAt': response['email_verified_at'],
          'createdAt': response['created_at'],
          'updatedAt': response['updated_at'],
        };

        return SellerSettingsModel.fromJson(adaptedResponse);
      } else {
        print('❌ [SellerSettingsDataSource] Vendeur non trouvé pour mise à jour: ${settings.sellerId}');
        throw ServerFailure('Vendeur non trouvé');
      }
    } on PostgrestException catch (e) {
      print('❌ [SellerSettingsDataSource] Erreur PostgreSQL: ${e.message}');
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      print('❌ [SellerSettingsDataSource] Erreur inattendue: $e');
      throw ServerFailure('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  @override
  Future<void> deleteSellerSettings(String sellerId) async {
    try {
      print('🗑️ [SellerSettingsDataSource] Effacement des données de profil pour: $sellerId');

      // Effacer seulement les données de profil (pas l'email ni l'authentification)
      final dataToUpdate = {
        'first_name': null,
        'last_name': null,
        'company_name': null,
        'phone': null,
        'address': null,
        'city': null,
        'zip_code': null,
        'siret': null,
        'avatar_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('sellers')
          .update(dataToUpdate)
          .eq('id', sellerId);

      print('✅ [SellerSettingsDataSource] Données de profil effacées dans sellers');
    } on PostgrestException catch (e) {
      print('❌ [SellerSettingsDataSource] Erreur PostgreSQL: ${e.message}');
      throw ServerFailure('Erreur de base de données: ${e.message}');
    } catch (e) {
      print('❌ [SellerSettingsDataSource] Erreur inattendue: $e');
      throw ServerFailure('Erreur lors de la suppression des paramètres: $e');
    }
  }
}