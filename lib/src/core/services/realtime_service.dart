import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _conversationsChannel;

  // Streams pour les messages et conversations
  final StreamController<Map<String, dynamic>> _messageStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _conversationStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;
  Stream<Map<String, dynamic>> get conversationStream => _conversationStreamController.stream;

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
            filter: 'conversation_id=eq.$conversationId',
            callback: (payload) {
              print('🎉 [Realtime] *** NOUVEAU MESSAGE REÇU *** ');
              print('🔍 [Realtime] Conversation: $conversationId');
              print('🔍 [Realtime] Message ID: ${payload.newRecord?['id']}');
              print('🔍 [Realtime] Contenu: ${payload.newRecord?['content']}');
              _messageStreamController.add({
                'type': 'insert',
                'table': 'messages',
                'record': payload.newRecord,
              });
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              print('📝 [Realtime] Message mis à jour: ${payload.newRecord}');
              _messageStreamController.add({
                'type': 'update',
                'table': 'messages',
                'record': payload.newRecord,
              });
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
            filter: 'user_id=eq.$userId',
            callback: (payload) {
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
    _messageStreamController.close();
    _conversationStreamController.close();
    stopRealtimeSubscriptions();
  }
}