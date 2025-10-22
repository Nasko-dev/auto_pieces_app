import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/providers/particulier_conversations_providers.dart';
import '../../../../../core/services/device_service.dart';
import '../../../../../shared/presentation/widgets/loading_widget.dart';
import '../../../../../shared/presentation/widgets/app_header.dart';
import '../../../../../shared/presentation/widgets/app_menu.dart';
import '../../../../../shared/presentation/widgets/unread_filter_chip.dart'
    show ConversationFilterChips;
import '../../widgets/particulier/particulier_conversation_group_card.dart';

class ConversationsListPage extends ConsumerStatefulWidget {
  const ConversationsListPage({super.key});

  @override
  ConsumerState<ConversationsListPage> createState() =>
      _ConversationsListPageState();
}

class _ConversationsListPageState extends ConsumerState<ConversationsListPage>
    with SingleTickerProviderStateMixin {
  bool _showOnlyUnread = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Charger les conversations au démarrage et initialiser le realtime
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          ref.read(particulierConversationsControllerProvider.notifier);
      controller.loadConversations();

      // Initialiser le realtime avec les vrais IDs particulier (pas auth ID)
      _initializeRealtimeWithCorrectIds(controller);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeRealtimeWithCorrectIds(dynamic controller) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceService = DeviceService(prefs);
      final deviceId = await deviceService.getDeviceId();

      // Récupérer les vrais IDs particulier
      final allParticuliersWithDevice = await Supabase.instance.client
          .from('particuliers')
          .select('id')
          .eq('device_id', deviceId);

      final allUserIds =
          allParticuliersWithDevice.map((p) => p['id'] as String).toList();

      if (allUserIds.isNotEmpty) {
        final primaryUserId = allUserIds.first;
        controller.initializeRealtime(primaryUserId);
      }

      // Fallback vers auth ID si aucun trouvé
      if (allUserIds.isEmpty) {
        final authUserId = Supabase.instance.client.auth.currentUser?.id;
        if (authUserId != null) {
          controller.initializeRealtime(authUserId);
        }
      }
    } catch (e) {
      // Fallback vers auth ID
      final authUserId = Supabase.instance.client.auth.currentUser?.id;
      if (authUserId != null) {
        controller.initializeRealtime(authUserId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(particulierConversationsControllerProvider);
    final demandesGroups = ref.watch(demandesConversationGroupsProvider);
    final annoncesGroups = ref.watch(annoncesConversationGroupsProvider);
    final isLoading = state.isLoading;
    final error = state.error;

    // ✅ OPTIMISATION: Afficher onglets basés sur les counts au lieu des données chargées
    final hasDemandes = state.demandesCount > 0;
    final hasAnnonces = state.annoncesCount > 0;
    final showTabs = hasDemandes && hasAnnonces;

    // Calculer le nombre total de messages non lus
    final allGroups = ref.watch(particulierConversationGroupsProvider);
    final totalUnreadCount = allGroups.fold<int>(
      0,
      (sum, group) => sum + group.totalUnreadCount,
    );

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Mes Conversations',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref
                      .read(particulierConversationsControllerProvider.notifier)
                      .loadConversations();
                },
              ),
              const AppMenu(),
            ],
          ),
          // TabBar conditionnelle (seulement si les 2 types existent)
          if (showTabs)
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Demandes'),
                Tab(text: 'Annonces'),
              ],
            ),
          // Widget de filtres (Tous / Non lus) - EN DESSOUS des onglets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ConversationFilterChips(
              showOnlyUnread: _showOnlyUnread,
              onFilterChanged: (showUnread) {
                setState(() {
                  _showOnlyUnread = showUnread;
                });
              },
              unreadCount: totalUnreadCount,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(particulierConversationsControllerProvider.notifier)
                    .loadConversations();
              },
              child: showTabs
                  ? _buildTabBarView(
                      demandesGroups, annoncesGroups, isLoading, error)
                  : _buildSingleList(
                      hasDemandes ? demandesGroups : annoncesGroups,
                      isLoading,
                      error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView(
      List demandesGroups, List annoncesGroups, bool isLoading, String? error) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Onglet Demandes
        _buildConversationList(_filterByUnread(demandesGroups), isLoading, error),
        // Onglet Annonces
        _buildConversationList(_filterByUnread(annoncesGroups), isLoading, error),
      ],
    );
  }

  Widget _buildSingleList(
      List conversationGroups, bool isLoading, String? error) {
    return _buildConversationList(
        _filterByUnread(conversationGroups), isLoading, error);
  }

  List _filterByUnread(List groups) {
    return _showOnlyUnread
        ? groups.where((group) => group.hasUnreadMessages).toList()
        : groups;
  }

  Widget _buildConversationList(
      List conversationGroups, bool isLoading, String? error) {
    if (isLoading && conversationGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingWidget(),
            SizedBox(height: 16),
            Text('Chargement de vos conversations...'),
          ],
        ),
      );
    }

    if (error != null && conversationGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(particulierConversationsControllerProvider.notifier)
                    .loadConversations();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (conversationGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucune conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vos conversations avec les vendeurs apparaîtront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: conversationGroups.length,
      itemBuilder: (context, index) {
        final group = conversationGroups[index];

        return ParticulierConversationGroupCard(
          group: group,
          onConversationTap: (conversationId) {
            context.push('/conversations/$conversationId');
          },
        );
      },
    );
  }
}
