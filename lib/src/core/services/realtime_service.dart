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

  /// S'abonner aux changements de messages en temps réel
  Future<void> subscribeToMessages() async {
    try {
      print('🔔 [Realtime] Abonnement aux messages');
      
      _messagesChannel = _supabase
          .channel('messages_channel')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              print('🎉 [Realtime] *** ÉVÉNEMENT MESSAGE REÇU *** : ${payload.newRecord}');
              print('🔍 [Realtime] Type: insert, Table: messages');
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

  /// S'abonner aux changements de conversations en temps réel
  Future<void> subscribeToConversations() async {
    try {
      print('🔔 [Realtime] Abonnement aux conversations');
      
      _conversationsChannel = _supabase
          .channel('conversations_channel')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'conversations',
            callback: (payload) {
              print('💬 [Realtime] Nouvelle conversation: ${payload.newRecord}');
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

  /// Démarrer tous les abonnements Realtime
  Future<void> startRealtimeSubscriptions() async {
    print('🚀 [Realtime] Démarrage des abonnements');
    await Future.wait([
      subscribeToMessages(),
      subscribeToConversations(),
    ]);
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