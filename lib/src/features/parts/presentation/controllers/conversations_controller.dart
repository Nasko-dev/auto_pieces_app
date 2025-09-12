import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation_enums.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/get_conversation_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/manage_conversation.dart';
import '../../data/repositories/conversations_repository_impl.dart';
import '../../data/datasources/conversations_remote_datasource.dart';

part 'conversations_controller.freezed.dart';

@freezed
class ConversationsState with _$ConversationsState {
  const factory ConversationsState({
    @Default([]) List<Conversation> conversations,
    @Default({}) Map<String, List<Message>> conversationMessages,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMessages,
    @Default(false) bool isSendingMessage,
    String? error,
    String? activeConversationId,
    @Default(0) int totalUnreadCount,
  }) = _ConversationsState;
}

class ConversationsController extends StateNotifier<ConversationsState> {
  final GetConversations _getConversations;
  final GetConversationMessages _getConversationMessages;
  final SendMessage _sendMessage;
  final MarkMessagesAsRead _markMessagesAsRead;
  final DeleteConversation _deleteConversation;
  final BlockConversation _blockConversation;
  final CloseConversation _closeConversation;
  final ConversationsRemoteDataSource _dataSource;

  Timer? _refreshTimer;

  ConversationsController({
    required GetConversations getConversations,
    required GetConversationMessages getConversationMessages,
    required SendMessage sendMessage,
    required MarkMessagesAsRead markMessagesAsRead,
    required DeleteConversation deleteConversation,
    required BlockConversation blockConversation,
    required CloseConversation closeConversation,
    required ConversationsRemoteDataSource dataSource,
  })  : _getConversations = getConversations,
        _getConversationMessages = getConversationMessages,
        _sendMessage = sendMessage,
        _markMessagesAsRead = markMessagesAsRead,
        _deleteConversation = deleteConversation,
        _blockConversation = blockConversation,
        _closeConversation = closeConversation,
        _dataSource = dataSource,
        super(const ConversationsState());

  // Initialiser le refresh timer uniquement
  void initializeRealtime(String userId) {
    print('📡 [Controller] Initialisation refresh timer pour: $userId');
    _startRefreshTimer();
  }

  // Méthode simplifiée pour recevoir des messages du RealtimeService
  void handleIncomingMessage(Message newMessage) {
    print('📨 [Controller] Message reçu du RealtimeService: ${newMessage.content}');
    
    final currentMessages = Map<String, List<Message>>.from(state.conversationMessages);
    final conversationMessages = currentMessages[newMessage.conversationId] ?? [];
    
    if (!conversationMessages.any((m) => m.id == newMessage.id)) {
      final updatedMessages = [...conversationMessages, newMessage];
      // Tri par timestamp Supabase (UTC) - fiable car généré côté serveur
      updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      currentMessages[newMessage.conversationId] = updatedMessages;
      
      state = state.copyWith(conversationMessages: currentMessages);
      print('✅ [Controller] Message ajouté à la conversation');
      
      // Marquer automatiquement comme lu si la conversation est active
      if (state.activeConversationId == newMessage.conversationId && 
          newMessage.senderType == MessageSenderType.seller) {
        _autoMarkAsRead(newMessage.conversationId);
      }
      
      _updateUnreadCount();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _refreshConversationsQuietly();
      }
    });
  }

  Future<void> _refreshConversationsQuietly() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final result = await _getConversations(GetConversationsParams(userId: userId));
      result.fold(
        (failure) => print('⚠️ [Controller] Erreur refresh silencieux: ${failure.message}'),
        (conversations) {
          state = state.copyWith(conversations: conversations);
          _updateUnreadCount();
        },
      );
    }
  }

  // Charger les conversations
  Future<void> loadConversations() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      print('❌ [Controller] Utilisateur non connecté');
      return;
    }

    print('📋 [Controller] Chargement conversations pour: $userId');
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getConversations(GetConversationsParams(userId: userId));
    
    result.fold(
      (failure) {
        print('❌ [Controller] Erreur chargement: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (conversations) {
        print('✅ [Controller] ${conversations.length} conversations chargées');
        state = state.copyWith(
          conversations: conversations,
          isLoading: false,
          error: null,
        );
        _updateUnreadCount();
        
        // Initialiser le refresh timer après le premier chargement
        initializeRealtime(userId);
      },
    );
  }

  // Charger les messages d'une conversation
  Future<void> loadConversationMessages(String conversationId) async {
    print('💬 [Controller] Chargement messages: $conversationId');
    
    state = state.copyWith(
      isLoadingMessages: true,
      activeConversationId: conversationId,
    );

    final result = await _getConversationMessages(
      GetConversationMessagesParams(conversationId: conversationId)
    );
    
    result.fold(
      (failure) {
        print('❌ [Controller] Erreur chargement messages: ${failure.message}');
        state = state.copyWith(
          isLoadingMessages: false,
          error: failure.message,
        );
      },
      (messages) {
        print('✅ [Controller] ${messages.length} messages chargés');
        final updatedMessages = Map<String, List<Message>>.from(state.conversationMessages);
        updatedMessages[conversationId] = messages;
        
        state = state.copyWith(
          conversationMessages: updatedMessages,
          isLoadingMessages: false,
          error: null,
        );
        
        // Marquer comme lu automatiquement
        _autoMarkAsRead(conversationId);
      },
    );
  }

  Future<void> _autoMarkAsRead(String conversationId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await markAsRead(conversationId);
    }
  }

  // Envoyer un message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType messageType = MessageType.text,
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      print('❌ [Controller] Utilisateur non connecté');
      return;
    }

    print('📤 [Controller] Envoi message: $content');
    state = state.copyWith(isSendingMessage: true);

    final result = await _sendMessage(SendMessageParams(
      conversationId: conversationId,
      senderId: userId,
      content: content,
      messageType: messageType,
      offerPrice: offerPrice,
      offerAvailability: offerAvailability,
      offerDeliveryDays: offerDeliveryDays,
    ));
    
    result.fold(
      (failure) {
        print('❌ [Controller] Erreur envoi: ${failure.message}');
        state = state.copyWith(
          isSendingMessage: false,
          error: failure.message,
        );
      },
      (message) {
        try {
          print('✅ [Controller] Message envoyé avec succès');
          
          // Ajouter le message localement pour l'expéditeur immédiatement
          // Le RealtimeService le recevra aussi mais _handleNewMessage évite la duplication
          final currentMessages = Map<String, List<Message>>.from(state.conversationMessages);
          final conversationMessages = currentMessages[conversationId] ?? [];
          
          if (!conversationMessages.any((m) => m.id == message.id)) {
            final updatedMessages = [...conversationMessages, message];
            // Tri par timestamp Supabase (UTC) - fiable car généré côté serveur
            updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            currentMessages[conversationId] = updatedMessages;
            
            print('🕒 [Controller] Message local timestamp: ${message.createdAt.toIso8601String()}');
            print('📋 [Controller] Ordre final messages: ${updatedMessages.map((m) => '${m.content.length > 10 ? m.content.substring(0, 10) : m.content}... - ${m.createdAt.toIso8601String()}').join(', ')}');
            
            state = state.copyWith(
              conversationMessages: currentMessages,
              isSendingMessage: false,
              error: null,
            );
          } else {
            state = state.copyWith(
              isSendingMessage: false,
              error: null,
            );
          }
          
          // Recharger les conversations pour mettre à jour l'aperçu
          _refreshConversationsQuietly();
        } catch (e) {
          print('❌ [Controller] Erreur lors du traitement local: $e');
          state = state.copyWith(
            isSendingMessage: false,
            error: 'Erreur lors du traitement du message',
          );
        }
      },
    );
  }

  
  // Marquer comme lu
  Future<void> markAsRead(String conversationId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    print('👀 [Controller] Marquage comme lu: $conversationId');

    final result = await _markMessagesAsRead(MarkMessagesAsReadParams(
      conversationId: conversationId,
      userId: userId,
    ));
    
    result.fold(
      (failure) => print('⚠️ [Controller] Erreur marquage: ${failure.message}'),
      (_) {
        print('✅ [Controller] Messages marqués comme lus');
        _updateConversationReadStatus(conversationId);
      },
    );
  }

  void _updateConversationReadStatus(String conversationId) {
    // Marquer les messages de cette conversation comme lus localement
    final updatedMessages = Map<String, List<Message>>.from(state.conversationMessages);
    final messages = updatedMessages[conversationId];
    if (messages != null) {
      updatedMessages[conversationId] = messages.map((msg) => 
        msg.senderType == MessageSenderType.seller
            ? msg.copyWith(isRead: true, readAt: DateTime.now())
            : msg
      ).toList();
      
      state = state.copyWith(conversationMessages: updatedMessages);
    }
    
    _updateUnreadCount();
  }

  // Supprimer une conversation
  Future<void> deleteConversation(String conversationId) async {
    print('🗑️ [Controller] Suppression conversation: $conversationId');

    final result = await _deleteConversation(ConversationParams(
      conversationId: conversationId,
    ));
    
    result.fold(
      (failure) {
        print('❌ [Controller] Erreur suppression: ${failure.message}');
        state = state.copyWith(error: failure.message);
      },
      (_) {
        print('✅ [Controller] Conversation supprimée');
        
        // Retirer de la liste locale
        final updatedConversations = state.conversations
            .where((c) => c.id != conversationId)
            .toList();
        
        final updatedMessages = Map<String, List<Message>>.from(state.conversationMessages);
        updatedMessages.remove(conversationId);
        
        state = state.copyWith(
          conversations: updatedConversations,
          conversationMessages: updatedMessages,
        );
        
        _updateUnreadCount();
      },
    );
  }

  // Bloquer une conversation
  Future<void> blockConversation(String conversationId) async {
    print('🚫 [Controller] Blocage conversation: $conversationId');

    final result = await _blockConversation(ConversationParams(
      conversationId: conversationId,
    ));
    
    result.fold(
      (failure) {
        print('❌ [Controller] Erreur blocage: ${failure.message}');
        state = state.copyWith(error: failure.message);
      },
      (_) {
        print('✅ [Controller] Conversation bloquée');
        
        // Retirer de la liste locale (car bloquée)
        final updatedConversations = state.conversations
            .where((c) => c.id != conversationId)
            .toList();
        
        state = state.copyWith(conversations: updatedConversations);
        _updateUnreadCount();
      },
    );
  }

  // Fermer une conversation
  Future<void> closeConversation(String conversationId) async {
    print('📪 [Controller] Fermeture conversation: $conversationId');

    final result = await _closeConversation(ConversationParams(
      conversationId: conversationId,
    ));
    
    result.fold(
      (failure) {
        print('❌ [Controller] Erreur fermeture: ${failure.message}');
        state = state.copyWith(error: failure.message);
      },
      (_) {
        print('✅ [Controller] Conversation fermée');
        
        // Mettre à jour le statut localement
        final updatedConversations = state.conversations.map((c) => 
          c.id == conversationId 
              ? c.copyWith(status: ConversationStatus.closed)
              : c
        ).toList();
        
        state = state.copyWith(conversations: updatedConversations);
      },
    );
  }

  // Calculer le nombre total de messages non lus
  void _updateUnreadCount() {
    int totalUnread = 0;
    
    for (final conversation in state.conversations) {
      final messages = state.conversationMessages[conversation.id] ?? [];
      final unreadInConversation = messages
          .where((msg) => msg.senderType == MessageSenderType.seller && !msg.isRead)
          .length;
      totalUnread += unreadInConversation;
    }
    
    state = state.copyWith(totalUnreadCount: totalUnread);
    print('🔔 [Controller] Total messages non lus: $totalUnread');
  }

  // Helpers
  List<Message> getMessagesForConversation(String conversationId) {
    return state.conversationMessages[conversationId] ?? [];
  }

  int getUnreadCountForConversation(String conversationId) {
    final messages = getMessagesForConversation(conversationId);
    return messages
        .where((msg) => msg.senderType == MessageSenderType.seller && !msg.isRead)
        .length;
  }

  @override
  void dispose() {
    print('🧹 [Controller] Nettoyage ressources');
    _refreshTimer?.cancel();
    super.dispose();
  }
}