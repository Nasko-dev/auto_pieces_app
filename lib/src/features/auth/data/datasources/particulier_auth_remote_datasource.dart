import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/device_service.dart';
import '../models/particulier_model.dart';

abstract class ParticulierAuthRemoteDataSource {
  Future<ParticulierModel> signInAnonymously();

  Future<void> logout();

  Future<ParticulierModel> getCurrentParticulier();

  Future<bool> isLoggedIn();

  Future<ParticulierModel> updateParticulier(ParticulierModel particulier);
}

class ParticulierAuthRemoteDataSourceImpl implements ParticulierAuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final DeviceService deviceService;

  ParticulierAuthRemoteDataSourceImpl({
    required this.supabaseClient, 
    required this.deviceService,
  });

  @override
  Future<ParticulierModel> signInAnonymously() async {
    try {
      print('👤 [DataSource] Connexion anonyme avec persistance device');

      // 1. Obtenir l'ID de l'appareil
      final deviceId = await deviceService.getDeviceId();
      print('📱 [DataSource] Device ID: $deviceId');

      // 2. Vérifier si un particulier existe déjà pour cet appareil
      print('🔍 [DataSource] Début recherche particulier existant pour device: $deviceId');
      
      // D'abord, vérifier tous les utilisateurs avec ce device_id
      try {
        print('🔍 [DataSource] Recherche TOUS les utilisateurs avec ce device_id...');
        final allUsersWithDeviceId = await supabaseClient
            .from('particuliers')
            .select()
            .eq('device_id', deviceId);
            
        print('📊 [DataSource] Utilisateurs trouvés avec device_id $deviceId: ${allUsersWithDeviceId.length}');
        for (int i = 0; i < allUsersWithDeviceId.length; i++) {
          final user = allUsersWithDeviceId[i];
          print('👤 [DataSource] Utilisateur $i: id=${user['id']}, is_anonymous=${user['is_anonymous']}, device_id=${user['device_id']}');
        }
      } catch (e) {
        print('⚠️ [DataSource] Erreur recherche tous utilisateurs: $e');
      }
      
      // Maintenant, recherche spécifique pour utilisateur anonyme
      try {
        print('📊 [DataSource] Exécution requête Supabase pour recherche existante (anonyme seulement)...');
        final existingUser = await supabaseClient
            .from('particuliers')
            .select()
            .eq('device_id', deviceId)
            .eq('is_anonymous', true)
            .maybeSingle();

        print('🎯 [DataSource] Résultat recherche existante (anonyme): ${existingUser != null ? "TROUVÉ" : "NON TROUVÉ"}');
        
        if (existingUser != null) {
          print('✅ [DataSource] Particulier existant trouvé pour ce device: ${existingUser['id']}');
          print('📋 [DataSource] Données utilisateur existant: $existingUser');
          
          // Se connecter avec le compte existant via Supabase auth
          try {
            print('🔐 [DataSource] Tentative connexion anonyme pour utilisateur existant...');
            final authResponse = await supabaseClient.auth.signInAnonymously();
            if (authResponse.user != null) {
              print('✅ [DataSource] Connexion anonyme réussie pour utilisateur existant: ${authResponse.user!.id}');
              // Retourner le particulier existant avec le nouvel auth ID
              final existingParticulier = ParticulierModel.fromJson(existingUser).copyWith(
                id: authResponse.user!.id, // Nouveau auth ID
              ) as ParticulierModel;
              print('🎉 [DataSource] Retour utilisateur existant avec nouvel auth ID');
              return existingParticulier;
            } else {
              print('❌ [DataSource] Échec connexion anonyme: user null');
            }
          } catch (authError) {
            print('⚠️ [DataSource] Échec auth pour utilisateur existant, création nouveau compte: $authError');
          }
        } else {
          print('👻 [DataSource] Aucun particulier anonyme existant trouvé pour device: $deviceId');
          
          // Essayer de trouver un utilisateur non-anonyme et le convertir
          try {
            print('🔄 [DataSource] Recherche utilisateur non-anonyme à convertir...');
            final nonAnonymousUser = await supabaseClient
                .from('particuliers')
                .select()
                .eq('device_id', deviceId)
                .eq('is_anonymous', false)
                .maybeSingle();
                
            if (nonAnonymousUser != null) {
              print('🔄 [DataSource] Utilisateur non-anonyme trouvé, conversion en anonyme...');
              // Mettre à jour pour le marquer comme anonyme
              await supabaseClient
                  .from('particuliers')
                  .update({'is_anonymous': true})
                  .eq('id', nonAnonymousUser['id']);
              
              // Se connecter avec ce compte converti
              final authResponse = await supabaseClient.auth.signInAnonymously();
              if (authResponse.user != null) {
                final convertedUser = ParticulierModel.fromJson(nonAnonymousUser).copyWith(
                  id: authResponse.user!.id,
                  isAnonymous: true,
                ) as ParticulierModel;
                print('✅ [DataSource] Utilisateur converti en anonyme avec succès');
                return convertedUser;
              }
            }
          } catch (conversionError) {
            print('⚠️ [DataSource] Erreur conversion utilisateur: $conversionError');
          }
        }
      } catch (e) {
        print('⚠️ [DataSource] Erreur recherche particulier existant: $e');
        print('📝 [DataSource] Type erreur: ${e.runtimeType}');
        print('📝 [DataSource] Message erreur: ${e.toString()}');
      }

      // 3. Créer un nouveau compte anonyme
      print('🆕 [DataSource] Création nouveau compte anonyme');
      final authResponse = await supabaseClient.auth.signInAnonymously();

      if (authResponse.user == null) {
        print('❌ [DataSource] Échec connexion anonyme: utilisateur null');
        throw const ServerException('Échec de la connexion anonyme');
      }

      print('✅ [DataSource] Nouvelle connexion anonyme réussie: ${authResponse.user!.id}');

      // 4. Créer le modèle avec device_id
      final particulierModel = ParticulierModel.fromAnonymousAuth(
        id: authResponse.user!.id,
        deviceId: deviceId,
        createdAt: DateTime.parse(authResponse.user!.createdAt),
      );

      // 5. Insérer dans la table particuliers avec device_id
      try {
        print('📝 [DataSource] Insertion nouveau particulier avec device_id...');
        print('📊 [DataSource] Données à insérer: ${particulierModel.toInsert()}');
        await supabaseClient.from('particuliers').insert(particulierModel.toInsert());
        print('✅ [DataSource] Insertion table particuliers réussie');
      } catch (e) {
        print('⚠️ [DataSource] Erreur insertion table: $e');
        print('📝 [DataSource] Type erreur insertion: ${e.runtimeType}');
        print('📝 [DataSource] Message erreur insertion: ${e.toString()}');
        // Continue même si l'insertion en table échoue
      }

      return particulierModel;

    } on AuthException catch (e) {
      print('❌ [DataSource] Erreur auth: ${e.message}');
      throw ServerException(e.message);
    } catch (e) {
      print('❌ [DataSource] Erreur: $e');
      throw ServerException('Erreur lors de la connexion anonyme: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🚪 [DataSource] Déconnexion particulier');
      
      // Déconnexion globale pour nettoyer toutes les sessions
      await supabaseClient.auth.signOut(scope: SignOutScope.global);
      
      print('✅ [DataSource] Déconnexion réussie');
    } catch (e) {
      print('❌ [DataSource] Erreur déconnexion: $e');
      throw ServerException('Erreur lors de la déconnexion: $e');
    }
  }

  @override
  Future<ParticulierModel> getCurrentParticulier() async {
    try {
      print('👤 [DataSource] Récupération particulier actuel');

      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        print('❌ [DataSource] Aucun utilisateur connecté');
        throw const ServerException('Aucun utilisateur connecté');
      }

      print('✅ [DataSource] Utilisateur trouvé: ${user.id}');

      // Vérifier si c'est un utilisateur anonyme
      if (user.isAnonymous) {
        print('👤 [DataSource] Utilisateur anonyme détecté');
        final deviceId = await deviceService.getDeviceId();
        return ParticulierModel.fromAnonymousAuth(
          id: user.id,
          deviceId: deviceId,
          createdAt: DateTime.parse(user.createdAt),
        );
      }

      // Essayer de récupérer depuis la table particuliers pour utilisateur avec email
      try {
        final userData = await supabaseClient
            .from('particuliers')
            .select()
            .eq('id', user.id)
            .single();

        return ParticulierModel.fromJson(userData);
      } catch (e) {
        print('⚠️ [DataSource] Table particuliers non trouvée, fallback auth: $e');
        // Fallback sur les données auth
        return ParticulierModel.fromSupabaseAuth(
          id: user.id,
          email: user.email!,
          createdAt: DateTime.parse(user.createdAt),
          emailConfirmedAt: user.emailConfirmedAt != null
              ? DateTime.parse(user.emailConfirmedAt!)
              : null,
        );
      }

    } catch (e) {
      print('❌ [DataSource] Erreur: $e');
      throw ServerException('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final user = supabaseClient.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ParticulierModel> updateParticulier(ParticulierModel particulier) async {
    try {
      print('💾 [DataSource] Mise à jour particulier: ${particulier.id}');

      final dataToUpdate = {
        'first_name': particulier.firstName,
        'last_name': particulier.lastName,
        'phone': particulier.phone,
        'address': particulier.address,
        'city': particulier.city,
        'zip_code': particulier.zipCode,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('📊 [DataSource] Données à mettre à jour: $dataToUpdate');

      final response = await supabaseClient
          .from('particuliers')
          .update(dataToUpdate)
          .eq('id', particulier.id)
          .select()
          .single();

      print('✅ [DataSource] Particulier mis à jour: $response');

      return ParticulierModel.fromJson(response);
    } catch (e) {
      print('❌ [DataSource] Erreur mise à jour: $e');
      throw ServerException('Erreur lors de la mise à jour du particulier: $e');
    }
  }
}