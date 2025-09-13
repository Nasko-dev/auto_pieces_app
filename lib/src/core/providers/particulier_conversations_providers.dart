import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/realtime_service.dart';
import '../../features/parts/domain/repositories/part_request_repository.dart';
import '../../features/parts/domain/entities/particulier_conversation.dart';
import 'part_request_providers.dart';

part 'particulier_conversations_providers.freezed.dart';

@freezed
class ParticulierConversationsState with _$ParticulierConversationsState {
  const factory ParticulierConversationsState({
    @Default([]) List<ParticulierConversation> conversations,
    @Default(false) bool isLoading,
    String? error,
    @Default(0) int unreadCount,
  }) = _ParticulierConversationsState;
}

class ParticulierConversationsController extends StateNotifier<ParticulierConversationsState> {
  final PartRequestRepository _repository;
  final RealtimeService _realtimeService;
  Timer? _pollingTimer;
  bool _isPollingActive = false;

  ParticulierConversationsController({
    required PartRequestRepository repository,
    required RealtimeService realtimeService,
  }) : _repository = repository,
       _realtimeService = realtimeService,
       super(const ParticulierConversationsState()) {
    _initializeRealtimeSubscriptions();
    // Le polling sera démarré dans initializeRealtime() avec les bons IDs
  }

  void _initializeRealtimeSubscriptions() {
    print('🔔 [ParticulierConversations] Initialisation du temps réel');
    _realtimeService.startSubscriptions();
  }
  
  // Abonnement global aux messages - même structure que le vendeur
  void initializeRealtime(String userId) async {
    print('📡 [ParticulierConversations] Initialisation realtime global pour particulier: $userId');
    _startIntelligentPolling();
    _subscribeToGlobalMessages(userId);
  }

  // S'abonner globalement aux messages - exactement comme le vendeur
  void _subscribeToGlobalMessages(String userId) async {
    print('🌍 [ParticulierConversations] Configuration écoute globale des messages');
    
    // Créer un channel pour écouter TOUS les messages où l'utilisateur est impliqué
    final channel = Supabase.instance.client
        .channel('global_particulier_messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            print('🎉 [ParticulierConversations] *** TRIGGER NOUVEAU MESSAGE DÉTECTÉ ***');
            print('💬 [ParticulierConversations] Nouveau message global détecté');
            _handleGlobalNewMessage(payload.newRecord as Map<String, dynamic>, userId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'conversations',
          callback: (payload) {
            print('🔄 [ParticulierConversations] Conversation mise à jour détectée');
            // Refresh quand une conversation est mise à jour (ex: unread_count)
            loadConversations();
          },
        );
    
    await channel.subscribe();
    print('✅ [ParticulierConversations] Channel global messages abonné');
  }

  // Gérer un nouveau message reçu globalement - même logique que le vendeur
  void _handleGlobalNewMessage(Map<String, dynamic> messageData, String userId) async {
    final conversationId = messageData['conversation_id'] as String?;
    final senderId = messageData['sender_id'] as String?;
    
    if (conversationId == null || senderId == null) return;

    print('🎉 [ParticulierConversations] *** NOUVEAU MESSAGE REÇU *** ');
    print('🔍 [ParticulierConversations] Conversation: $conversationId, Sender: $senderId');
    
    // Si ce n'est pas notre propre message, refresh immédiatement
    if (senderId != userId) {
      print('🚀 [ParticulierConversations] Message d\'un vendeur → REFRESH IMMÉDIAT');
      await loadConversations();
    } else {
      print('📤 [ParticulierConversations] Notre propre message, pas besoin de refresh');
    }
  }

  void _startIntelligentPolling() {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    print('⏰ [ParticulierConversations] Polling de fond réduit (30s)');
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadConversationsQuietly();
      }
    });
  }

  Future<void> loadConversations() async {
    print('💬 [ParticulierConversations] Chargement conversations');
    
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.getParticulierConversations();
    
    result.fold(
      (failure) {
        print('❌ [ParticulierConversations] Erreur: ${failure.message}');
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        }
      },
      (conversations) {
        final updatedConversations = _calculateAndUpdateUnreadCounts(conversations);
        final sortedConversations = _sortConversationsByLastMessage(updatedConversations);
        final totalUnreadCount = _calculateUnreadCount(sortedConversations);
        print('✅ [ParticulierConversations] ${conversations.length} conversations, $totalUnreadCount non lues');
        
        if (mounted) {
          state = state.copyWith(
            conversations: sortedConversations,
            isLoading: false,
            error: null,
            unreadCount: totalUnreadCount,
          );
        }
      },
    );
  }

  Future<void> _loadConversationsQuietly() async {
    final result = await _repository.getParticulierConversations();
    
    result.fold(
      (failure) => print('⚠️ [ParticulierConversations] Erreur polling: ${failure.message}'),
      (conversations) {
        if (mounted) {
          final updatedConversations = _calculateAndUpdateUnreadCounts(conversations);
          final sortedConversations = _sortConversationsByLastMessage(updatedConversations);
          state = state.copyWith(
            conversations: sortedConversations,
            unreadCount: _calculateUnreadCount(sortedConversations),
          );
        }
      },
    );
  }

  // Trier les conversations par message le plus récent (même logique que vendeur)
  List<ParticulierConversation> _sortConversationsByLastMessage(List<ParticulierConversation> conversations) {
    final sortedConversations = [...conversations];
    sortedConversations.sort((a, b) {
      // Obtenir le dernier message de chaque conversation
      final lastMessageA = a.messages.isEmpty ? null : a.messages.last;
      final lastMessageB = b.messages.isEmpty ? null : b.messages.last;
      
      // Si une conversation n'a pas de messages, la mettre en bas
      if (lastMessageA == null && lastMessageB == null) return 0;
      if (lastMessageA == null) return 1;
      if (lastMessageB == null) return -1;
      
      // Trier par date du dernier message (plus récent en premier)
      return lastMessageB.createdAt.compareTo(lastMessageA.createdAt);
    });
    
    print('🔄 [ParticulierConversations] Conversations triées par dernier message');
    return sortedConversations;
  }

  List<ParticulierConversation> _calculateAndUpdateUnreadCounts(List<ParticulierConversation> conversations) {
    return conversations.map((conversation) {
      // Compter les messages non lus pour cette conversation (messages des autres utilisateurs)
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final unreadCount = conversation.messages
          .where((msg) => !msg.isRead && msg.senderId != currentUserId)
          .length;
      
      // Mettre à jour la conversation avec le bon unreadCount
      final updatedConversation = conversation.copyWith(unreadCount: unreadCount);
      
      if (unreadCount > 0) {
        print('💬 [ParticulierConversations] Conversation ${conversation.id}: $unreadCount non lus');
      }
      
      return updatedConversation;
    }).toList();
  }

  int _calculateUnreadCount(List<ParticulierConversation> conversations) {
    return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
  }


  Future<void> loadConversationDetails(String conversationId) async {
    print('📨 [ChatDetail] Chargement messages conversation: $conversationId');
    
    final result = await _repository.getParticulierConversationById(conversationId);
    
    result.fold(
      (failure) {
        print('❌ [ChatDetail] Erreur: ${failure.message}');
        if (mounted) {
          state = state.copyWith(error: failure.message);
        }
      },
      (conversation) {
        print('✅ [ChatDetail] Conversation chargée: ${conversation.messages.length} messages');
        
        // Mettre à jour la conversation dans la liste
        final updatedConversations = state.conversations.map((c) => 
          c.id == conversationId ? conversation : c
        ).toList();
        
        if (mounted) {
          state = state.copyWith(
            conversations: updatedConversations,
            error: null,
          );
        }
      },
    );
  }

  Future<void> sendMessage(String conversationId, String content) async {
    print('📤 [ChatDetail] Envoi message: $content');
    
    final result = await _repository.sendParticulierMessage(
      conversationId: conversationId,
      content: content,
    );
    
    result.fold(
      (failure) {
        print('❌ [ChatDetail] Erreur envoi: ${failure.message}');
        throw Exception(failure.message);
      },
      (_) {
        print('✅ [ChatDetail] Message envoyé');
        // Recharger la conversation pour voir le nouveau message
        loadConversationDetails(conversationId);
      },
    );
  }

  Future<void> markConversationAsRead(String conversationId) async {
    print('👀 [ParticulierConversations] Marquer comme lu: $conversationId');
    
    final result = await _repository.markParticulierConversationAsRead(conversationId);
    
    result.fold(
      (failure) => print('⚠️ [ParticulierConversations] Erreur marquage lu: ${failure.message}'),
      (_) {
        print('✅ [ParticulierConversations] Marqué comme lu - REFRESH IMMÉDIAT');
        // Refresh immédiat pour mettre à jour les compteurs dans la liste
        loadConversations();
      },
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    print('🗑️ [ParticulierConversations] Suppression conversation: $conversationId');
    
    // TODO: Implémenter la suppression côté repository
    // Pour l'instant, on simule en retirant de la liste locale
    final updatedConversations = state.conversations
        .where((c) => c.id != conversationId)
        .toList();
    
    if (mounted) {
      state = state.copyWith(conversations: updatedConversations);
    }
    
    print('✅ [ParticulierConversations] Conversation supprimée localement');
  }
  
  Future<void> blockConversation(String conversationId) async {
    print('🚫 [ParticulierConversations] Blocage vendeur: $conversationId');
    
    // TODO: Implémenter le blocage côté repository
    // Pour l'instant, on simule en retirant de la liste locale
    final updatedConversations = state.conversations
        .where((c) => c.id != conversationId)
        .toList();
    
    if (mounted) {
      state = state.copyWith(conversations: updatedConversations);
    }
    
    print('✅ [ParticulierConversations] Vendeur bloqué localement');
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _isPollingActive = false;
    _realtimeService.dispose();
    super.dispose();
  }
}

final particulierConversationsControllerProvider = 
    StateNotifierProvider<ParticulierConversationsController, ParticulierConversationsState>(
  (ref) {
    final repository = ref.read(partRequestRepositoryProvider);
    final realtimeService = ref.read(realtimeServiceProvider);
    
    return ParticulierConversationsController(
      repository: repository,
      realtimeService: realtimeService,
    );
  },
);

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});