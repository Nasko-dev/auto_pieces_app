import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service simplifié pour gérer les tokens push dans une table dédiée
class SimplePushService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static SimplePushService? _instance;
  static SimplePushService get instance {
    _instance ??= SimplePushService._();
    return _instance!;
  }

  SimplePushService._();

  /// Sauvegarde ou met à jour le Player ID dans la table push_tokens
  Future<bool> saveOrUpdatePushToken() async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      final userId = _supabase.auth.currentUser?.id;
      final userEmail = _supabase.auth.currentUser?.email;

      debugPrint('\n📱 SAUVEGARDE DU TOKEN PUSH');
      debugPrint('   Player ID: $playerId');
      debugPrint('   User ID: $userId');

      if (playerId == null || playerId.isEmpty) {
        debugPrint('❌ Player ID manquant');
        return false;
      }

      // Déterminer le type d'utilisateur
      String userType = 'unknown';
      if (userId != null) {
        // Vérifier dans particuliers
        final isParticulier = await _supabase
            .from('particuliers')
            .select('id')
            .eq('id', userId)
            .maybeSingle();

        if (isParticulier != null) {
          userType = 'particulier';
        } else {
          // Vérifier dans sellers
          final isSeller = await _supabase
              .from('sellers')
              .select('id')
              .eq('id', userId)
              .maybeSingle();

          if (isSeller != null) {
            userType = 'seller';
          }
        }
      }

      // Utiliser upsert basé sur onesignal_player_id
      await _supabase.from('push_tokens').upsert({
        'onesignal_player_id': playerId,
        'user_id': userId,
        'user_email': userEmail,
        'user_type': userType,
        'platform': 'android',
        'last_active': DateTime.now().toIso8601String(),
      }, onConflict: 'onesignal_player_id');

      debugPrint('✅ Token push sauvegardé avec succès');
      debugPrint('   Type: $userType');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde: $e');
      return false;
    }
  }

  /// Récupère le Player ID pour un utilisateur
  Future<String?> getPlayerIdForUser(String userId) async {
    try {
      final result = await _supabase
          .from('push_tokens')
          .select('onesignal_player_id')
          .eq('user_id', userId)
          .order('last_active', ascending: false)
          .limit(1)
          .maybeSingle();

      return result?['onesignal_player_id'];
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération: $e');
      return null;
    }
  }

  /// Récupère le Player ID le plus récent (peu importe l'utilisateur)
  Future<String?> getCurrentPlayerId() async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId != null) {
        // Sauvegarder/mettre à jour au passage
        await saveOrUpdatePushToken();
      }
      return playerId;
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      return null;
    }
  }

  /// Test d'envoi de notification
  Future<void> testNotification() async {
    debugPrint('\n🚀 TEST DE NOTIFICATION');

    // D'abord sauvegarder le token actuel
    final saved = await saveOrUpdatePushToken();
    if (!saved) {
      debugPrint('❌ Impossible de sauvegarder le token');
      return;
    }

    // Récupérer le Player ID
    final playerId = OneSignal.User.pushSubscription.id;
    debugPrint('✅ Player ID prêt: $playerId');
    debugPrint(
        '   Vous pouvez maintenant envoyer une notification à ce Player ID');

    // TODO: Appeler votre Edge Function pour envoyer la notification
    // Exemple:
    // await _supabase.functions.invoke('send-push-notification', body: {
    //   'player_ids': [playerId],
    //   'title': 'Test de notification',
    //   'message': 'Votre notification fonctionne !',
    // });
  }
}
