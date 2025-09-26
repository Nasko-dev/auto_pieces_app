import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_navigation_service.dart';

/// Service pour gérer l'état de l'application (foreground/background)
class AppStateManager {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // IMPORTANT: Démarrer avec false (background) par défaut pour être sûr
  bool _isInForeground = false;
  bool get isInForeground => _isInForeground;

  void setAppState(bool isInForeground) {
    final previousState = _isInForeground;
    _isInForeground = isInForeground;
    debugPrint('📱 App State changed: $previousState -> ${isInForeground ? 'FOREGROUND' : 'BACKGROUND'}');
  }

  void debugCurrentState() {
    debugPrint('🔍 Current app state: ${_isInForeground ? 'FOREGROUND' : 'BACKGROUND'}');
  }
}

class PushNotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppStateManager _appStateManager = AppStateManager();

  static PushNotificationService? _instance;
  static PushNotificationService get instance {
    _instance ??= PushNotificationService._();
    return _instance!;
  }

  PushNotificationService._();

  Future<void> initialize() async {
    try {
      debugPrint('🔧 Initialisation du PushNotificationService...');

      // Vérifier d'abord les permissions
      final hasPermission = OneSignal.Notifications.permission;
      debugPrint('📱 Statut des permissions: $hasPermission');

      if (!hasPermission) {
        debugPrint('⚠️ Permissions non accordées, demande en cours...');
        await OneSignal.Notifications.requestPermission(true);
      }

      // Configuration des listeners
      _setupNotificationListeners();

      // Attendre que le Player ID soit disponible avec plusieurs tentatives
      await _waitForPlayerIdAndSave();

      debugPrint('✅ PushNotificationService initialisé avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation PushNotificationService: $e');
    }
  }

  Future<void> _waitForPlayerIdAndSave() async {
    const maxAttempts = 5;
    const delayBetweenAttempts = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      debugPrint('🔄 Tentative $attempt/$maxAttempts de récupération du Player ID...');

      final playerId = OneSignal.User.pushSubscription.id;
      final token = OneSignal.User.pushSubscription.token;

      debugPrint('   Player ID: $playerId');
      debugPrint('   Token: ${token != null ? 'Présent (${token.length} caractères)' : 'Absent'}');

      if (playerId != null && playerId.isNotEmpty) {
        await _savePlayerIdToSupabase();
        return;
      }

      if (attempt < maxAttempts) {
        debugPrint('   ⏳ Attente avant la prochaine tentative...');
        await Future.delayed(delayBetweenAttempts);
      }
    }

    debugPrint('⚠️ Impossible de récupérer le Player ID après $maxAttempts tentatives');
  }

  void _setupNotificationListeners() {
    // Listener quand une notification est reçue
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('==== NOTIFICATION RECEIVED ====');
      debugPrint('🔔 Title: ${event.notification.title}');
      debugPrint('🔔 Body: ${event.notification.body}');

      // Debug détaillé de l'état de l'app
      _appStateManager.debugCurrentState();
      final isInForeground = _appStateManager.isInForeground;
      debugPrint('📱 isInForeground value: $isInForeground');

      // Prévenir l'affichage par défaut
      event.preventDefault();

      // LOGIQUE INVERSEÉE : N'afficher QUE si app est en background
      if (isInForeground) {
        debugPrint('❌ FOREGROUND DÉTECTÉ - NOTIFICATION BLOQUÉE');
        // NE PAS AFFICHER - l'utilisateur est sur l'app
      } else {
        debugPrint('✅ BACKGROUND DÉTECTÉ - NOTIFICATION AFFICHÉE');
        event.notification.display();
      }

      debugPrint('==== END NOTIFICATION PROCESSING ====');
    });

    // Listener quand l'utilisateur clique sur une notification
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('Notification cliquée: ${event.notification.title}');
      // TODO: Navigation vers la conversation appropriée
      _handleNotificationClick(event.notification);
    });

    // Listener pour les changements de permission
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint('Permission notification changée: $state');
    });
  }

  Future<void> _savePlayerIdToSupabase() async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      final userId = _supabase.auth.currentUser?.id;
      final userEmail = _supabase.auth.currentUser?.email;
      final optedIn = OneSignal.User.pushSubscription.optedIn;

      debugPrint('🔍 Tentative sauvegarde Player ID...');
      debugPrint('   Player ID: $playerId');
      debugPrint('   User ID: $userId');
      debugPrint('   User Email: $userEmail');
      debugPrint('   Push Opted In: $optedIn');

      if (playerId == null || playerId.isEmpty) {
        debugPrint('❌ Player ID est null ou vide');
        return;
      }

      if (userId == null) {
        debugPrint('❌ User ID est null - utilisateur non connecté');
        return;
      }

      if (optedIn != true) {
        debugPrint('⚠️ L\'utilisateur n\'a pas activé les notifications push');
      }

      // Vérifier d'abord dans la table particuliers
      final existingParticulier = await _supabase
        .from('particuliers')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

      // Vérifier ensuite dans la table sellers
      final existingVendeur = await _supabase
        .from('sellers')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

      if (existingParticulier != null) {
        debugPrint('✅ Utilisateur trouvé dans particuliers, mise à jour du Player ID...');

        // Mettre à jour le Player ID dans particuliers
        await _supabase
          .from('particuliers')
          .update({
            'onesignal_player_id': playerId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

        debugPrint('✅ Player ID mis à jour dans particuliers');

      } else if (existingVendeur != null) {
        debugPrint('✅ Utilisateur trouvé dans sellers, mise à jour du Player ID...');

        try {
          // Mettre à jour le Player ID dans sellers
          await _supabase
            .from('sellers')
            .update({
              'onesignal_player_id': playerId,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);

          debugPrint('✅ Player ID mis à jour dans sellers');
        } catch (e) {
          debugPrint('⚠️ Impossible de mettre à jour dans sellers: $e');
          debugPrint('   La colonne onesignal_player_id n\'existe peut-être pas dans la table sellers');

          // Essayer de stocker dans une table de mapping ou créer la colonne
          debugPrint('   💡 Solution: Demandez à votre admin de base de données d\'ajouter la colonne:');
          debugPrint('      ALTER TABLE sellers ADD COLUMN onesignal_player_id TEXT;');
        }

      } else {
        debugPrint('⚠️ Utilisateur non trouvé dans aucune table (particuliers ou sellers)');
        debugPrint('   Création/mise à jour dans particuliers...');

        try {
          // Utiliser upsert pour créer ou mettre à jour basé sur l'ID
          await _supabase
            .from('particuliers')
            .upsert({
              'id': userId,
              'email': userEmail ?? 'user_$userId@app.local',  // Email par défaut si absent
              'onesignal_player_id': playerId,
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'id');

          debugPrint('✅ Utilisateur créé/mis à jour dans particuliers avec Player ID');
        } catch (e) {
          debugPrint('❌ Erreur lors de l\'upsert: $e');

          // Si l'upsert échoue à cause de l'email, essayer de trouver l'utilisateur et mettre à jour
          try {
            // D'abord chercher si un utilisateur existe avec cet email généré
            final emailToSearch = userEmail ?? 'user_$userId@app.local';
            final existingByEmail = await _supabase
              .from('particuliers')
              .select('id')
              .eq('email', emailToSearch)
              .maybeSingle();

            if (existingByEmail != null) {
              // Mettre à jour par email
              await _supabase
                .from('particuliers')
                .update({
                  'onesignal_player_id': playerId,
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('email', emailToSearch);

              debugPrint('✅ Player ID mis à jour via email: $emailToSearch');
            } else {
              // Essayer de mettre à jour par ID
              await _supabase
                .from('particuliers')
                .update({
                  'onesignal_player_id': playerId,
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('id', userId);

              debugPrint('✅ Player ID mis à jour pour l\'utilisateur existant');
            }
          } catch (updateError) {
            debugPrint('❌ Mise à jour échouée aussi: $updateError');

            // En dernier recours, afficher les infos pour debug
            debugPrint('📊 Info de debug:');
            debugPrint('   User ID actuel: $userId');
            debugPrint('   Email actuel: $userEmail');
            debugPrint('   Player ID: $playerId');
          }
        }
      }

      debugPrint('✅ Player ID OneSignal sauvegardé avec succès');
      debugPrint('   Player ID: $playerId');
      debugPrint('   User ID: $userId');

      // Vérifier que la sauvegarde a bien fonctionné
      final verification = await _supabase
        .from('particuliers')
        .select('onesignal_player_id')
        .eq('id', userId)
        .maybeSingle();

      if (verification != null) {
        debugPrint('🔍 Vérification réussie: ${verification['onesignal_player_id']}');
      } else {
        debugPrint('⚠️ Impossible de vérifier la sauvegarde');
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la sauvegarde du Player ID: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _handleNotificationClick(OSNotification notification) {
    try {
      final additionalData = notification.additionalData;
      if (additionalData != null) {
        debugPrint('Notification cliquée - Data: $additionalData');

        // Utiliser le service de navigation global
        final navigationService = NotificationNavigationService.instance;

        // Navigation asynchrone sans besoin de contexte
        Future.microtask(() async {
          await navigationService.navigateFromNotificationGlobal(additionalData);
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du traitement du clic notification: $e');
    }
  }

  Future<String?> getPlayerId() async {
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du Player ID: $e');
      return null;
    }
  }

  Future<bool> hasPermission() async {
    try {
      return OneSignal.Notifications.permission;
    } catch (e) {
      debugPrint('Erreur lors de la vérification des permissions: $e');
      return false;
    }
  }

  Future<void> requestPermission() async {
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint('Erreur lors de la demande de permission: $e');
    }
  }

  // Méthode pour mettre à jour les tags utilisateur
  Future<void> updateUserTags({
    String? userType, // 'particulier' ou 'vendeur'
    String? userId,
    String? location,
  }) async {
    try {
      final tags = <String, String>{};

      if (userType != null) tags['user_type'] = userType;
      if (userId != null) tags['user_id'] = userId;
      if (location != null) tags['location'] = location;

      if (tags.isNotEmpty) {
        OneSignal.User.addTags(tags);
        debugPrint('Tags utilisateur mis à jour: $tags');
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des tags: $e');
    }
  }

  /// Mettre à jour l'état de l'application
  void setAppState(bool isInForeground) {
    debugPrint('📍 PushNotificationService.setAppState called with: $isInForeground');
    _appStateManager.setAppState(isInForeground);
    _appStateManager.debugCurrentState();
  }

  void dispose() {
    // OneSignal gère automatiquement les listeners
    debugPrint('PushNotificationService disposed');
  }

  // Méthode pour forcer la synchronisation du Player ID
  Future<bool> forceSyncPlayerId() async {
    try {
      debugPrint('🔄 SYNCHRONISATION FORCÉE DU PLAYER ID');

      final playerId = OneSignal.User.pushSubscription.id;
      final userId = _supabase.auth.currentUser?.id;

      if (playerId == null || userId == null) {
        debugPrint('❌ Player ID ou User ID manquant');
        return false;
      }

      debugPrint('   Player ID: $playerId');
      debugPrint('   User ID: $userId');

      // Essayer de sauvegarder dans les deux tables si nécessaire
      bool savedInParticuliers = false;
      bool savedInSellers = false;

      // Essayer dans particuliers
      try {
        final exists = await _supabase
          .from('particuliers')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

        if (exists != null) {
          await _supabase
            .from('particuliers')
            .update({
              'onesignal_player_id': playerId,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);

          savedInParticuliers = true;
          debugPrint('✅ Synchronisé dans particuliers');
        }
      } catch (e) {
        debugPrint('   Pas dans particuliers: $e');
      }

      // Essayer dans sellers
      try {
        final exists = await _supabase
          .from('sellers')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

        if (exists != null) {
          await _supabase
            .from('sellers')
            .update({
              'onesignal_player_id': playerId,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);

          savedInSellers = true;
          debugPrint('✅ Synchronisé dans sellers');
        }
      } catch (e) {
        debugPrint('   Pas dans sellers: $e');
      }

      if (savedInParticuliers || savedInSellers) {
        debugPrint('✅ SYNCHRONISATION RÉUSSIE');
        return true;
      } else {
        debugPrint('⚠️ AUCUNE TABLE TROUVÉE POUR CET UTILISATEUR');
        debugPrint('   Création de l\'utilisateur dans particuliers...');

        // Créer l'utilisateur dans particuliers s'il n'existe nulle part
        try {
          final userEmail = _supabase.auth.currentUser?.email;

          await _supabase
            .from('particuliers')
            .insert({
              'id': userId,
              'email': userEmail ?? 'user_$userId@app.local',
              'onesignal_player_id': playerId,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });

          debugPrint('✅ UTILISATEUR CRÉÉ ET SYNCHRONISÉ');
          return true;
        } catch (e) {
          debugPrint('❌ Impossible de créer l\'utilisateur: $e');

          // En cas d'échec, essayer un upsert
          try {
            await _supabase
              .from('particuliers')
              .upsert({
                'id': userId,
                'onesignal_player_id': playerId,
                'updated_at': DateTime.now().toIso8601String(),
              }, onConflict: 'id');

            debugPrint('✅ UPSERT RÉUSSI');
            return true;
          } catch (upsertError) {
            debugPrint('❌ Upsert échoué aussi: $upsertError');
            return false;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la synchronisation: $e');
      return false;
    }
  }
}