import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/in_app_notification_service.dart';

/// Provider pour gérer les notifications in-app de messages
class InAppMessageNotifier extends StateNotifier<void> {
  final SupabaseClient _supabase;
  String? _currentConversationId;
  BuildContext? _context;

  InAppMessageNotifier(this._supabase) : super(null) {
    _setupRealtimeListener();
  }

  /// Définir le contexte pour afficher les notifications
  void setContext(BuildContext? context) {
    _context = context;
  }

  /// Définir la conversation actuellement ouverte (pour ne pas afficher de notif)
  void setCurrentConversation(String? conversationId) {
    _currentConversationId = conversationId;
  }

  /// Écouter les nouveaux messages en temps réel
  void _setupRealtimeListener() {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    _supabase
        .channel('in_app_notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            _handleNewMessage(payload.newRecord, currentUserId);
          },
        )
        .subscribe();
  }

  /// Gérer un nouveau message
  void _handleNewMessage(Map<String, dynamic> messageData, String currentUserId) {
    try {
      final conversationId = messageData['conversation_id'] as String?;
      final senderId = messageData['sender_id'] as String?;
      final content = messageData['content'] as String?;
      final messageType = messageData['message_type'] as String?;

      // Ne pas afficher de notification si :
      // 1. C'est notre propre message
      if (senderId == currentUserId) return;

      // 2. On est déjà dans cette conversation
      if (conversationId == _currentConversationId) return;

      // 3. Pas de contexte disponible
      if (_context == null || !_context!.mounted) return;

      // Récupérer les infos de l'expéditeur
      _fetchSenderInfoAndShowNotification(
        conversationId: conversationId ?? '',
        senderId: senderId ?? '',
        content: content ?? '',
        messageType: messageType ?? 'text',
      );
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Récupérer les infos de l'expéditeur et afficher la notification
  Future<void> _fetchSenderInfoAndShowNotification({
    required String conversationId,
    required String senderId,
    required String content,
    required String messageType,
  }) async {
    try {
      // Récupérer les infos de la conversation pour avoir le nom de l'expéditeur
      final conversationData = await _supabase
          .from('conversations')
          .select('seller_id, seller_name, seller_company, user_display_name')
          .eq('id', conversationId)
          .maybeSingle();

      if (conversationData == null) return;

      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      // Déterminer le nom de l'expéditeur selon qui a envoyé
      String senderName;
      String? avatarUrl;

      if (senderId == conversationData['seller_id']) {
        // Message du vendeur
        senderName = conversationData['seller_company'] ??
                     conversationData['seller_name'] ??
                     'Vendeur';
      } else {
        // Message du particulier
        senderName = conversationData['user_display_name'] ?? 'Client';
      }

      // Formater le contenu selon le type
      String messagePreview;
      if (messageType == 'image') {
        messagePreview = '📷 Image';
      } else if (messageType == 'offer') {
        messagePreview = '💰 Nouvelle offre';
      } else {
        messagePreview = content.length > 50
            ? '${content.substring(0, 50)}...'
            : content;
      }

      // Afficher la notification
      if (_context != null && _context!.mounted) {
        InAppNotificationService.showMessageNotification(
          _context!,
          senderName: senderName,
          messagePreview: messagePreview,
          avatarUrl: avatarUrl,
          onTap: () {
            // Naviguer vers la conversation
            _navigateToConversation(conversationId);
          },
        );
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Naviguer vers une conversation
  void _navigateToConversation(String conversationId) {
    if (_context == null || !_context!.mounted) return;

    // Utiliser GoRouter pour naviguer
    // La navigation sera implémentée selon votre routing
    // Pour l'instant, on log juste
  }
}

/// Provider pour le notifier
final inAppMessageNotifierProvider = StateNotifierProvider<InAppMessageNotifier, void>((ref) {
  final supabase = Supabase.instance.client;
  return InAppMessageNotifier(supabase);
});