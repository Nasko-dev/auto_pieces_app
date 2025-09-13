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
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;

  ParticulierConversationsController({
    required PartRequestRepository repository,
    required RealtimeService realtimeService,
  }) : _repository = repository,
       _realtimeService = realtimeService,
       super(const ParticulierConversationsState()) {
    _initializeRealtimeSubscriptions();
    _startIntelligentPolling();
  }

  void _initializeRealtimeSubscriptions() {
    print('🔔 [ParticulierConversations] Initialisation du temps réel');
    _realtimeService.startSubscriptions();
  }
  
  void initializeRealtime(String userId) {
    print('📡 [ParticulierConversations] Initialisation realtime pour particulier: $userId');
    
    // Écouter les nouveaux messages globalement
    _messageSubscription = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final latestMessage = data.last;
            print('🎉 [ParticulierConversations] *** NOUVEAU MESSAGE DÉTECTÉ - REFRESH AUTOMATIQUE ***');
            print('📨 Données: ${latestMessage.toString()}');
            
            // Refresh immédiat des conversations
            loadConversations();
          }
        });
    
    print('✅ [ParticulierConversations] Subscription realtime active');
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
        final totalUnreadCount = _calculateUnreadCount(updatedConversations);
        print('✅ [ParticulierConversations] ${conversations.length} conversations, $totalUnreadCount non lues');
        
        if (mounted) {
          state = state.copyWith(
            conversations: updatedConversations,
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
          state = state.copyWith(
            conversations: updatedConversations,
            unreadCount: _calculateUnreadCount(updatedConversations),
          );
        }
      },
    );
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
    _messageSubscription?.cancel();
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