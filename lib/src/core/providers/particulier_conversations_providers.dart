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
    @Default(false) bool needsReload, // Flag pour forcer le rechargement après invalidation
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
  bool get shouldReload => conversations.isEmpty || !isFresh || needsReload;
}

class ParticulierConversationsController
    extends StateNotifier<ParticulierConversationsState> {
  final PartRequestRepository _repository;
  final RealtimeService _realtimeService;
  Timer? _pollingTimer;
  bool _isPollingActive = false;

  bool _isRealtimeInitialized = false;
  RealtimeChannel? _realtimeChannel; // ✅ FIX: Garder référence pour unsubscribe

  // ✅ FIX RACE CONDITION: Tracker les dernières incrémentations optimistes
  final Map<String, DateTime> _recentOptimisticIncrements = {};

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
  // ✅ FIX RACE CONDITION: Fonction synchrone pour éviter appels concurrents
  void initializeRealtime(String userId) {
    if (_isRealtimeInitialized) {
      return;
    }

    _isRealtimeInitialized = true;
    _startIntelligentPolling();
    _subscribeToGlobalMessages(userId);
  }

  // S'abonner globalement aux messages - exactement comme le vendeur
  void _subscribeToGlobalMessages(String userId) async {
    // ✅ FIX: Unsubscribe ancien channel si existe
    if (_realtimeChannel != null) {
      await Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }

    // Créer un channel pour écouter TOUS les messages où l'utilisateur est impliqué
    _realtimeChannel = Supabase.instance.client
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

    _realtimeChannel!.subscribe();
    debugPrint('📡 [Realtime] Channel subscribed: global_particulier_messages_$userId');
  }

  // ✅ DB-BASED: Gérer un nouveau message reçu - incrémenter compteur DB
  void _handleGlobalNewMessage(dynamic messageData, String userId) async {
    final conversationId = messageData['conversation_id'] as String?;
    final senderId = messageData['sender_id'] as String?;
    final senderType = messageData['sender_type'] as String?;

    debugPrint('🔔 [Provider] _handleGlobalNewMessage appelé');
    debugPrint('   conversationId: $conversationId');
    debugPrint('   senderId: $senderId');
    debugPrint('   userId: $userId');
    debugPrint('   activeConversationId: ${state.activeConversationId}');

    if (conversationId == null || senderId == null || senderType == null) {
      debugPrint('   ❌ Données manquantes - abandon');
      return;
    }

    // ✅ CRITICAL FIX: Vérifier que ce n'est pas notre propre message
    // Le senderId est l'auth ID, il faut comparer avec l'auth ID actuel
    final currentAuthId = Supabase.instance.client.auth.currentUser?.id;
    if (currentAuthId != null && senderId == currentAuthId) {
      debugPrint('   ❌ C\'est notre propre message (auth ID match) - ignoré');
      return;
    }

    // ✅ DB-BASED: Déterminer si ce message nous est destiné selon notre rôle dans la conversation
    try {
      // Utiliser la logique intelligente - tous les messages non-propres peuvent nous être destinés
      if (state.activeConversationId == conversationId) {
        // Marquer le message comme lu immédiatement si la conversation est ouverte
        debugPrint('   ✅ Conversation active → marquer comme lu');
        _markConversationAsReadInDB(conversationId);
      } else {
        debugPrint('   ✅ Conversation inactive → incrémenter compteur');
        _incrementUnreadCountForUserOnly(conversationId);
      }
    } catch (e) {
      // En cas d'erreur, logger pour debug
      debugPrint('   ❌ ERREUR dans _handleGlobalNewMessage: $e');
    }
  }

  // ✅ FIX: Rendre public pour permettre start/stop depuis provider
  void startPolling() {
    if (_isPollingActive) return;

    _isPollingActive = true;

    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadConversationsQuietly();
      }
    });

    debugPrint('🔄 [Polling] Démarré (toutes les 30s)');
  }

  // ✅ FIX: Arrêter le polling proprement
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPollingActive = false;
    debugPrint('⏸️ [Polling] Arrêté');
  }

  void _startIntelligentPolling() {
    startPolling();
  }

  // ✅ OPTIMISATION OPTION C: Charger d'abord les counts, puis les données
  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null, needsReload: false);

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
                // ✅ FIX: Vérifier AVANT de modifier le state si annonces déjà chargées
                final currentAnnoncesLoaded = state.conversations.where((c) => !c.isRequester).length;

                state = state.copyWith(
                  conversations: demandes,
                  isLoading: false,
                  error: null,
                  lastLoadedAt: DateTime.now(), // ✅ CACHE: Timestamp du chargement
                );

                // 3. Précharger les "Annonces" après 2 secondes si elles existent ET pas déjà chargées
                final annoncesCount = counts['annonces'] ?? 0;

                debugPrint('📊 [Preload] Annonces count: $annoncesCount, déjà chargées: $currentAnnoncesLoaded');

                if (annoncesCount > 0 && currentAnnoncesLoaded == 0) {
                  // ✅ FIX: Précharger seulement si aucune annonce n'était chargée dans l'état précédent
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
          // ✅ FIX: Merge intelligent pour préserver les unreadCount optimistes
          final mergedConversations = conversations.map((newConv) {
            // Vérifier si cette conversation a une protection active
            final lastIncrement = _recentOptimisticIncrements[newConv.id];
            final hasRecentIncrement = lastIncrement != null &&
                DateTime.now().difference(lastIncrement).inSeconds < 2;

            if (hasRecentIncrement) {
              // Trouver la conversation actuelle dans le state
              final currentConv = state.conversations.firstWhere(
                (c) => c.id == newConv.id,
                orElse: () => newConv,
              );

              debugPrint('🔄 [Polling Merge] ${newConv.id}: préserver unreadCount optimiste=${currentConv.unreadCount}');

              // Merger: prendre tout de la DB SAUF unreadCount
              return newConv.copyWith(
                unreadCount: currentConv.unreadCount,
                hasUnreadMessages: currentConv.hasUnreadMessages,
              );
            }

            // Pas de protection: prendre les données DB telles quelles
            return newConv;
          }).toList();

          state = state.copyWith(
            conversations: mergedConversations,
          );
        }
      },
    );
  }

  // ✅ OPTIMISATION: Charger seulement une conversation spécifique
  Future<void> _loadSingleConversationQuietly(String conversationId) async {
    try {
      // ✅ FIX RACE CONDITION: Vérifier si incrémentation optimiste en cours
      final lastIncrement = _recentOptimisticIncrements[conversationId];
      final hasRecentIncrement = lastIncrement != null &&
          DateTime.now().difference(lastIncrement).inSeconds < 2;

      if (hasRecentIncrement) {
        debugPrint('🔄 [_loadSingleConversationQuietly] Protection active - merge intelligent des données');
      } else if (lastIncrement != null) {
        // Nettoyer l'entrée expirée
        _recentOptimisticIncrements.remove(conversationId);
      }

      final result = await _repository.getParticulierConversationById(conversationId);

      result.fold(
        (failure) => null,
        (updatedConversation) {
          if (mounted) {
            // ✅ FIX: Merger intelligent si protection active
            ParticulierConversation finalConversation = updatedConversation;

            if (hasRecentIncrement) {
              // Préserver le unreadCount optimiste de la conversation actuelle
              final currentConv = state.conversations.firstWhere(
                (c) => c.id == conversationId,
                orElse: () => updatedConversation,
              );

              debugPrint('   🔀 Merge: DB unreadCount=${updatedConversation.unreadCount}, Local unreadCount=${currentConv.unreadCount}');
              debugPrint('   ✅ Conservation du unreadCount local (optimiste)');

              // Prendre toutes les données de la DB SAUF le unreadCount
              finalConversation = updatedConversation.copyWith(
                unreadCount: currentConv.unreadCount,
                hasUnreadMessages: currentConv.hasUnreadMessages,
              );
            }

            // Mettre à jour seulement cette conversation dans la liste
            final updatedList = state.conversations.map((conv) {
              return conv.id == conversationId ? finalConversation : conv;
            }).toList();

            state = state.copyWith(conversations: updatedList);
          }
        },
      );
    } catch (e) {
      // ✅ FIX: Logger les erreurs au lieu de les ignorer silencieusement
      debugPrint('❌ [_loadSingleConversationQuietly] Erreur: $e');
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
      debugPrint('📊 [Provider] _incrementUnreadCountForUserOnly appelé');
      debugPrint('   conversationId: $conversationId');

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('   ❌ userId est null - abandon');
        return;
      }

      // ✅ FIX: Déterminer le rôle et incrémenter le BON compteur
      // Trouver la conversation dans le state pour savoir si on est le demandeur ou le répondeur
      final conversationIndex = state.conversations.indexWhere((conv) => conv.id == conversationId);

      debugPrint('   conversationIndex: $conversationIndex');
      debugPrint('   Nombre total conversations: ${state.conversations.length}');

      if (conversationIndex == -1) {
        // ✅ FIX: Conversation pas trouvée → charger ET incrémenter pour ne pas perdre le message
        debugPrint('   ⚠️ Conversation pas en mémoire - chargement + incrémentation');

        // Charger la conversation pour déterminer le rôle et incrémenter le bon compteur
        final result = await _repository.getParticulierConversationById(conversationId);

        result.fold(
          (failure) {
            debugPrint('   ❌ Erreur chargement conversation: ${failure.message}');
          },
          (loadedConversation) async {
            debugPrint('   ✅ Conversation chargée: ${loadedConversation.sellerName}');
            debugPrint('   isRequester: ${loadedConversation.isRequester}');

            // Incrémenter le bon compteur en DB
            if (loadedConversation.isRequester) {
              debugPrint('   📤 Incrémentation DB: unread_count_for_user');
              await _repository.incrementUnreadCountForUser(conversationId: conversationId);
            } else {
              debugPrint('   📤 Incrémentation DB: unread_count_for_seller');
              await _repository.incrementUnreadCountForSeller(conversationId: conversationId);
            }

            // Ajouter la conversation à la liste avec compteur incrémenté
            final updatedConversation = loadedConversation.copyWith(
              unreadCount: loadedConversation.unreadCount + 1,
              hasUnreadMessages: true,
            );

            if (mounted) {
              final updatedList = List<ParticulierConversation>.from(state.conversations);
              updatedList.add(updatedConversation);
              state = state.copyWith(conversations: updatedList);
              debugPrint('   ✅ Conversation ajoutée à la liste avec unreadCount: ${updatedConversation.unreadCount}');

              // ✅ FIX RACE CONDITION: Protéger aussi cette incrémentation
              _recentOptimisticIncrements[conversationId] = DateTime.now();
              debugPrint('   🔒 [Race Protection] Incrémentation optimiste protégée pour 2s');
            }
          },
        );

        return;
      }

      final conversation = state.conversations[conversationIndex];
      debugPrint('   ✅ Conversation trouvée: ${conversation.sellerName}');
      debugPrint('   unreadCount actuel: ${conversation.unreadCount}');
      debugPrint('   isRequester: ${conversation.isRequester}');

      // ✅ OPTIMISATION CRITIQUE: Mise à jour locale OPTIMISTE du compteur
      // Incrémenter IMMÉDIATEMENT dans le state local pour que l'UI se mette à jour
      final updatedConversation = conversation.copyWith(
        unreadCount: conversation.unreadCount + 1,
        hasUnreadMessages: true,
      );

      final updatedList = List<ParticulierConversation>.from(state.conversations);
      updatedList[conversationIndex] = updatedConversation;

      if (mounted) {
        debugPrint('   ✅ MISE À JOUR STATE: unreadCount ${conversation.unreadCount} → ${updatedConversation.unreadCount}');
        state = state.copyWith(conversations: updatedList);

        // ✅ FIX RACE CONDITION: Enregistrer le timestamp de l'incrémentation optimiste
        _recentOptimisticIncrements[conversationId] = DateTime.now();
        debugPrint('   🔒 [Race Protection] Incrémentation optimiste protégée pour 2s');
      } else {
        debugPrint('   ❌ Provider not mounted - skip update');
        return;
      }

      // ✅ FIX: BACKGROUND avec rollback si erreur DB
      final dbIncrementFuture = conversation.isRequester
          ? _repository.incrementUnreadCountForUser(conversationId: conversationId)
          : _repository.incrementUnreadCountForSeller(conversationId: conversationId);

      dbIncrementFuture.then((result) {
        result.fold(
          (failure) {
            // ✅ ROLLBACK: Restaurer la valeur précédente si erreur DB
            debugPrint('   ❌ ERREUR DB increment - ROLLBACK: ${failure.message}');

            // Nettoyer la protection
            _recentOptimisticIncrements.remove(conversationId);

            if (mounted) {
              final rollbackList = List<ParticulierConversation>.from(state.conversations);
              final currentIndex = rollbackList.indexWhere((c) => c.id == conversationId);
              if (currentIndex != -1) {
                rollbackList[currentIndex] = conversation; // Restaurer valeur originale
                state = state.copyWith(conversations: rollbackList);
                debugPrint('   ✅ ROLLBACK effectué: unreadCount ${updatedConversation.unreadCount} → ${conversation.unreadCount}');
              }
            }
          },
          (_) {
            // Succès - nettoyer la protection puis recharger depuis DB pour synchroniser
            debugPrint('   ✅ Incrémentation DB réussie');

            // ✅ FIX RACE CONDITION: Nettoyer la protection avant de recharger
            _recentOptimisticIncrements.remove(conversationId);
            debugPrint('   🔓 [Race Protection] Protection levée, rechargement autorisé');

            _loadSingleConversationQuietly(conversationId);
          },
        );
      });
    } catch (e) {
      // Logger l'erreur au lieu de l'ignorer silencieusement
      debugPrint('   ❌ ERREUR dans _incrementUnreadCountForUserOnly: $e');
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
      // ✅ FIX: Logger les erreurs au lieu de les ignorer silencieusement
      debugPrint('❌ [_markConversationAsReadInDB] Erreur: $e');
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

  // ✅ RELOAD: Marquer qu'un rechargement est nécessaire (appelé après envoi de message)
  void markNeedsReload() {
    if (mounted) {
      state = state.copyWith(needsReload: true);
    }
  }

  @override
  void dispose() async {
    stopPolling(); // ✅ FIX: Utiliser la méthode propre

    // ✅ FIX: Unsubscribe du channel Realtime
    if (_realtimeChannel != null) {
      await Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
      debugPrint('📡 [Realtime] Channel unsubscribed');
    }

    // ✅ FIX: NE PAS disposer le RealtimeService singleton - il doit rester vivant
    // Le service gère lui-même ses ressources avec unsubscribe
    // _realtimeService.dispose(); // ❌ SUPPRIMÉ: casse le singleton

    super.dispose();
  }
}

// ✅ FIX: Utiliser autoDispose pour éviter fuites mémoire, avec gestion intelligente du polling
final particulierConversationsControllerProvider = StateNotifierProvider.autoDispose<
    ParticulierConversationsController, ParticulierConversationsState>(
  (ref) {
    final repository = ref.read(partRequestRepositoryProvider);
    final realtimeService = ref.read(realtimeServiceProvider);

    final controller = ParticulierConversationsController(
      repository: repository,
      realtimeService: realtimeService,
    );

    // ✅ FIX: Arrêter le polling quand plus de listeners actifs (économie batterie/data)
    ref.onCancel(() {
      debugPrint('📵 [Provider] Plus de listeners - arrêt polling');
      controller.stopPolling();
    });

    // ✅ FIX: Redémarrer le polling quand nouveaux listeners
    ref.onResume(() {
      debugPrint('📱 [Provider] Nouveaux listeners - redémarrage polling');
      controller.startPolling();
    });

    // ✅ FIX: Garder le provider en vie pour conserver le cache
    ref.keepAlive();

    return controller;
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
    // ✅ FIX: Logger + retourner 0 si conversation non trouvée
    debugPrint('⚠️ [particulierConversationUnreadCountProvider] Conversation $conversationId non trouvée');
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
