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

      // 1. Obtenir l'ID de l'appareil
      final deviceId = await deviceService.getDeviceId();

      // 2. Vérifier si un particulier existe déjà pour cet appareil
      
      // D'abord, vérifier tous les utilisateurs avec ce device_id
      try {
        final allUsersWithDeviceId = await supabaseClient
            .from('particuliers')
            .select()
            .eq('device_id', deviceId);
            
        for (int i = 0; i < allUsersWithDeviceId.length; i++) {
          final user = allUsersWithDeviceId[i];
        }
      } catch (e) {
      }
      
      // Maintenant, recherche spécifique pour utilisateur anonyme
      try {
        final existingUser = await supabaseClient
            .from('particuliers')
            .select()
            .eq('device_id', deviceId)
            .eq('is_anonymous', true)
            .maybeSingle();

        
        if (existingUser != null) {
          
          // Se connecter avec le compte existant via Supabase auth
          try {
            final authResponse = await supabaseClient.auth.signInAnonymously();
            if (authResponse.user != null) {
              // Retourner le particulier existant avec le nouvel auth ID
              final existingParticulier = ParticulierModel.fromJson(existingUser).copyWith(
                id: authResponse.user!.id, // Nouveau auth ID
              );
              return existingParticulier;
            } else {
            }
          } catch (authError) {
          }
        } else {
          
          // Essayer de trouver un utilisateur non-anonyme et le convertir
          try {
            final nonAnonymousUser = await supabaseClient
                .from('particuliers')
                .select()
                .eq('device_id', deviceId)
                .eq('is_anonymous', false)
                .maybeSingle();
                
            if (nonAnonymousUser != null) {
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
                );
                return convertedUser;
              }
            }
          } catch (conversionError) {
          }
        }
      } catch (e) {
      }

      // 3. Créer un nouveau compte anonyme
      final authResponse = await supabaseClient.auth.signInAnonymously();

      if (authResponse.user == null) {
        throw const ServerException('Échec de la connexion anonyme');
      }


      // 4. Créer le modèle avec device_id
      final particulierModel = ParticulierModel.fromAnonymousAuth(
        id: authResponse.user!.id,
        deviceId: deviceId,
        createdAt: DateTime.parse(authResponse.user!.createdAt),
      );

      // 5. Insérer dans la table particuliers avec device_id
      try {
        await supabaseClient.from('particuliers').insert(particulierModel.toInsert());
      } catch (e) {
        // Continue même si l'insertion en table échoue
      }

      return particulierModel;

    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Erreur lors de la connexion anonyme: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      
      // Déconnexion globale pour nettoyer toutes les sessions
      await supabaseClient.auth.signOut(scope: SignOutScope.global);
      
    } catch (e) {
      throw ServerException('Erreur lors de la déconnexion: $e');
    }
  }

  @override
  Future<ParticulierModel> getCurrentParticulier() async {
    try {

      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException('Aucun utilisateur connecté');
      }


      // Vérifier si c'est un utilisateur anonyme
      if (user.isAnonymous) {
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

      final dataToUpdate = {
        'first_name': particulier.firstName,
        'last_name': particulier.lastName,
        'phone': particulier.phone,
        'address': particulier.address,
        'city': particulier.city,
        'zip_code': particulier.zipCode,
        'updated_at': DateTime.now().toIso8601String(),
      };


      final response = await supabaseClient
          .from('particuliers')
          .update(dataToUpdate)
          .eq('id', particulier.id)
          .select()
          .single();


      return ParticulierModel.fromJson(response);
    } catch (e) {
      throw ServerException('Erreur lors de la mise à jour du particulier: $e');
    }
  }
}