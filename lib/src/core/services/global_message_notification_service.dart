import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import '../../shared/presentation/widgets/ios_notification_fixed.dart';

/// Service global pour afficher les notifications de messages partout dans l'app
class GlobalMessageNotificationService {
  static final GlobalMessageNotificationService _instance = GlobalMessageNotificationService._internal();
  factory GlobalMessageNotificationService() => _instance;
  GlobalMessageNotificationService._internal();

  final NotificationService _notificationService = NotificationService();
  final SupabaseClient _supabase = Supabase.instance.client;

  BuildContext? _context;
  String? _activeConversationId;
  bool _isInitialized = false;
  String? _currentSellerId; // ID vendeur si l'utilisateur est vendeur
  String? _currentParticulierId; // ID particulier si l'utilisateur est particulier

  /// Initialiser le service avec le contexte de l'app
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) {
      debugPrint('⚠️  [GlobalNotification] Déjà initialisé');
      return;
    }

    _context = context;
    _isInitialized = true;

    debugPrint('🚀 [GlobalNotification] Initialisation du service global de notifications');

    // Récupérer les IDs vendeur/particulier
    await _fetchUserIds();

    _subscribeToAllMessages();
  }

  /// Récupérer les IDs réels de l'utilisateur (vendeur et/ou particulier)
  Future<void> _fetchUserIds() async {
    final authUserId = _supabase.auth.currentUser?.id;
    if (authUserId == null) return;

    try {
      // Vérifier si c'est un vendeur - l'ID dans sellers EST l'auth user ID
      final sellerResponse = await _supabase
          .from('sellers')
          .select('id')
          .eq('id', authUserId)
          .maybeSingle();

      if (sellerResponse != null) {
        _currentSellerId = sellerResponse['id'] as String;
        debugPrint('✅ [GlobalNotification] ID Vendeur: $_currentSellerId');
      }

      // Vérifier si c'est un particulier - l'ID dans particuliers EST l'auth user ID
      final particulierResponse = await _supabase
          .from('particuliers')
          .select('id')
          .eq('id', authUserId)
          .maybeSingle();

      if (particulierResponse != null) {
        _currentParticulierId = particulierResponse['id'] as String;
        debugPrint('✅ [GlobalNotification] ID Particulier: $_currentParticulierId');
      }
    } catch (e) {
      debugPrint('❌ [GlobalNotification] Erreur récupération IDs: $e');
    }
  }

  /// Définir quelle conversation est actuellement active (pour éviter les doublons)
  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
    debugPrint('📍 [GlobalNotification] Conversation active: ${conversationId ?? "aucune"}');
  }

  /// S'abonner à TOUS les messages de l'utilisateur connecté
  void _subscribeToAllMessages() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('❌ [GlobalNotification] Pas d\'utilisateur connecté');
      return;
    }

    debugPrint('🔔 [GlobalNotification] Abonnement aux messages pour user: $userId');
    debugPrint('   Seller ID: $_currentSellerId');
    debugPrint('   Particulier ID: $_currentParticulierId');

    // Créer un channel global qui écoute TOUS les messages
    final channel = _supabase
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

    channel.subscribe((status, error) {
      if (error != null) {
        debugPrint('❌ [GlobalNotification] Erreur subscription: $error');
      } else {
        debugPrint('✅ [GlobalNotification] Subscription activée - Status: $status');
      }
    });
  }

  /// Gérer un nouveau message reçu
  void _handleNewMessage(Map<String, dynamic> messageData, String currentAuthUserId) {
    try {
      final conversationId = messageData['conversation_id'] as String?;
      final senderId = messageData['sender_id'] as String?;
      final content = messageData['content'] as String?;

      if (conversationId == null || senderId == null || content == null) {
        debugPrint('⏭️  [GlobalNotification] Message incomplet ignoré');
        return;
      }

      // Ne pas afficher si c'est notre propre message
      // Vérifier à la fois contre notre ID vendeur ET notre ID particulier
      if (senderId == _currentSellerId || senderId == _currentParticulierId) {
        debugPrint('⏭️  [GlobalNotification] Notre propre message ignoré (senderId: $senderId)');
        return;
      }

      // Ne pas afficher si on est déjà dans cette conversation
      if (_activeConversationId == conversationId) {
        debugPrint('⏭️  [GlobalNotification] Déjà dans la conversation, notification ignorée');
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
  Future<void> _getSenderInfo(String senderId, String content, String conversationId, String messageSenderId) async {
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
          senderName = '${particulierResponse['first_name']} ${particulierResponse['last_name']}';
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
      subtitle: content.length > 50 ? '${content.substring(0, 50)}...' : content,
      type: NotificationType.info,
      onTap: () => _navigateToConversation(conversationId),
    );
  }

  /// Naviguer vers la conversation appropriée selon le type d'utilisateur
  void _navigateToConversation(String conversationId) {
    if (_context == null || !(_context! as Element).mounted) return;

    debugPrint('🧭 [GlobalNotification] Navigation vers conversation: $conversationId');

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
  void dispose() {
    debugPrint('🧹 [GlobalNotification] Nettoyage du service');
    _isInitialized = false;
    _context = null;
    _activeConversationId = null;
  }
}