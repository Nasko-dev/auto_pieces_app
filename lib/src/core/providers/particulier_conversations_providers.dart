import 'dart:async';
import 'package:flutter/foundation.dart';
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
  const ParticulierConversationsState._();

  const factory ParticulierConversationsState({
    @Default([]) List<ParticulierConversation> conversations,
    @Default(false) bool isLoading,
    String? error,
    String? activeConversationId,
  }) = _ParticulierConversationsState;

  int get unreadCount => conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
}

class ParticulierConversationsController extends StateNotifier<ParticulierConversationsState> {
  final PartRequestRepository _repository;
  final RealtimeService _realtimeService;
  Timer? _pollingTimer;
  bool _isPollingActive = false;

  bool _isRealtimeInitialized = false;

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
    _realtimeService.startSubscriptions();
  }
  
  // Abonnement global aux messages - même structure que le vendeur
  void initializeRealtime(String userId) async {
    if (_isRealtimeInitialized) {
      return;
    }

    _isRealtimeInitialized = true;
    _startIntelligentPolling();
    _subscribeToGlobalMessages(userId);
  }

  // S'abonner globalement aux messages - exactement comme le vendeur
  void _subscribeToGlobalMessages(String userId) async {
    
    // Créer un channel pour écouter TOUS les messages où l'utilisateur est impliqué
    final channel = Supabase.instance.client
        .channel('global_particulier_messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            _handleGlobalNewMessage(payload.newRecord, userId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'conversations',
          callback: (payload) {
            // Refresh quand une conversation est mise à jour (ex: unread_count)
            loadConversations();
          },
        );
    
    channel.subscribe();
  }

  // ✅ DB-BASED: Gérer un nouveau message reçu - incrémenter compteur DB
  void _handleGlobalNewMessage(dynamic messageData, String userId) async {
    final conversationId = messageData['conversation_id'] as String?;
    final senderId = messageData['sender_id'] as String?;
    final senderType = messageData['sender_type'] as String?;

    if (conversationId == null || senderId == null || senderType == null) return;


    // ✅ CRITICAL: Vérifier que ce n'est pas notre propre message AVANT tout traitement
    if (senderId == userId) {
      return;
    }

    // ✅ DB-BASED: Déterminer si ce message nous est destiné selon notre rôle dans la conversation
    try {
      // Utiliser la logique intelligente - tous les messages non-propres peuvent nous être destinés
      if (state.activeConversationId == conversationId) {
        // Marquer le message comme lu immédiatement si la conversation est ouverte
        _markConversationAsReadInDB(conversationId);
      } else {
        _incrementUnreadCountForUserOnly(conversationId);
      }
    } catch (e) {
      // En cas d'erreur, ne rien faire pour éviter les incrémentations incorrectes
    }
  }

  void _startIntelligentPolling() {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadConversationsQuietly();
      }
    });
  }

  Future<void> loadConversations() async {
    
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.getParticulierConversations();
    
    result.fold(
      (failure) {
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        }
      },
      (conversations) {

        if (mounted) {
          state = state.copyWith(
            conversations: conversations,
            isLoading: false,
            error: null,
          );
        }
      },
    );
  }

  Future<void> _loadConversationsQuietly() async {
    final result = await _repository.getParticulierConversations();
    
    result.fold(
      (failure) => null,
      (conversations) {
        if (mounted) {
          state = state.copyWith(
            conversations: conversations,
          );
        }
      },
    );
  }


  Future<void> loadConversationDetails(String conversationId) async {
    
    final result = await _repository.getParticulierConversationById(conversationId);
    
    result.fold(
      (failure) {
        if (mounted) {
          state = state.copyWith(error: failure.message);
        }
      },
      (conversation) {
        
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
    
    final result = await _repository.sendParticulierMessage(
      conversationId: conversationId,
      content: content,
    );
    
    result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (_) {
        // Recharger la conversation pour voir le nouveau message
        loadConversationDetails(conversationId);
      },
    );
  }

  // ✅ DB-BASED: Marquer conversation comme active et remettre compteur DB à 0
  void markConversationAsRead(String conversationId) {

    // Marquer en DB
    _markConversationAsReadInDB(conversationId);

    // Marquer comme conversation active
    state = state.copyWith(activeConversationId: conversationId);

  }


  void _incrementUnreadCountForUserOnly(String conversationId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await _repository.incrementUnreadCountForUser(
        conversationId: conversationId,
      );
      loadConversations();
    } catch (e) {
      // Ignorer les erreurs d'incrémentation pour éviter de bloquer l'UI
    }
  }

  void _markConversationAsReadInDB(String conversationId) async {
    try {
      await _repository.markParticulierMessagesAsRead(
        conversationId: conversationId,
      );
      // Refresh pour récupérer le nouveau compteur
      loadConversations();
    } catch (e) {
      // Ignorer les erreurs de lecture pour éviter de bloquer l'UI
    }
  }

  // ✅ SIMPLE: Désactiver la conversation active
  void setConversationInactive() {
    // ✅ SIMPLE: Éviter setState during build en différant la mise à jour
    Future.microtask(() {
      state = state.copyWith(activeConversationId: null);
    });
  }

  Future<void> deleteConversation(String conversationId) async {
    
    // TODO: Implémenter la suppression côté repository
    // Pour l'instant, on simule en retirant de la liste locale
    final updatedConversations = state.conversations
        .where((c) => c.id != conversationId)
        .toList();
    
    if (mounted) {
      state = state.copyWith(conversations: updatedConversations);
    }
    
  }
  
  Future<void> blockConversation(String conversationId) async {
    
    // TODO: Implémenter le blocage côté repository
    // Pour l'instant, on simule en retirant de la liste locale
    final updatedConversations = state.conversations
        .where((c) => c.id != conversationId)
        .toList();
    
    if (mounted) {
      state = state.copyWith(conversations: updatedConversations);
    }
    
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