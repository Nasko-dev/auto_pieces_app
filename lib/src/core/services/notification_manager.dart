import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'send_notification_service.dart';
import 'device_service.dart';

/// Service principal pour gérer TOUTES les notifications
class NotificationManager {
  final SupabaseClient _supabase = Supabase.instance.client;

  static NotificationManager? _instance;
  static NotificationManager get instance {
    _instance ??= NotificationManager._();
    return _instance!;
  }

  NotificationManager._();

  /// Initialisation complète
  Future<void> initialize() async {
    debugPrint('\n🚀 INITIALISATION NOTIFICATION MANAGER');

    try {
      // 1. Vérifier et demander les permissions de manière plus insistante
      final hasPermission = OneSignal.Notifications.permission;
      debugPrint('📱 Permissions initiales: $hasPermission');

      if (!hasPermission) {
        debugPrint('⚠️ Demande de permissions notifications...');
        await OneSignal.Notifications.requestPermission(true);

        // Vérifier à nouveau après la demande
        final newPermission = OneSignal.Notifications.permission;
        debugPrint('📱 Nouvelles permissions: $newPermission');

        if (!newPermission) {
          debugPrint('❌ ATTENTION: Notifications désactivées !');
          debugPrint('💡 L\'utilisateur doit activer les notifications manuellement dans les paramètres Android');
        }
      } else {
        debugPrint('✅ Permissions notifications accordées');
      }

      // 2. Créer les channels de notification Android
      await _createNotificationChannels();

      // 3. Configurer les listeners
      _setupListeners();

      // 3. Sauvegarder le Player ID
      await Future.delayed(const Duration(seconds: 2)); // Attendre que le Player ID soit prêt
      await savePlayerIdToDatabase();

      debugPrint('✅ NotificationManager initialisé\n');
    } catch (e) {
      debugPrint('❌ Erreur initialisation: $e\n');
    }
  }

  /// Créer les channels de notification Android
  Future<void> _createNotificationChannels() async {
    try {
      debugPrint('📱 Création des channels de notification...');

      // OneSignal crée automatiquement les channels depuis les paramètres du dashboard
      // On n'a pas besoin de les créer manuellement avec la version 5.x
      debugPrint('✅ Channels gérés automatiquement par OneSignal');
    } catch (e) {
      debugPrint('⚠️ Erreur channels: $e');
    }
  }

  void _setupListeners() {
    // Notification reçue en foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('📬 Notification reçue: ${event.notification.title}');
      event.preventDefault();
      event.notification.display();
    });

    // Notification cliquée
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('👆 Notification cliquée: ${event.notification.title}');
      // TODO: Navigation
    });
  }

  /// Sauvegarde simple du Player ID
  Future<bool> savePlayerIdToDatabase() async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      final userId = _supabase.auth.currentUser?.id;
      final userEmail = _supabase.auth.currentUser?.email;

      debugPrint('💾 SAUVEGARDE PLAYER ID DÉTAILLÉE');
      debugPrint('   📱 Player ID OneSignal: $playerId');
      debugPrint('   👤 User ID Supabase: $userId');
      debugPrint('   📧 Email Supabase: $userEmail');
      debugPrint('   🔐 Auth State: ${_supabase.auth.currentUser != null ? "Connecté" : "Déconnecté"}');

      if (playerId == null) {
        debugPrint('   ⚠️ Player ID pas encore disponible');
        return false;
      }

      // Sauvegarder dans push_tokens (table universelle)
      debugPrint('   💾 Tentative de sauvegarde dans push_tokens...');

      // Récupérer le device_id si c'est un particulier anonyme
      String? deviceId;
      try {
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        deviceId = await deviceService.getDeviceId();
        debugPrint('   📱 Device ID: $deviceId');
      } catch (e) {
        debugPrint('   ⚠️ Erreur récupération device_id: $e');
      }

      final insertData = {
        'onesignal_player_id': playerId,
        'user_id': userId,
        'device_id': deviceId, // Ajouter device_id
        'platform': 'android',
        'last_active': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      debugPrint('   📦 Données à insérer: $insertData');

      final result = await _supabase.from('push_tokens').upsert(insertData, onConflict: 'onesignal_player_id');

      debugPrint('   ✅ Sauvegardé dans push_tokens - Résultat: OK');

      // Si on a un userId, essayer aussi de mettre à jour particuliers/sellers
      if (userId != null) {
        await _updateUserTables(userId, playerId);
      }

      return true;
    } catch (e) {
      debugPrint('   ❌ Erreur sauvegarde: $e');
      return false;
    }
  }

  /// Mise à jour optionnelle des tables utilisateurs
  Future<void> _updateUserTables(String userId, String playerId) async {
    // Essayer particuliers
    try {
      await _supabase
        .from('particuliers')
        .update({'onesignal_player_id': playerId})
        .eq('id', userId);
      debugPrint('   ✅ Mis à jour dans particuliers');
      return;
    } catch (e) {
      // Pas grave si ça échoue
    }

    // Essayer sellers
    try {
      await _supabase
        .from('sellers')
        .update({'onesignal_player_id': playerId})
        .eq('id', userId);
      debugPrint('   ✅ Mis à jour dans sellers');
    } catch (e) {
      // Pas grave si ça échoue
    }
  }

  /// Récupère le Player ID actuel
  Future<String?> getCurrentPlayerId() async {
    final playerId = OneSignal.User.pushSubscription.id;

    if (playerId != null) {
      // Sauvegarder au passage
      await savePlayerIdToDatabase();
    }

    return playerId;
  }

  /// Forcer la synchronisation du Player ID (utile quand l'utilisateur se connecte)
  Future<void> forceSyncPlayerId() async {
    debugPrint('🔄 SYNCHRONISATION FORCÉE DU PLAYER ID');

    final playerId = OneSignal.User.pushSubscription.id;
    final userId = _supabase.auth.currentUser?.id;

    debugPrint('   Player ID: $playerId');
    debugPrint('   User ID: $userId');

    if (playerId != null && userId != null) {
      await savePlayerIdToDatabase();

      // Vérifier que ça a bien été sauvegardé
      final result = await _supabase
        .from('push_tokens')
        .select('onesignal_player_id')
        .eq('user_id', userId)
        .maybeSingle();

      if (result != null) {
        debugPrint('   ✅ Player ID synchronisé avec succès');
      } else {
        debugPrint('   ❌ Échec de la synchronisation');
      }
    } else {
      debugPrint('   ⚠️ Player ID ou User ID manquant');
    }
  }

  /// Afficher tous les Player IDs dans la base de données
  Future<void> debugDatabase() async {
    debugPrint('\n🔍 DEBUG BASE DE DONNÉES');
    debugPrint('══════════════════════════════════════');

    try {
      // Récupérer tous les tokens
      final result = await _supabase
        .from('push_tokens')
        .select('user_id, onesignal_player_id, platform, last_active')
        .order('last_active', ascending: false);

      debugPrint('📊 Nombre de tokens: ${result.length}');

      for (final token in result) {
        debugPrint('🪙 Token:');
        debugPrint('   User ID: ${token['user_id']}');
        debugPrint('   Player ID: ${token['onesignal_player_id']}');
        debugPrint('   Plateforme: ${token['platform']}');
        debugPrint('   Dernière activité: ${token['last_active']}');
        debugPrint('   ────────────────────────');
      }

      // Vérifier le User ID spécifique qui pose problème
      final targetUserId = 'dfcc814d-85ba-46df-ab2f-bb4a2c00c95e';
      final targetResult = await _supabase
        .from('push_tokens')
        .select('onesignal_player_id')
        .eq('user_id', targetUserId)
        .maybeSingle();

      debugPrint('🎯 RECHERCHE SPÉCIFIQUE:');
      debugPrint('   Target User ID: $targetUserId');
      debugPrint('   Player ID trouvé: ${targetResult?['onesignal_player_id'] ?? 'AUCUN'}');

    } catch (e) {
      debugPrint('❌ Erreur debug DB: $e');
    }

    debugPrint('══════════════════════════════════════\n');
  }

  /// Test direct en vérifiant manuellement la base de données
  Future<void> testBetweenRegisteredUsers() async {
    debugPrint('\n🧪 TEST COMPLET AVEC VÉRIFICATION DB');
    debugPrint('══════════════════════════════════════════════════════════');

    try {
      // Les 2 utilisateurs enregistrés selon les logs
      final userId2 = '82392786-b854-40b4-90c1-605636804164';

      debugPrint('🎯 Test pour User ID: $userId2');

      // 1. Vérifier qu'il est bien dans la base
      final result = await _supabase
        .from('push_tokens')
        .select('onesignal_player_id')
        .eq('user_id', userId2)
        .maybeSingle();

      debugPrint('📊 DB result: $result');

      if (result == null) {
        debugPrint('❌ User pas trouvé dans push_tokens !');
        return;
      }

      final playerId = result['onesignal_player_id'];
      debugPrint('✅ Player ID trouvé: $playerId');

      // 2. Test d'envoi avec OneSignal direct (pas via Edge Function)
      debugPrint('\n📤 Test OneSignal direct...');

      // Essayons d'appeler l'Edge Function directement avec des logs
      debugPrint('📞 Appel Edge Function...');
      final response = await _supabase.functions.invoke('send-push-notification', body: {
        'user_ids': [userId2],
        'title': 'Test Direct',
        'message': 'Test depuis Dart directement',
        'type': 'test'
      });

      debugPrint('📋 Response status: ${response.status}');
      debugPrint('📋 Response data: ${response.data}');

    } catch (e) {
      debugPrint('❌ Erreur test complet: $e');
    }

    debugPrint('══════════════════════════════════════════════════════════\n');
  }

  /// Test simple pour vérifier que tout fonctionne
  Future<void> runTest() async {
    debugPrint('\n🧪 TEST DES NOTIFICATIONS');
    debugPrint('════════════════════════════════');

    // 1. Player ID actuel
    final playerId = OneSignal.User.pushSubscription.id;
    debugPrint('Player ID OneSignal: $playerId');

    // 2. Permissions
    final hasPermission = OneSignal.Notifications.permission;
    debugPrint('Permissions: $hasPermission');

    // 3. Sauvegarder
    if (playerId != null) {
      final saved = await savePlayerIdToDatabase();
      debugPrint('Sauvegarde: ${saved ? "✅" : "❌"}');
    }

    // 4. Vérifier dans la DB
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        final result = await _supabase
          .from('push_tokens')
          .select('onesignal_player_id')
          .eq('user_id', userId)
          .maybeSingle();

        debugPrint('Dans push_tokens: ${result?['onesignal_player_id']}');
      } catch (e) {
        debugPrint('Erreur lecture DB: $e');
      }
    }

    debugPrint('════════════════════════════════\n');
  }

  /// Vérifie et demande les permissions de notifications
  Future<bool> checkAndRequestPermissions() async {
    try {
      debugPrint('🔍 Vérification des permissions notifications...');

      final hasPermission = OneSignal.Notifications.permission;
      debugPrint('   État actuel: $hasPermission');

      if (!hasPermission) {
        debugPrint('   Demande de permissions...');
        await OneSignal.Notifications.requestPermission(true);

        // Attendre un peu et vérifier à nouveau
        await Future.delayed(const Duration(milliseconds: 500));
        final newPermission = OneSignal.Notifications.permission;
        debugPrint('   Nouveau statut: $newPermission');

        return newPermission;
      }

      return hasPermission;
    } catch (e) {
      debugPrint('❌ Erreur vérification permissions: $e');
      return false;
    }
  }
}