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
import '../../../../core/utils/logger.dart';
import 'base_conversation_controller.dart';

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

class ConversationsController extends BaseConversationController<ConversationsState> {
  final GetConversations _getConversations;
  final GetConversationMessages _getConversationMessages;
  final SendMessage _sendMessage;
  final MarkMessagesAsRead _markMessagesAsRead;
  final DeleteConversation _deleteConversation;
  final BlockConversation _blockConversation;
  final CloseConversation _closeConversation;
  final ConversationsRemoteDataSource _dataSource;
  final RealtimeService _realtimeService;

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

  // ✅ OPTIMISATION: Variable pour éviter les initialisations multiples
  bool _isRealtimeInitialized = false;

  // Initialiser le realtime et le refresh timer - UNE SEULE FOIS
  void initializeRealtime(String userId) {
    if (_isRealtimeInitialized) {
      print('⚠️ [Controller] Realtime déjà initialisé, ignorer');
      return;
    }

    print('📡 [Controller] Initialisation realtime et refresh timer pour: $userId');
    _startRefreshTimer();
    _subscribeToAllUserMessages(userId);
    _isRealtimeInitialized = true;
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
    print('👤 [Controller] UserId actuel: $userId');
    print('🔄 [Controller] senderId == userId ? ${senderId == userId}');
    print('🧐 [Controller] DEBUG: senderId="$senderId" (${senderId.runtimeType})');
    print('🧐 [Controller] DEBUG: userId="$userId" (${userId.runtimeType})');
    print('🧐 [Controller] DEBUG: senderId.toString()="${senderId.toString()}"');
    print('🧐 [Controller] DEBUG: userId.toString()="${userId.toString()}"');

    // ✅ CRITICAL: Vérifications multiples pour être sûr que ce n'est pas notre message
    final isOwnMessage = senderId == userId ||
                        senderId.toString() == userId.toString() ||
                        senderId.toString() == userId;

    if (isOwnMessage) {
      print('🚫 [Controller] C\'est notre propre message → IGNORER COMPLÈTEMENT');
      return;  // SORTIR IMMÉDIATEMENT
    }

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
      print('📤 [Controller] Message vendeur d\'un autre utilisateur, pas de compteur pour nous');
    }

    // ✅ OPTIMISATION: Plus de refresh automatique, juste mise à jour locale
    print('✅ [Controller] Message traité, pas de refresh (éviter boucles)');
  }

  // ✅ OPTIMISÉ: Méthode publique simplifiée pour les pages de chat
  void handleIncomingMessage(Message newMessage) {
    print('📨 [Controller] handleIncomingMessage: ${newMessage.content}');

    // Ajouter le message localement aux messages de la conversation
    final currentMessages = Map<String, List<Message>>.from(state.conversationMessages);
    final conversationMessages = currentMessages[newMessage.conversationId] ?? [];

    if (!conversationMessages.any((m) => m.id == newMessage.id)) {
      final updatedMessages = [...conversationMessages, newMessage];
      updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      currentMessages[newMessage.conversationId] = updatedMessages;

      state = state.copyWith(conversationMessages: currentMessages);
      print('✅ [Controller] Message ajouté localement');
    }

    // Note: Les compteurs sont gérés par _handleGlobalNewMessage via trigger realtime
  }

  // ✅ SUPPRIMÉ: Méthode de tri plus nécessaire - DB déjà triée par last_message_at

  void _startRefreshTimer() {
    startIntelligentPolling(
      interval: const Duration(seconds: 30),
      onPoll: _refreshConversationsQuietly,
      logPrefix: 'ConversationsController',
    );
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

        // ✅ OPTIMISATION: Initialiser le realtime seulement au premier chargement
        if (!_isRealtimeInitialized) {
          initializeRealtime(userId);
        }
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
    List<String> attachments = const [],
    Map<String, dynamic> metadata = const {},
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
      attachments: attachments,
      metadata: metadata,
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
          
          // ✅ OPTIMISATION: Pas de refresh automatique, les triggers realtime s'en chargent
          // _refreshConversationsQuietly(); // SUPPRIMÉ pour éviter double refresh
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

  // ✅ DB-BASED: Incrémenter compteur vendeur en DB - SANS REFRESH AUTO
  void _incrementUnreadCountInDB(String conversationId) async {
    try {
      // Utiliser le compteur spécifique vendeur
      await _dataSource.incrementUnreadCountForSeller(conversationId: conversationId);
      print('✅ [Controller] Compteur VENDEUR DB incrémenté pour: $conversationId');

      // ✅ OPTIMISATION: Mise à jour locale immédiate au lieu de full reload
      _updateLocalUnreadCount(conversationId, 1);
    } catch (e) {
      print('❌ [Controller] Erreur incrémentation DB vendeur: $e');
    }
  }

  // ✅ DB-BASED: Marquer conversation comme lue en DB - SANS REFRESH AUTO
  void _markConversationAsReadInDB(String conversationId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _dataSource.markMessagesAsRead(
        conversationId: conversationId,
        userId: userId,
      );
      print('✅ [Controller] Conversation marquée comme lue en DB: $conversationId');

      // ✅ OPTIMISATION: Mise à jour locale immédiate au lieu de full reload
      _updateLocalUnreadCount(conversationId, -999); // Reset à 0
    } catch (e) {
      print('❌ [Controller] Erreur marquage DB: $e');
    }
  }

  // ✅ OPTIMISATION: Mise à jour locale pour éviter les full reload
  void _updateLocalUnreadCount(String conversationId, int delta) {
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == conversationId) {
        final newCount = delta == -999 ? 0 : (conv.unreadCount + delta).clamp(0, 9999);
        return conv.copyWith(unreadCount: newCount);
      }
      return conv;
    }).toList();

    final newTotal = updatedConversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);

    state = state.copyWith(
      conversations: updatedConversations,
      totalUnreadCount: newTotal,
    );

    print('📊 [Controller] Local update: conv $conversationId = ${delta == -999 ? 0 : "+" + delta.toString()}, total = $newTotal');
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
    Logger.info('🧹 [Controller] Nettoyage ressources');
    _allMessagesSubscription?.cancel();
    _conversationsSubscription?.cancel();
    super.dispose(); // Appelle stopPolling() dans BaseConversationController
  }
}