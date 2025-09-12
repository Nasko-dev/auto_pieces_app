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

  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;
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

  // Initialiser les abonnements realtime
  void initializeRealtime(String userId) {
    print('📡 [Controller] Initialisation realtime pour: $userId');
    _setupConversationsSubscription(userId);
    _startRefreshTimer();
  }

  void _setupConversationsSubscription(String userId) {
    _conversationsSubscription?.cancel();
    
    print('🔄 [Controller] Configuration abonnement conversations');
    _conversationsSubscription = _dataSource
        .subscribeToConversationUpdates(userId: userId)
        .listen(
          (updatedConversation) {
            print('📨 [Realtime] Conversation mise à jour reçue');
            _handleConversationUpdate(updatedConversation);
          },
          onError: (error) {
            print('❌ [Realtime] Erreur conversations: $error');
          },
        );
  }

  void _setupMessagesSubscription(String conversationId) {
    _messagesSubscription?.cancel();
    
    print('💬 [Controller] Configuration abonnement messages: $conversationId');
    _messagesSubscription = _dataSource
        .subscribeToNewMessages(conversationId: conversationId)
        .listen(
          (newMessage) {
            print('📨 [Realtime] Nouveau message reçu');
            _handleNewMessage(newMessage);
          },
          onError: (error) {
            print('❌ [Realtime] Erreur messages: $error');
          },
        );
  }

  void _handleConversationUpdate(Conversation updatedConversation) {
    final currentConversations = state.conversations;
    final index = currentConversations.indexWhere((c) => c.id == updatedConversation.id);
    
    if (index != -1) {
      final updatedConversations = [...currentConversations];
      updatedConversations[index] = updatedConversation;
      
      state = state.copyWith(conversations: updatedConversations);
      print('✅ [Controller] Conversation mise à jour dans la liste');
    } else {
      // Nouvelle conversation
      state = state.copyWith(
        conversations: [updatedConversation, ...currentConversations]
      );
      print('✅ [Controller] Nouvelle conversation ajoutée');
    }
    
    _updateUnreadCount();
  }

  void _handleNewMessage(Message newMessage) {
    // Mettre à jour les messages de la conversation
    final currentMessages = Map<String, List<Message>>.from(state.conversationMessages);
    final conversationMessages = currentMessages[newMessage.conversationId] ?? [];
    
    if (!conversationMessages.any((m) => m.id == newMessage.id)) {
      currentMessages[newMessage.conversationId] = [...conversationMessages, newMessage];
      
      state = state.copyWith(conversationMessages: currentMessages);
      print('✅ [Controller] Nouveau message ajouté à la conversation');
      
      // Marquer automatiquement comme lu si la conversation est active
      if (state.activeConversationId == newMessage.conversationId && 
          newMessage.senderType == MessageSenderType.seller) {
        _autoMarkAsRead(newMessage.conversationId);
      }
    }
    
    _updateUnreadCount();
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
        
        // Initialiser le realtime après le premier chargement
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
        
        // Configuration realtime pour cette conversation
        _setupMessagesSubscription(conversationId);
        
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
        print('✅ [Controller] Message envoyé avec succès');
        
        // Ajouter le message à la liste locale
        final updatedMessages = Map<String, List<Message>>.from(state.conversationMessages);
        final currentMessages = updatedMessages[conversationId] ?? [];
        updatedMessages[conversationId] = [...currentMessages, message];
        
        state = state.copyWith(
          conversationMessages: updatedMessages,
          isSendingMessage: false,
          error: null,
        );
        
        // Recharger les conversations pour mettre à jour l'aperçu
        _refreshConversationsQuietly();
      },
    );
  }

  // Ajouter un message reçu en temps réel
  void addRealtimeMessage(Message message) {
    print('🎉 [Controller] Ajout message realtime: ${message.content}');
    
    final currentMessages = Map<String, List<Message>>.from(state.conversationMessages);
    final conversationMessages = currentMessages[message.conversationId] ?? [];
    
    // Vérifier que le message n'existe pas déjà
    if (!conversationMessages.any((m) => m.id == message.id)) {
      currentMessages[message.conversationId] = [...conversationMessages, message];
      
      state = state.copyWith(conversationMessages: currentMessages);
      print('✅ [Controller] Message realtime ajouté à la conversation');
      
      // Marquer automatiquement comme lu si la conversation est active
      if (state.activeConversationId == message.conversationId && 
          message.senderType == MessageSenderType.seller) {
        _autoMarkAsRead(message.conversationId);
      }
      
      // Mettre à jour le compteur de messages non lus
      _updateUnreadCount();
      
      // Rafraîchir les conversations pour mettre à jour l'aperçu
      _refreshConversationsQuietly();
    }
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
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}