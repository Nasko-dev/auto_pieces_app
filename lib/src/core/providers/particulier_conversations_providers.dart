import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
    _startIntelligentPolling();
  }

  void _initializeRealtimeSubscriptions() {
    print('🔔 [ParticulierConversations] Initialisation du polling intelligent');
    _realtimeService.startSubscriptions();
  }

  void _startIntelligentPolling() {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    print('⏰ [ParticulierConversations] Polling de fond activé (10s)');
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
        
        // Compter les messages non lus
        final unreadCount = conversations.fold<int>(0, (sum, conv) => 
          sum + conv.messages.where((msg) => !msg.isFromParticulier && !msg.isRead).length
        );
        
        print('🔔 [ParticulierConversations] $unreadCount non lues');
        
        // Débugger les conversations pour voir leur structure
        _debugConversations(conversations);
        
        if (mounted) {
          state = state.copyWith(
            conversations: conversations,
            isLoading: false,
            error: null,
            unreadCount: unreadCount,
          );
          
          print('🎯 [UI] Affichage de ${conversations.length} conversations particulier');
          
          // Grouper par véhicule pour débug
          final vehicleGroups = <String, List<ParticulierConversation>>{};
          for (final conv in conversations) {
            final key = conv.partRequest.vehiclePlate ?? 'Sans plaque';
            vehicleGroups[key] = (vehicleGroups[key] ?? [])..add(conv);
          }
          
          print('📊 [UI] ${vehicleGroups.keys.length} groupes de véhicules');
        }
      },
    );
  }

  Future<void> _loadConversationsQuietly() async {
    final result = await _repository.getParticulierConversations();
    
    result.fold(
      (failure) {
        // Log erreur silencieusement
        print('⚠️ [ParticulierConversations] Erreur polling: ${failure.message}');
      },
      (conversations) {
        if (mounted) {
          final unreadCount = conversations.fold<int>(0, (sum, conv) => 
            sum + conv.messages.where((msg) => !msg.isFromParticulier && !msg.isRead).length
          );
          
          state = state.copyWith(
            conversations: conversations,
            unreadCount: unreadCount,
          );
        }
      },
    );
  }

  void _debugConversations(List<ParticulierConversation> conversations) {
    print('📝 [ParticulierConversations] Debug des conversations:');
    for (int i = 0; i < conversations.length; i++) {
      final conv = conversations[i];
      print('  - Conv $i: sellerName=${conv.sellerName}, messages=${conv.messages.length}');
      for (int j = 0; j < conv.messages.length && j < 20; j++) {
        final msg = conv.messages[j];
        print('    Msg $j: isFromParticulier=${msg.isFromParticulier}, content="${msg.content}"');
      }
    }
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
    print('👀 [ChatDetail] Marquer comme lu: $conversationId');
    
    final result = await _repository.markParticulierConversationAsRead(conversationId);
    
    result.fold(
      (failure) => print('⚠️ [ChatDetail] Erreur marquage lu: ${failure.message}'),
      (_) {
        print('✅ [ChatDetail] Marqué comme lu');
        // Recharger pour mettre à jour les compteurs
        loadConversationDetails(conversationId);
      },
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    print('🗑️ [ChatDetail] Suppression conversation: $conversationId');
    
    // TODO: Implémenter la suppression côté repository
    // Pour l'instant, on simule en retirant de la liste locale
    final updatedConversations = state.conversations
        .where((c) => c.id != conversationId)
        .toList();
    
    if (mounted) {
      state = state.copyWith(conversations: updatedConversations);
    }
    
    print('✅ [ChatDetail] Conversation supprimée localement');
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