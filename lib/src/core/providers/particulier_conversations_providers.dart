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
    // ✅ SIMPLE: Compteur local par conversation
    @Default({}) Map<String, int> localUnreadCounts,
    // ✅ SIMPLE: Conversation actuellement ouverte
    String? activeConversationId,
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

  // ✅ SIMPLE: Gérer un nouveau message reçu - incrémenter compteur local
  void _handleGlobalNewMessage(dynamic messageData, String userId) async {
    final conversationId = messageData['conversation_id'] as String?;
    final senderId = messageData['sender_id'] as String?;
    final senderType = messageData['sender_type'] as String?;

    if (conversationId == null || senderId == null || senderType == null) return;

    print('🎉 [ParticulierConversations] *** NOUVEAU MESSAGE REÇU *** ');
    print('🔍 [ParticulierConversations] Conversation: $conversationId, Sender: $senderId, Type: $senderType');

    // ✅ SIMPLE: Si c'est un message du vendeur, incrémenter compteur local SEULEMENT si pas dans la conversation
    if (senderType == 'seller') {
      if (state.activeConversationId == conversationId) {
        print('👀 [ParticulierConversations] Message reçu dans conversation active → compteur reste à 0');
      } else {
        print('🔥 [ParticulierConversations] Message du vendeur → +1 compteur local');

        final currentCount = state.localUnreadCounts[conversationId] ?? 0;
        final newCounts = Map<String, int>.from(state.localUnreadCounts);
        newCounts[conversationId] = currentCount + 1;

        // ✅ SIMPLE: Éviter setState during build en différant la mise à jour
        Future.microtask(() {
          state = state.copyWith(
            localUnreadCounts: newCounts,
            unreadCount: newCounts.values.fold(0, (sum, count) => sum + count),
          );
        });

        print('📊 [ParticulierConversations] Nouveau compteur conv $conversationId: ${newCounts[conversationId]}');
      }
    } else {
      print('📤 [ParticulierConversations] Notre propre message, pas de compteur');
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
        print('✅ [ParticulierConversations] ${conversations.length} conversations chargées');

        if (mounted) {
          state = state.copyWith(
            conversations: conversations,
            isLoading: false,
            error: null,
            // unreadCount reste basé sur localUnreadCounts
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
          state = state.copyWith(
            conversations: conversations,
            // unreadCount reste basé sur localUnreadCounts
          );
        }
      },
    );
  }


  // ✅ SIMPLE: Pas de calcul complexe, on utilise juste les compteurs locaux


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

  // ✅ SIMPLE: Marquer conversation comme active et remettre compteur à 0
  void markConversationAsRead(String conversationId) {
    print('👀 [ParticulierConversations] Ouverture conversation: $conversationId → compteur = 0 + active');

    final newCounts = Map<String, int>.from(state.localUnreadCounts);
    newCounts[conversationId] = 0;

    state = state.copyWith(
      localUnreadCounts: newCounts,
      unreadCount: newCounts.values.fold(0, (sum, count) => sum + count),
      activeConversationId: conversationId, // ✅ Définir comme conversation active
    );

    print('📊 [ParticulierConversations] Conversation $conversationId maintenant active');
  }

  // ✅ SIMPLE: Désactiver la conversation active
  void setConversationInactive() {
    print('🚪 [ParticulierConversations] Aucune conversation active');
    // ✅ SIMPLE: Éviter setState during build en différant la mise à jour
    Future.microtask(() {
      state = state.copyWith(activeConversationId: null);
    });
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

  // ✅ SIMPLE: Plus besoin de recalcul forcé, on utilise les compteurs locaux

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