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
            _handleGlobalNewMessage(payload.newRecord, userId);
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
    
    channel.subscribe();
    print('✅ [ParticulierConversations] Channel global messages abonné');
  }

  // Gérer un nouveau message reçu globalement - même logique que le vendeur
  void _handleGlobalNewMessage(dynamic messageData, String userId) async {
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
        final processedConversations = _calculateAndUpdateUnreadCounts(conversations);
        final totalUnreadCount = _calculateUnreadCount(processedConversations);
        print('✅ [ParticulierConversations] ${conversations.length} conversations, $totalUnreadCount non lues');
        
        if (mounted) {
          state = state.copyWith(
            conversations: processedConversations,
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
          final processedConversations = _calculateAndUpdateUnreadCounts(conversations);
          state = state.copyWith(
            conversations: processedConversations,
            unreadCount: _calculateUnreadCount(processedConversations),
          );
        }
      },
    );
  }


  // Optimisation : calcul unread plus efficace
  List<ParticulierConversation> _calculateAndUpdateUnreadCounts(List<ParticulierConversation> conversations) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return conversations;
    
    return conversations.map((conversation) {
      // Calcul optimisé : éviter where().length pour de meilleures performances
      int unreadCount = 0;
      for (final msg in conversation.messages) {
        if (!msg.isRead && msg.senderId != currentUserId) {
          unreadCount++;
        }
      }
      
      // Seulement copier si le count a changé (éviter copyWith inutiles)
      if (conversation.unreadCount != unreadCount) {
        if (unreadCount > 0) {
          print('💬 [ParticulierConversations] Conversation ${conversation.id}: $unreadCount non lus');
        }
        return conversation.copyWith(unreadCount: unreadCount);
      }
      
      return conversation; // Pas de changement, retourner l'original
    }).toList();
  }

  // Optimisation : calcul total plus efficace (éviter fold si aucun unread)
  int _calculateUnreadCount(List<ParticulierConversation> conversations) {
    int total = 0;
    for (final conv in conversations) {
      if (conv.unreadCount > 0) total += conv.unreadCount;
    }
    return total;
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