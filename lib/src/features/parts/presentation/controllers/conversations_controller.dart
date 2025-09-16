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
import '../../data/datasources/conversations_remote_datasource.dart';
import '../../../../core/services/realtime_service.dart';

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
  final RealtimeService _realtimeService;

  Timer? _refreshTimer;
  StreamSubscription? _allMessagesSubscription;
  StreamSubscription? _conversationsSubscription;

  ConversationsController({
    required GetConversations getConversations,
    required GetConversationMessages getConversationMessages,
    required SendMessage sendMessage,
    required MarkMessagesAsRead markMessagesAsRead,
    required DeleteConversation deleteConversation,
    required BlockConversation blockConversation,
    required CloseConversation closeConversation,
    required ConversationsRemoteDataSource dataSource,
    required RealtimeService realtimeService,
  })  : _getConversations = getConversations,
        _getConversationMessages = getConversationMessages,
        _sendMessage = sendMessage,
        _markMessagesAsRead = markMessagesAsRead,
        _deleteConversation = deleteConversation,
        _blockConversation = blockConversation,
        _closeConversation = closeConversation,
        _dataSource = dataSource,
        _realtimeService = realtimeService,
        super(const ConversationsState());

  // Initialiser le realtime et le refresh timer
  void initializeRealtime(String userId) {
    print('📡 [Controller] Initialisation realtime et refresh timer pour: $userId');
    _startRefreshTimer();
    _subscribeToAllUserMessages(userId);
  }

  // S'abonner à tous les messages de l'utilisateur
  void _subscribeToAllUserMessages(String userId) {
    print('🔔 [Controller] Abonnement global aux messages pour user: $userId');
    
    // S'abonner aux changements de conversations
    _realtimeService.subscribeToConversationsForUser(userId);
    _conversationsSubscription = _realtimeService.conversationStream.listen((event) {
      print('📨 [Controller] Événement conversation reçu: ${event['type']}');
      // Recharger les conversations lors de changements
      loadConversations();
    });

    // Pour écouter les nouveaux messages, on doit s'abonner à toutes les conversations
    // On va améliorer cela en créant un listener global pour les messages
    _subscribeToGlobalMessages(userId);
  }

  // S'abonner globalement aux messages de toutes les conversations de l'utilisateur
  void _subscribeToGlobalMessages(String userId) async {
    print('🌍 [Controller] Configuration écoute globale des messages');
    
    // Créer un channel pour écouter TOUS les messages où l'utilisateur est impliqué
    final channel = Supabase.instance.client
        .channel('global_messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            print('🎉 [Controller] *** TRIGGER NOUVEAU MESSAGE DÉTECTÉ ***');
            print('💬 [Controller] Nouveau message global détecté');
            _handleGlobalNewMessage(payload.newRecord, userId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'conversations',
          callback: (payload) {
            print('🔄 [Controller] Conversation mise à jour détectée');
            // Refresh quand une conversation est mise à jour (ex: unread_count)
            loadConversations();
          },
        );
    
    channel.subscribe();
    print('✅ [Controller] Channel global messages abonné');
  }

  // ✅ SIMPLE: Gérer un nouveau message reçu - incrémenter compteur local côté vendeur
  void _handleGlobalNewMessage(dynamic messageData, String userId) async {
    final conversationId = messageData['conversation_id'] as String?;
    final senderId = messageData['sender_id'] as String?;
    final senderType = messageData['sender_type'] as String?;

    if (conversationId == null || senderId == null || senderType == null) return;

    print('🎉 [Controller] *** NOUVEAU MESSAGE REÇU *** ');
    print('🔍 [Controller] Conversation: $conversationId, Sender: $senderId, Type: $senderType');

    // ✅ DB-BASED: Si c'est un message du particulier, incrémenter en DB sauf si conversation active
    if (senderType == 'user') {
      if (state.activeConversationId == conversationId) {
        print('👀 [Controller] Message reçu dans conversation active → marqué comme lu automatiquement');
        // Marquer le message comme lu immédiatement si la conversation est ouverte
        _markConversationAsReadInDB(conversationId);
      } else {
        print('🔥 [Controller] Message du particulier → +1 compteur en DB');
        _incrementUnreadCountInDB(conversationId);
      }
    } else {
      print('📤 [Controller] Notre propre message, pas de compteur');
    }

    // Si ce n'est pas notre propre message, refresh immédiatement
    if (senderId != userId) {
      print('🚀 [Controller] Message d\'un autre utilisateur → REFRESH IMMÉDIAT');
      await loadConversations();
    }
  }

  // Méthode simplifiée pour recevoir des messages du RealtimeService
  void handleIncomingMessage(Message newMessage) {
    print('🎉 [Controller] *** NOUVEAU MESSAGE DÉTECTÉ - REFRESH AUTOMATIQUE ***');
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
      
      // Plus besoin de recalculer - compteurs locaux gérés en temps réel
      
      // 🚀 TRI OPTIMISÉ après nouveau message (évite un refresh DB complet)
      print('🚀 [Controller] Re-tri optimisé suite au nouveau message');
      _sortConversationsIfNeeded();
    }
  }

  // Tri optimisé - seulement quand nécessaire (après nouveau message)
  void _sortConversationsIfNeeded() {
    final conversations = [...state.conversations];
    conversations.sort((a, b) {
      // Prioriser lastMessageAt (plus fiable car vient de la DB)
      if (a.lastMessageAt != null && b.lastMessageAt != null) {
        return b.lastMessageAt.compareTo(a.lastMessageAt);
      }
      
      // Fallback sur les messages en mémoire si lastMessageAt indisponible
      final messagesA = state.conversationMessages[a.id] ?? [];
      final messagesB = state.conversationMessages[b.id] ?? [];
      
      if (messagesA.isEmpty && messagesB.isEmpty) return 0;
      if (messagesA.isEmpty) return 1;
      if (messagesB.isEmpty) return -1;
      
      return messagesB.last.createdAt.compareTo(messagesA.last.createdAt);
    });
    
    state = state.copyWith(conversations: conversations);
    print('🔄 [Controller] Conversations re-triées après nouveau message');
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
          state = state.copyWith(conversations: conversations); // Déjà triées en DB
          // Plus besoin de recalculer - compteurs locaux gérés en temps réel
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

        // ✅ DB-BASED: Utiliser directement les compteurs de la DB
        final totalUnread = conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);

        state = state.copyWith(
          conversations: conversations, // Triées en DB par last_message_at DESC avec unreadCount
          isLoading: false,
          error: null,
          totalUnreadCount: totalUnread,
        );
        print('📊 [Controller] ${conversations.length} conversations chargées, total unread: $totalUnread');
        
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
        
        // Plus besoin de calculs - compteurs locaux gérés en temps réel
      },
    );
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

    print('👀 [VendeurController] Marquage comme lu: $conversationId');

    final result = await _markMessagesAsRead(MarkMessagesAsReadParams(
      conversationId: conversationId,
      userId: userId,
    ));
    
    result.fold(
      (failure) => print('⚠️ [VendeurController] Erreur marquage: ${failure.message}'),
      (_) {
        print('✅ [VendeurController] Messages marqués comme lus');
        _updateConversationReadStatus(conversationId);
        
        // 🚀 REFRESH IMMÉDIAT après marquage comme lu
        print('🚀 [VendeurController] Refresh après marquage comme lu');
        loadConversations();
      },
    );
  }

  void _updateConversationReadStatus(String conversationId) {
    // Marquer les messages de cette conversation comme lus localement
    // SEULEMENT pour les messages reçus (pas envoyés) par l'utilisateur actuel
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    final updatedMessages = Map<String, List<Message>>.from(state.conversationMessages);
    final messages = updatedMessages[conversationId];
    if (messages != null) {
      updatedMessages[conversationId] = messages.map((msg) =>
        // ✅ CORRECTION: Ne marquer comme lus QUE les messages reçus par cet utilisateur
        // ET qui ne sont pas déjà lus
        (msg.senderId != currentUserId && !msg.isRead)
            ? msg.copyWith(isRead: true, readAt: DateTime.now())
            : msg
      ).toList();

      state = state.copyWith(conversationMessages: updatedMessages);
      print('✅ [VendeurController] Messages reçus marqués comme lus pour: $conversationId');
    }

    // Plus besoin de recalculer - compteurs locaux gérés en temps réel
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

        // Plus besoin de recalculer - compteurs locaux gérés en temps réel
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
        // Plus besoin de recalculer - compteurs locaux gérés en temps réel
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

  // ✅ DB-BASED: Marquer conversation comme active et remettre compteur DB à 0
  void markConversationAsRead(String conversationId) {
    print('👀 [Controller] Ouverture conversation: $conversationId → compteur DB = 0 + active');

    // Marquer en DB
    _markConversationAsReadInDB(conversationId);

    // Marquer comme conversation active
    state = state.copyWith(activeConversationId: conversationId);

    print('📊 [Controller] Conversation $conversationId maintenant active');
  }

  // ✅ DB-BASED: Incrémenter compteur en DB
  void _incrementUnreadCountInDB(String conversationId) async {
    try {
      final result = await _dataSource.incrementUnreadCount(conversationId: conversationId);
      print('✅ [Controller] Compteur DB incrémenté pour: $conversationId');
      // Refresh pour récupérer le nouveau compteur
      loadConversations();
    } catch (e) {
      print('❌ [Controller] Erreur incrémentation DB: $e');
    }
  }

  // ✅ DB-BASED: Marquer conversation comme lue en DB
  void _markConversationAsReadInDB(String conversationId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _dataSource.markMessagesAsRead(
        conversationId: conversationId,
        userId: userId,
      );
      print('✅ [Controller] Conversation marquée comme lue en DB: $conversationId');
      // Refresh pour récupérer le nouveau compteur
      loadConversations();
    } catch (e) {
      print('❌ [Controller] Erreur marquage DB: $e');
    }
  }

  // ✅ SIMPLE: Désactiver la conversation active
  void setConversationInactive() {
    print('🚪 [Controller] Aucune conversation active');
    // ✅ SIMPLE: Éviter setState during build en différant la mise à jour
    Future.microtask(() {
      state = state.copyWith(activeConversationId: null);
    });
  }



  // Helpers
  List<Message> getMessagesForConversation(String conversationId) {
    return state.conversationMessages[conversationId] ?? [];
  }


  @override
  void dispose() {
    print('🧹 [Controller] Nettoyage ressources');
    _refreshTimer?.cancel();
    _allMessagesSubscription?.cancel();
    _conversationsSubscription?.cancel();
    super.dispose();
  }
}