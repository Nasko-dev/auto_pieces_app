import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'device_service.dart';
import '../../shared/presentation/widgets/ios_notification_fixed.dart';

/// Service global pour afficher les notifications de messages partout dans l'app
class GlobalMessageNotificationService {
  static final GlobalMessageNotificationService _instance =
      GlobalMessageNotificationService._internal();
  factory GlobalMessageNotificationService() => _instance;
  GlobalMessageNotificationService._internal();

  final NotificationService _notificationService = NotificationService();
  final SupabaseClient _supabase = Supabase.instance.client;

  BuildContext? _context;
  String? _activeConversationId;
  bool _isInitialized = false;
  String? _currentSellerId; // ID vendeur si l'utilisateur est vendeur
  String?
      _currentParticulierId; // ID particulier si l'utilisateur est particulier
  final Set<String> _myConversationIds =
      {}; // IDs des conversations de l'utilisateur
  RealtimeChannel? _messageChannel; // ✅ FIX: Garder référence pour éviter les duplicatas

  /// Initialiser le service avec le contexte de l'app
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) {
      debugPrint('⚠️  [GlobalNotification] Déjà initialisé');
      return;
    }

    _context = context;
    _isInitialized = true;

    debugPrint(
        '🚀 [GlobalNotification] Initialisation du service global de notifications');

    // Récupérer les IDs vendeur/particulier
    await _fetchUserIds();

    // Charger les IDs de conversations
    await _loadMyConversations();

    await _subscribeToAllMessages();
  }

  /// Récupérer les IDs réels de l'utilisateur (vendeur et/ou particulier)
  Future<void> _fetchUserIds() async {
    final authUserId = _supabase.auth.currentUser?.id;
    if (authUserId == null) return;

    try {
      // Vérifier si c'est un vendeur
      final sellerResponse = await _supabase
          .from('sellers')
          .select('id')
          .eq('id', authUserId)
          .maybeSingle();

      if (sellerResponse != null) {
        _currentSellerId = sellerResponse['id'] as String;
        debugPrint('✅ [GlobalNotification] ID Vendeur: $_currentSellerId');
        return; // Si vendeur, pas besoin de chercher particulier
      }

      // Pour les particuliers, utiliser device_id (auth anonyme)
      try {
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        final deviceId = await deviceService.getDeviceId();

        final particulierResponse = await _supabase
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (particulierResponse != null) {
          _currentParticulierId = particulierResponse['id'] as String;
          debugPrint(
              '✅ [GlobalNotification] ID Particulier (via device_id): $_currentParticulierId');
        } else {
          debugPrint(
              '⚠️  [GlobalNotification] Aucun particulier trouvé pour device_id: $deviceId');
        }
      } catch (e) {
        debugPrint('❌ [GlobalNotification] Erreur device_id: $e');
      }
    } catch (e) {
      debugPrint('❌ [GlobalNotification] Erreur récupération IDs: $e');
    }
  }

  /// Charger les IDs de conversations de l'utilisateur
  Future<void> _loadMyConversations() async {
    final authUserId = _supabase.auth.currentUser?.id;
    if (authUserId == null) return;

    try {
      _myConversationIds.clear();

      // Pour vendeurs
      if (_currentSellerId != null) {
        final sellerConvs = await _supabase
            .from('conversations')
            .select('id')
            .or('seller_id.eq.$_currentSellerId,user_id.eq.$_currentSellerId');

        for (final conv in sellerConvs) {
          _myConversationIds.add(conv['id'] as String);
        }
      }

      // Pour particuliers - utiliser device_id pour auth anonyme
      if (_currentParticulierId != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final deviceService = DeviceService(prefs);
          final deviceId = await deviceService.getDeviceId();

          // Récupérer tous les user_ids liés à ce device
          final allParticuliersWithDevice = await _supabase
              .from('particuliers')
              .select('id')
              .eq('device_id', deviceId);

          final allUserIds =
              allParticuliersWithDevice.map((p) => p['id'] as String).toList();

          // Ajouter l'utilisateur actuel s'il n'est pas dans la liste
          if (!allUserIds.contains(_currentParticulierId)) {
            allUserIds.add(_currentParticulierId!);
          }

          // Récupérer les conversations pour tous ces user_ids
          if (allUserIds.isNotEmpty) {
            final particConvs = await _supabase
                .from('conversations')
                .select('id')
                .inFilter('user_id', allUserIds);

            for (final conv in particConvs) {
              _myConversationIds.add(conv['id'] as String);
            }
          }
        } catch (e) {
          debugPrint(
              '⚠️  [GlobalNotification] Erreur device_id, fallback user_id: $e');
          // Fallback: récupérer seulement avec user_id
          final particConvs = await _supabase
              .from('conversations')
              .select('id')
              .eq('user_id', _currentParticulierId!);

          for (final conv in particConvs) {
            _myConversationIds.add(conv['id'] as String);
          }
        }
      }

      debugPrint(
          '✅ [GlobalNotification] ${_myConversationIds.length} conversations chargées');
    } catch (e) {
      debugPrint('❌ [GlobalNotification] Erreur chargement conversations: $e');
    }
  }

  /// Définir quelle conversation est actuellement active (pour éviter les doublons)
  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
    debugPrint(
        '📍 [GlobalNotification] Conversation active: ${conversationId ?? "aucune"}');

    // Ajouter cette conversation à notre liste si elle n'y est pas déjà
    if (conversationId != null &&
        !_myConversationIds.contains(conversationId)) {
      _myConversationIds.add(conversationId);
      debugPrint(
          '➕ [GlobalNotification] Nouvelle conversation ajoutée: $conversationId');
    }
  }

  /// S'abonner à TOUS les messages de l'utilisateur connecté
  Future<void> _subscribeToAllMessages() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('❌ [GlobalNotification] Pas d\'utilisateur connecté');
      return;
    }

    // ✅ FIX: Nettoyer l'ancien channel s'il existe pour éviter les duplicatas
    if (_messageChannel != null) {
      debugPrint('🧹 [GlobalNotification] Nettoyage de l\'ancien channel...');
      await _supabase.removeChannel(_messageChannel!);
      _messageChannel = null;
    }

    debugPrint(
        '🔔 [GlobalNotification] Abonnement aux messages pour user: $userId');
    debugPrint('   Seller ID: $_currentSellerId');
    debugPrint('   Particulier ID: $_currentParticulierId');

    // Créer un channel global qui écoute TOUS les messages
    _messageChannel = _supabase
        .channel('global_notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            debugPrint('📨 [GlobalNotification] MESSAGE REÇU VIA REALTIME!');
            debugPrint('   Payload: ${payload.newRecord}');
            _handleNewMessage(payload.newRecord, userId);
          },
        );

    _messageChannel!.subscribe((status, error) {
      if (error != null) {
        debugPrint('❌ [GlobalNotification] Erreur subscription: $error');
      } else {
        debugPrint(
            '✅ [GlobalNotification] Subscription activée - Status: $status');
      }
    });
  }

  /// Gérer un nouveau message reçu
  void _handleNewMessage(
      Map<String, dynamic> messageData, String currentAuthUserId) {
    try {
      final conversationId = messageData['conversation_id'] as String?;
      final senderId = messageData['sender_id'] as String?;
      final content = messageData['content'] as String?;

      if (conversationId == null || senderId == null || content == null) {
        debugPrint('⏭️  [GlobalNotification] Message incomplet ignoré');
        return;
      }

      // Vérifier si cette conversation nous appartient
      if (!_myConversationIds.contains(conversationId)) {
        debugPrint(
            '⏭️  [GlobalNotification] Conversation non pertinente ignorée (ID: $conversationId)');
        return;
      }

      // Ne pas afficher si c'est notre propre message
      // Vérifier à la fois contre notre ID vendeur ET notre ID particulier
      if (senderId == _currentSellerId || senderId == _currentParticulierId) {
        debugPrint(
            '⏭️  [GlobalNotification] Notre propre message ignoré (senderId: $senderId)');
        return;
      }

      // Ne pas afficher si on est déjà dans cette conversation
      if (_activeConversationId == conversationId) {
        debugPrint(
            '⏭️  [GlobalNotification] Déjà dans la conversation, notification ignorée');
        return;
      }

      debugPrint('✅ [GlobalNotification] Nouveau message détecté:');
      debugPrint('   Conversation: $conversationId');
      debugPrint('   Sender: $senderId');
      debugPrint('   Notre Seller ID: $_currentSellerId');
      debugPrint('   Notre Particulier ID: $_currentParticulierId');

      // Récupérer les infos de l'expéditeur
      _getSenderInfo(senderId, content, conversationId, senderId);
    } catch (e) {
      debugPrint('❌ [GlobalNotification] Erreur: $e');
    }
  }

  /// Récupérer les informations de l'expéditeur et afficher la notification
  Future<void> _getSenderInfo(String senderId, String content,
      String conversationId, String messageSenderId) async {
    try {
      // Essayer de récupérer depuis sellers
      final sellerResponse = await _supabase
          .from('sellers')
          .select('company_name, first_name, last_name')
          .eq('id', senderId)
          .maybeSingle();

      String senderName = 'Nouveau message';

      if (sellerResponse != null) {
        // C'est un vendeur
        senderName = sellerResponse['company_name'] as String? ??
            '${sellerResponse['first_name']} ${sellerResponse['last_name']}';
      } else {
        // Essayer depuis particuliers
        final particulierResponse = await _supabase
            .from('particuliers')
            .select('first_name, last_name')
            .eq('id', senderId)
            .maybeSingle();

        if (particulierResponse != null) {
          senderName =
              '${particulierResponse['first_name']} ${particulierResponse['last_name']}';
        }
      }

      _showNotification(senderName, content, conversationId);
    } catch (e) {
      debugPrint('❌ [GlobalNotification] Erreur récupération expéditeur: $e');
      _showNotification('Nouveau message', content, conversationId);
    }
  }

  /// Afficher la notification avec navigation
  void _showNotification(String title, String content, String conversationId) {
    if (_context == null || !(_context! as Element).mounted) {
      debugPrint('❌ [GlobalNotification] Pas de contexte valide');
      return;
    }

    debugPrint('🎉 [GlobalNotification] AFFICHAGE NOTIFICATION: $title');

    _notificationService.show(
      context: _context!,
      message: title,
      subtitle:
          content.length > 50 ? '${content.substring(0, 50)}...' : content,
      type: NotificationType.info,
      onTap: () => _navigateToConversation(conversationId),
    );
  }

  /// Naviguer vers la conversation appropriée selon le type d'utilisateur
  void _navigateToConversation(String conversationId) {
    if (_context == null || !(_context! as Element).mounted) return;

    debugPrint(
        '🧭 [GlobalNotification] Navigation vers conversation: $conversationId');

    // Déterminer la route selon si on est vendeur ou particulier
    if (_currentSellerId != null) {
      // Route vendeur
      _context!.go('/seller/conversation/$conversationId');
    } else if (_currentParticulierId != null) {
      // Route particulier
      _context!.go('/conversations/$conversationId');
    }
  }

  /// Nettoyer les ressources
  Future<void> dispose() async {
    debugPrint('🧹 [GlobalNotification] Nettoyage du service');

    // ✅ FIX: Nettoyer le channel realtime
    if (_messageChannel != null) {
      debugPrint('🧹 [GlobalNotification] Suppression du channel realtime...');
      await _supabase.removeChannel(_messageChannel!);
      _messageChannel = null;
    }

    _isInitialized = false;
    _context = null;
    _activeConversationId = null;
    _myConversationIds.clear();
  }
}
