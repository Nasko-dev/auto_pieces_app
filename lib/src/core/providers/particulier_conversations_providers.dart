import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/realtime_service.dart';
import '../../features/parts/domain/repositories/part_request_repository.dart';
import '../../features/parts/domain/entities/particulier_conversation.dart';
import '../../features/parts/domain/services/particulier_conversation_grouping_service.dart';
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
    @Default(0) int demandesCount, // Count rapide des demandes
    @Default(0) int annoncesCount, // Count rapide des annonces
    @Default(false) bool isLoadingAnnonces, // Chargement en cours des annonces
    DateTime? lastLoadedAt, // Timestamp du dernier chargement pour cache intelligent
  }) = _ParticulierConversationsState;

  int get unreadCount =>
      conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

  // ✅ CACHE: Vérifier si les données sont encore fraîches (< 5 minutes)
  bool get isFresh {
    if (lastLoadedAt == null) return false;
    final age = DateTime.now().difference(lastLoadedAt!);
    return age.inMinutes < 5;
  }

  // ✅ CACHE: Vérifier si on doit recharger
  bool get shouldReload => conversations.isEmpty || !isFresh;
}

class ParticulierConversationsController
    extends StateNotifier<ParticulierConversationsState> {
  final PartRequestRepository _repository;
  final RealtimeService _realtimeService;
  Timer? _pollingTimer;
  bool _isPollingActive = false;

  bool _isRealtimeInitialized = false;

  ParticulierConversationsController({
    required PartRequestRepository repository,
    required RealtimeService realtimeService,
  })  : _repository = repository,
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
            // ✅ OPTIMISATION: Mettre à jour seulement la conversation concernée
            final conversationId = payload.newRecord['id'] as String?;
            if (conversationId != null) {
              _loadSingleConversationQuietly(conversationId);
            }
          },
        );

    channel.subscribe();
  }

  // ✅ DB-BASED: Gérer un nouveau message reçu - incrémenter compteur DB
  void _handleGlobalNewMessage(dynamic messageData, String userId) async {
    final conversationId = messageData['conversation_id'] as String?;
    final senderId = messageData['sender_id'] as String?;
    final senderType = messageData['sender_type'] as String?;

    if (conversationId == null || senderId == null || senderType == null) {
      return;
    }

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

  // ✅ OPTIMISATION OPTION C: Charger d'abord les counts, puis les données
  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);

    // 1. Charger rapidement les counts pour savoir quels onglets afficher
    final countsResult = await _repository.getConversationsCounts();

    await countsResult.fold(
      (failure) async {
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        }
      },
      (counts) async {
        if (mounted) {
          // Mettre à jour les counts immédiatement
          state = state.copyWith(
            demandesCount: counts['demandes'] ?? 0,
            annoncesCount: counts['annonces'] ?? 0,
          );

          // 2. Charger les vraies données des demandes en priorité
          final demandesResult = await _repository.getParticulierConversations(
            filterType: 'demandes',
          );

          demandesResult.fold(
            (failure) {
              if (mounted) {
                state = state.copyWith(
                  isLoading: false,
                  error: failure.message,
                );
              }
            },
            (demandes) {
              if (mounted) {
                state = state.copyWith(
                  conversations: demandes,
                  isLoading: false,
                  error: null,
                  lastLoadedAt: DateTime.now(), // ✅ CACHE: Timestamp du chargement
                );

                // 3. Précharger les "Annonces" après 2 secondes si elles existent ET pas déjà chargées
                final annoncesCount = counts['annonces'] ?? 0;
                // Vérifier dans l'état actuel combien d'annonces on a déjà
                final currentAnnoncesLoaded = state.conversations.where((c) => !c.isRequester).length;

                debugPrint('📊 [Preload] Annonces count: $annoncesCount, déjà chargées: $currentAnnoncesLoaded');

                if (annoncesCount > 0 && currentAnnoncesLoaded == 0) {
                  // Précharger seulement si aucune annonce n'est encore chargée
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      debugPrint('🔄 [Preload] Lancement préchargement annonces');
                      _preloadAnnonces(demandes);
                    }
                  });
                } else {
                  debugPrint('⏭️ [Preload] Skip préchargement, annonces déjà présentes');
                }
              }
            },
          );
        }
      },
    );
  }

  // ✅ OPTIMISATION: Précharger les annonces en arrière-plan
  Future<void> _preloadAnnonces(List<ParticulierConversation> demandes) async {
    if (mounted) {
      state = state.copyWith(isLoadingAnnonces: true);
    }

    final annoncesResult = await _repository.getParticulierConversations(
      filterType: 'annonces',
    );

    annoncesResult.fold(
      (failure) {
        if (mounted) {
          state = state.copyWith(isLoadingAnnonces: false);
        }
      },
      (annonces) {
        if (mounted) {
          // Fusionner demandes + annonces
          final allConversations = [...demandes, ...annonces];
          state = state.copyWith(
            conversations: allConversations,
            isLoadingAnnonces: false,
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

  // ✅ OPTIMISATION: Charger seulement une conversation spécifique
  Future<void> _loadSingleConversationQuietly(String conversationId) async {
    try {
      final result = await _repository.getParticulierConversationById(conversationId);

      result.fold(
        (failure) => null,
        (updatedConversation) {
          if (mounted) {
            // Mettre à jour seulement cette conversation dans la liste
            final updatedList = state.conversations.map((conv) {
              return conv.id == conversationId ? updatedConversation : conv;
            }).toList();

            state = state.copyWith(conversations: updatedList);
          }
        },
      );
    } catch (e) {
      // Ignorer les erreurs pour éviter de bloquer le realtime
    }
  }

  Future<void> loadConversationDetails(String conversationId) async {
    final result =
        await _repository.getParticulierConversationById(conversationId);

    result.fold(
      (failure) {
        if (mounted) {
          state = state.copyWith(error: failure.message);
        }
      },
      (conversation) {
        // Mettre à jour la conversation dans la liste
        final updatedConversations = state.conversations
            .map((c) => c.id == conversationId ? conversation : c)
            .toList();

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
      // ✅ OPTIMISATION: Mettre à jour seulement cette conversation
      _loadSingleConversationQuietly(conversationId);
    } catch (e) {
      // Ignorer les erreurs d'incrémentation pour éviter de bloquer l'UI
    }
  }

  void _markConversationAsReadInDB(String conversationId) async {
    try {
      await _repository.markParticulierMessagesAsRead(
        conversationId: conversationId,
      );
      // ✅ OPTIMISATION: Mettre à jour seulement cette conversation
      _loadSingleConversationQuietly(conversationId);
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
    final updatedConversations =
        state.conversations.where((c) => c.id != conversationId).toList();

    if (mounted) {
      state = state.copyWith(conversations: updatedConversations);
    }
  }

  Future<void> blockConversation(String conversationId) async {
    // TODO: Implémenter le blocage côté repository
    // Pour l'instant, on simule en retirant de la liste locale
    final updatedConversations =
        state.conversations.where((c) => c.id != conversationId).toList();

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

final particulierConversationsControllerProvider = StateNotifierProvider<
    ParticulierConversationsController, ParticulierConversationsState>(
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

// Provider pour le service de groupement
final particulierConversationGroupingServiceProvider = Provider((ref) {
  return ParticulierConversationGroupingService();
});

// Provider pour les groupes de conversations (groupés par véhicule)
final particulierConversationGroupsProvider = Provider((ref) {
  final conversationsState =
      ref.watch(particulierConversationsControllerProvider);
  final groupingService =
      ref.watch(particulierConversationGroupingServiceProvider);

  return groupingService.groupConversations(conversationsState.conversations);
});

// Provider pour le compteur de messages non lus d'une conversation spécifique
final particulierConversationUnreadCountProvider =
    Provider.family<int, String>((ref, conversationId) {
  final conversationsState =
      ref.watch(particulierConversationsControllerProvider);

  try {
    final conversation = conversationsState.conversations.firstWhere(
      (conv) => conv.id == conversationId,
    );
    return conversation.unreadCount;
  } catch (e) {
    // Si la conversation n'est pas trouvée, retourner 0
    return 0;
  }
});

// Provider pour les conversations "Demandes" (isRequester = true)
final demandesConversationsProvider = Provider((ref) {
  final conversationsState =
      ref.watch(particulierConversationsControllerProvider);

  return conversationsState.conversations
      .where((conv) => conv.isRequester)
      .toList();
});

// Provider pour les conversations "Annonces" (isRequester = false)
final annoncesConversationsProvider = Provider((ref) {
  final conversationsState =
      ref.watch(particulierConversationsControllerProvider);

  return conversationsState.conversations
      .where((conv) => !conv.isRequester)
      .toList();
});

// Provider pour les groupes "Demandes"
final demandesConversationGroupsProvider = Provider((ref) {
  final demandesConversations = ref.watch(demandesConversationsProvider);
  final groupingService =
      ref.watch(particulierConversationGroupingServiceProvider);

  return groupingService.groupConversations(demandesConversations);
});

// Provider pour les groupes "Annonces"
final annoncesConversationGroupsProvider = Provider((ref) {
  final annoncesConversations = ref.watch(annoncesConversationsProvider);
  final groupingService =
      ref.watch(particulierConversationGroupingServiceProvider);

  return groupingService.groupConversations(annoncesConversations);
});
