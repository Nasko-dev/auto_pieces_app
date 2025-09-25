import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour envoyer des notifications push via Edge Function
class SendNotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static SendNotificationService? _instance;
  static SendNotificationService get instance {
    _instance ??= SendNotificationService._();
    return _instance!;
  }

  SendNotificationService._();

  /// Envoie une notification à des utilisateurs spécifiques
  Future<bool> sendToUsers({
    required List<String> userIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
    String type = 'message',
  }) async {
    try {
      debugPrint('📤 Envoi de notification...');
      debugPrint('   Destinataires: ${userIds.length} utilisateur(s)');
      debugPrint('   Titre: $title');

      final response = await _supabase.functions.invoke(
        'send-push-notification',
        body: {
          'user_ids': userIds,
          'title': title,
          'message': message,
          'data': data,
          'type': type,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        debugPrint('✅ Notification envoyée avec succès');
        debugPrint('   ID: ${response.data['notification_id']}');
        debugPrint('   Destinataires: ${response.data['recipients']}');
        return true;
      }

      debugPrint('❌ Échec de l\'envoi: ${response.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'envoi: $e');
      return false;
    }
  }

  /// Envoie une notification de nouveau message
  Future<bool> sendMessageNotification({
    required String toUserId,
    required String fromUserName,
    required String messagePreview,
    String? conversationId,
  }) async {
    return sendToUsers(
      userIds: [toUserId],
      title: fromUserName,
      message: messagePreview,
      data: {
        'conversation_id': conversationId,
        'action': 'open_conversation',
      },
      type: 'message',
    );
  }

  /// Envoie une notification de message à un particulier anonyme via device_id
  Future<bool> sendMessageNotificationByDeviceId({
    required String deviceId,
    required String fromUserName,
    required String messagePreview,
    String? conversationId,
  }) async {
    try {
      debugPrint('📤 Envoi notification par device_id...');
      debugPrint('   Device ID: $deviceId');
      debugPrint('   From: $fromUserName');

      final response = await _supabase.functions.invoke(
        'send-push-notification',
        body: {
          'device_ids': [deviceId],  // Nouveau paramètre pour device_id
          'title': fromUserName,
          'message': messagePreview,
          'data': {
            'conversation_id': conversationId,
            'action': 'open_conversation',
          },
          'type': 'message',
        },
      );

      if (response.data != null && response.data['success'] == true) {
        debugPrint('✅ Notification envoyée avec succès par device_id');
        return true;
      }

      debugPrint('❌ Échec envoi par device_id: ${response.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Erreur envoi par device_id: $e');
      return false;
    }
  }

  /// Envoie une notification de demande de pièce
  Future<bool> sendPartRequestNotification({
    required String sellerId,
    required String buyerName,
    required String partName,
    String? requestId,
  }) async {
    return sendToUsers(
      userIds: [sellerId],
      title: 'Nouvelle demande de pièce',
      message: '$buyerName recherche: $partName',
      data: {
        'request_id': requestId,
        'action': 'open_request',
      },
      type: 'part_request',
    );
  }

  /// Envoie une notification de réponse à une demande
  Future<bool> sendPartResponseNotification({
    required String buyerId,
    required String sellerName,
    required String partName,
    String? responseId,
  }) async {
    return sendToUsers(
      userIds: [buyerId],
      title: 'Réponse à votre demande',
      message: '$sellerName a une proposition pour: $partName',
      data: {
        'response_id': responseId,
        'action': 'open_response',
      },
      type: 'part_response',
    );
  }

  /// Test d'envoi de notification
  Future<bool> sendTestNotification() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      debugPrint('❌ Utilisateur non connecté');
      return false;
    }

    return sendToUsers(
      userIds: [userId],
      title: '🎉 Test réussi !',
      message: 'Les notifications push fonctionnent correctement',
      data: {
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}