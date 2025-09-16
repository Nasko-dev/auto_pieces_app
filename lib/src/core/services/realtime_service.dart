import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/parts/domain/entities/message.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _conversationsChannel;

  // Streams pour les messages et conversations
  final Map<String, StreamController<Message>> _messageStreamControllers = {};
  final StreamController<Map<String, dynamic>> _conversationStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Message> get messageStream => throw UnimplementedError('Utiliser getMessageStreamForConversation');
  Stream<Map<String, dynamic>> get conversationStream => _conversationStreamController.stream;
  
  // Obtenir le stream pour une conversation spécifique
  Stream<Message> getMessageStreamForConversation(String conversationId) {
    if (!_messageStreamControllers.containsKey(conversationId)) {
      _messageStreamControllers[conversationId] = StreamController<Message>.broadcast();
    }
    return _messageStreamControllers[conversationId]!.stream;
  }

  // Mapper les données Supabase vers Message
  Message _mapSupabaseToMessage(Map<String, dynamic> json) {
    return Message.fromJson({
      'id': json['id'],
      'conversationId': json['conversation_id'],
      'senderId': json['sender_id'],
      'senderType': json['sender_type'],  // Garder la string, Message.fromJson se chargera de la conversion
      'content': json['content'],
      'messageType': json['message_type'],  // Garder la string, Message.fromJson se chargera de la conversion
      'attachments': json['attachments'] ?? [],
      'metadata': json['metadata'] ?? {},
      'isRead': json['is_read'] ?? false,
      'readAt': json['read_at'] != null 
          ? (json['read_at'] is DateTime 
              ? (json['read_at'] as DateTime).toIso8601String()
              : json['read_at'])
          : null,
      'createdAt': json['created_at'] is DateTime 
          ? (json['created_at'] as DateTime).toIso8601String()
          : json['created_at'],
      'updatedAt': json['updated_at'] is DateTime 
          ? (json['updated_at'] as DateTime).toIso8601String()
          : json['updated_at'],
      'offerPrice': json['offer_price']?.toDouble(),
      'offerAvailability': json['offer_availability'],
      'offerDeliveryDays': json['offer_delivery_days'],
    });
  }

  /// S'abonner aux changements de messages en temps réel pour une conversation spécifique
  Future<void> subscribeToMessagesForConversation(String? conversationId) async {
    try {
      // Se désabonner du channel existant si nécessaire
      if (_messagesChannel != null) {
        await _messagesChannel!.unsubscribe();
        _messagesChannel = null;
      }
      
      if (conversationId == null) {
        return;
      }
      
      
      _messagesChannel = _supabase
          .channel('messages_channel_$conversationId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              // Vérifier manuellement que c'est pour notre conversation
              if (payload.newRecord['conversation_id'] != conversationId) {
                return;
              }

              // Mapper et envoyer le message au stream spécifique
              try {
                final message = _mapSupabaseToMessage(payload.newRecord);
                
                // Envoyer au stream de cette conversation spécifique
                if (_messageStreamControllers.containsKey(conversationId)) {
                  _messageStreamControllers[conversationId]!.add(message);
                } else {
                }
              } catch (e) {
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              // Vérifier manuellement que c'est pour notre conversation
              if (payload.newRecord['conversation_id'] != conversationId) {
                return;
              }
              // Pour les updates, envoyer aussi au stream spécifique
              try {
                final message = _mapSupabaseToMessage(payload.newRecord);
                
                // Envoyer au stream de cette conversation spécifique
                if (_messageStreamControllers.containsKey(conversationId)) {
                  _messageStreamControllers[conversationId]!.add(message);
                }
              } catch (e) {
              }
            },
          );

      await _messagesChannel!.subscribe();
      
      // Test de diagnostic Realtime
    } catch (e) {
    }
  }

  /// S'abonner aux changements de conversations en temps réel pour un utilisateur
  Future<void> subscribeToConversationsForUser(String? userId) async {
    try {
      // Se désabonner du channel existant si nécessaire
      if (_conversationsChannel != null) {
        await _conversationsChannel!.unsubscribe();
        _conversationsChannel = null;
      }
      
      if (userId == null) {
        return;
      }
      
      
      _conversationsChannel = _supabase
          .channel('conversations_channel_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'conversations',
            callback: (payload) {
              // Vérifier manuellement que c'est pour notre utilisateur
              if (payload.newRecord['user_id'] != userId) {
                return;
              }
              _conversationStreamController.add({
                'type': 'insert',
                'table': 'conversations',
                'record': payload.newRecord,
              });
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'conversations',
            callback: (payload) {
              // Vérifier manuellement que c'est pour notre utilisateur
              if (payload.newRecord['user_id'] != userId) {
                return;
              }
              _conversationStreamController.add({
                'type': 'update',
                'table': 'conversations',
                'record': payload.newRecord,
              });
            },
          );

      await _conversationsChannel!.subscribe();
      
      // Test de diagnostic Realtime
    } catch (e) {
    }
  }

  /// Démarrer tous les abonnements Realtime (méthode générique)
  Future<void> startRealtimeSubscriptions() async {
    // Les abonnements seront configurés dynamiquement selon le contexte
  }
  
  /// S'abonner aux messages d'une conversation spécifique
  Future<void> subscribeToMessages(String conversationId) async {
    await subscribeToMessagesForConversation(conversationId);
  }
  
  /// S'abonner aux conversations d'un utilisateur spécifique  
  Future<void> subscribeToConversations(String userId) async {
    await subscribeToConversationsForUser(userId);
  }

  /// Alias pour startRealtimeSubscriptions
  Future<void> startSubscriptions() async {
    await startRealtimeSubscriptions();
  }

  /// Arrêter tous les abonnements
  Future<void> stopRealtimeSubscriptions() async {
    
    if (_messagesChannel != null) {
      await _messagesChannel!.unsubscribe();
      _messagesChannel = null;
    }
    
    if (_conversationsChannel != null) {
      await _conversationsChannel!.unsubscribe();
      _conversationsChannel = null;
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    // Fermer tous les stream controllers de conversations
    for (final controller in _messageStreamControllers.values) {
      controller.close();
    }
    _messageStreamControllers.clear();
    
    _conversationStreamController.close();
    stopRealtimeSubscriptions();
  }
  
  /// Nettoyer le stream d'une conversation spécifique
  void disposeConversationStream(String conversationId) {
    if (_messageStreamControllers.containsKey(conversationId)) {
      _messageStreamControllers[conversationId]!.close();
      _messageStreamControllers.remove(conversationId);
    }
  }
}