import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/parts/domain/entities/message.dart';
import '../../features/parts/domain/entities/conversation_enums.dart';

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
        print('⚠️ [Realtime] Pas de conversationId fourni, pas d\'abonnement');
        return;
      }
      
      print('🔔 [Realtime] Abonnement aux messages pour conversation: $conversationId');
      
      _messagesChannel = _supabase
          .channel('messages_channel_$conversationId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              // Vérifier manuellement que c'est pour notre conversation
              if (payload.newRecord?['conversation_id'] != conversationId) {
                return;
              }
              print('🎉 [Realtime] *** NOUVEAU MESSAGE REÇU *** ');
              print('🔍 [Realtime] Conversation: $conversationId');
              print('🔍 [Realtime] Message ID: ${payload.newRecord?['id']}');
              print('🔍 [Realtime] Contenu: ${payload.newRecord?['content']}');
              
              // Mapper et envoyer le message au stream spécifique
              try {
                final message = _mapSupabaseToMessage(payload.newRecord as Map<String, dynamic>);
                
                // Envoyer au stream de cette conversation spécifique
                if (_messageStreamControllers.containsKey(conversationId)) {
                  _messageStreamControllers[conversationId]!.add(message);
                  print('📨 [Realtime] Message envoyé au stream conversation $conversationId');
                } else {
                  print('⚠️ [Realtime] Aucun listener pour conversation $conversationId');
                }
              } catch (e) {
                print('❌ [Realtime] Erreur mapping message: $e');
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              // Vérifier manuellement que c'est pour notre conversation
              if (payload.newRecord?['conversation_id'] != conversationId) {
                return;
              }
              print('📝 [Realtime] Message mis à jour: ${payload.newRecord}');
              // Pour les updates, envoyer aussi au stream spécifique
              try {
                final message = _mapSupabaseToMessage(payload.newRecord as Map<String, dynamic>);
                
                // Envoyer au stream de cette conversation spécifique
                if (_messageStreamControllers.containsKey(conversationId)) {
                  _messageStreamControllers[conversationId]!.add(message);
                  print('🔄 [Realtime] Message update envoyé au stream conversation $conversationId');
                }
              } catch (e) {
                print('❌ [Realtime] Erreur mapping message update: $e');
              }
            },
          );

      await _messagesChannel!.subscribe();
      print('✅ [Realtime] Abonné aux messages');
      
      // Test de diagnostic Realtime
      print('🔍 [Realtime] Channel messages créé et abonné');
    } catch (e) {
      print('❌ [Realtime] Erreur abonnement messages: $e');
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
        print('⚠️ [Realtime] Pas de userId fourni, pas d\'abonnement');
        return;
      }
      
      print('🔔 [Realtime] Abonnement aux conversations pour user: $userId');
      
      _conversationsChannel = _supabase
          .channel('conversations_channel_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'conversations',
            callback: (payload) {
              // Vérifier manuellement que c'est pour notre utilisateur
              if (payload.newRecord?['user_id'] != userId) {
                return;
              }
              print('💬 [Realtime] Nouvelle conversation pour user $userId');
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
              if (payload.newRecord?['user_id'] != userId) {
                return;
              }
              print('🔄 [Realtime] Conversation mise à jour: ${payload.newRecord}');
              _conversationStreamController.add({
                'type': 'update',
                'table': 'conversations',
                'record': payload.newRecord,
              });
            },
          );

      await _conversationsChannel!.subscribe();
      print('✅ [Realtime] Abonné aux conversations');
      
      // Test de diagnostic Realtime
      print('🔍 [Realtime] Channel conversations créé et abonné');
    } catch (e) {
      print('❌ [Realtime] Erreur abonnement conversations: $e');
    }
  }

  /// Démarrer tous les abonnements Realtime (méthode générique)
  Future<void> startRealtimeSubscriptions() async {
    print('🚀 [Realtime] Service Realtime prêt (abonnements à configurer par utilisateur/conversation)');
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
    print('🛑 [Realtime] Arrêt des abonnements');
    
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
      print('🧹 [Realtime] Stream conversation $conversationId fermé');
    }
  }
}