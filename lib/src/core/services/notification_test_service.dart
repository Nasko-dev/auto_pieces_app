import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationTestService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> runDiagnostics(BuildContext context) async {
    debugPrint('\n════════════════════════════════════════════════════════');
    debugPrint('📱 DIAGNOSTIC DES NOTIFICATIONS PUSH');
    debugPrint('════════════════════════════════════════════════════════\n');

    // 1. Vérifier OneSignal App ID
    debugPrint('1️⃣ CONFIGURATION ONESIGNAL');
    debugPrint('   App ID configuré: dd1bf04c-a036-4654-9c19-92e7b20bae08');

    // 2. Vérifier les permissions
    debugPrint('\n2️⃣ PERMISSIONS');
    final hasPermission = OneSignal.Notifications.permission;
    debugPrint('   Statut des permissions: $hasPermission');

    if (!hasPermission) {
      debugPrint('   ⚠️ Demande de permission en cours...');
      await OneSignal.Notifications.requestPermission(true);
      final newPermission = OneSignal.Notifications.permission;
      debugPrint('   Nouveau statut: $newPermission');
    }

    // 3. Vérifier le Player ID
    debugPrint('\n3️⃣ PLAYER ID & SUBSCRIPTION');
    final playerId = OneSignal.User.pushSubscription.id;
    final token = OneSignal.User.pushSubscription.token;
    final optedIn = OneSignal.User.pushSubscription.optedIn;

    debugPrint('   Player ID: ${playerId ?? "NON DISPONIBLE"}');
    debugPrint(
        '   Token: ${token != null ? 'Présent (${token.length} caractères)' : 'ABSENT'}');
    debugPrint('   Opted In: $optedIn');

    // 4. Vérifier l'utilisateur connecté
    debugPrint('\n4️⃣ UTILISATEUR SUPABASE');
    final user = _supabase.auth.currentUser;
    debugPrint('   User ID: ${user?.id ?? "NON CONNECTÉ"}');
    debugPrint('   Email: ${user?.email ?? "N/A"}');

    // 5. Vérifier la sauvegarde dans Supabase
    if (user != null) {
      try {
        final result = await _supabase
            .from('particuliers')
            .select('onesignal_player_id')
            .eq('id', user.id)
            .maybeSingle();

        debugPrint('\n5️⃣ SAUVEGARDE SUPABASE');
        debugPrint(
            '   Player ID dans DB: ${result?['onesignal_player_id'] ?? "NON SAUVEGARDÉ"}');

        if (playerId != null && result?['onesignal_player_id'] != playerId) {
          debugPrint('   ⚠️ Player ID différent dans la DB, mise à jour...');
          await _supabase.from('particuliers').update({
            'onesignal_player_id': playerId,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', user.id);
          debugPrint('   ✅ Mis à jour avec succès');
        }
      } catch (e) {
        debugPrint('   ❌ Erreur lors de la vérification Supabase: $e');
      }
    }

    // 6. Tester l'envoi d'une notification locale
    debugPrint('\n6️⃣ TEST DE NOTIFICATION LOCALE');
    if (playerId != null) {
      try {
        debugPrint('   Envoi d\'une notification de test...');

        // Créer une notification locale pour tester
        await OneSignal.InAppMessages.addTrigger("test_notification", "true");

        debugPrint('   ✅ Notification de test déclenchée');
        debugPrint(
            '   ℹ️  Vous devriez recevoir une notification dans quelques secondes');
      } catch (e) {
        debugPrint('   ❌ Erreur lors de l\'envoi: $e');
      }
    } else {
      debugPrint('   ❌ Impossible d\'envoyer sans Player ID');
    }

    // 7. Vérifier les tags
    debugPrint('\n7️⃣ TAGS UTILISATEUR');
    try {
      final tags = OneSignal.User.getTags();
      debugPrint('   Tags configurés: $tags');
    } catch (e) {
      debugPrint('   ❌ Erreur lors de la récupération des tags: $e');
    }

    debugPrint('\n════════════════════════════════════════════════════════');
    debugPrint('📊 FIN DU DIAGNOSTIC');
    debugPrint('════════════════════════════════════════════════════════\n');

    // Afficher un résumé dans une SnackBar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            playerId != null
                ? 'Notifications configurées ✅\nPlayer ID: ${playerId.substring(0, 8)}...'
                : 'Notifications non configurées ❌',
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: playerId != null ? Colors.green : Colors.red,
        ),
      );
    }
  }

  static Future<void> sendTestNotificationFromSupabase() async {
    debugPrint('\n🚀 ENVOI DE NOTIFICATION TEST VIA SUPABASE');

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Utilisateur non connecté');
        return;
      }

      // Récupérer le Player ID depuis particuliers OU sellers
      debugPrint('Recherche du Player ID pour l\'utilisateur: $userId');

      // Essayer d'abord dans particuliers
      final resultParticulier = await _supabase
          .from('particuliers')
          .select('onesignal_player_id')
          .eq('id', userId)
          .maybeSingle();

      String? playerIdInDb = resultParticulier?['onesignal_player_id'];

      if (playerIdInDb == null) {
        debugPrint('Pas trouvé dans particuliers, recherche dans sellers...');

        // Essayer dans sellers
        final resultSeller = await _supabase
            .from('sellers')
            .select('onesignal_player_id')
            .eq('id', userId)
            .maybeSingle();

        playerIdInDb = resultSeller?['onesignal_player_id'];
      }

      debugPrint('Player ID trouvé dans la DB: $playerIdInDb');

      if (playerIdInDb == null) {
        debugPrint('❌ Aucun Player ID trouvé dans Supabase');
        debugPrint(
            '   💡 Conseil: Vérifiez que le Player ID a été sauvegardé lors de l\'initialisation');

        // Afficher aussi le Player ID actuel pour comparaison
        final currentPlayerId = OneSignal.User.pushSubscription.id;
        debugPrint('   Player ID actuel OneSignal: $currentPlayerId');

        if (currentPlayerId != null) {
          debugPrint('   ⚠️ Le Player ID existe mais n\'est pas dans la DB!');
        }
        return;
      }

      debugPrint('✅ Player ID trouvé: $playerIdInDb');
      debugPrint('   Prêt pour l\'envoi via Edge Function ou API OneSignal');

      // TODO: Appeler votre fonction Edge pour envoyer la notification
      // Exemple:
      // await _supabase.functions.invoke('send-notification', body: {
      //   'player_id': playerIdInDb,
      //   'title': 'Test de notification',
      //   'message': 'Ceci est un test',
      // });
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }
}
