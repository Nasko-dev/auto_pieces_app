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

class _ConversationsListPageState extends ConsumerState<ConversationsListPage> {
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    // Charger les conversations au démarrage et initialiser le realtime
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          ref.read(particulierConversationsControllerProvider.notifier);
      controller.loadConversations();

      // Initialiser le realtime avec les vrais IDs particulier (pas auth ID)
      _initializeRealtimeWithCorrectIds(controller);
    });
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
    final allConversationGroups =
        ref.watch(particulierConversationGroupsProvider);
    final isLoading = state.isLoading;
    final error = state.error;

    // Filtrer les groupes selon le filtre actif
    final conversationGroups = _showOnlyUnread
        ? allConversationGroups
            .where((group) => group.hasUnreadMessages)
            .toList()
        : allConversationGroups;

    // Calculer le nombre total de messages non lus
    final totalUnreadCount = allConversationGroups.fold<int>(
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
          // Widget de filtres (Tous / Non lus)
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
              child: _buildBody(conversationGroups, isLoading, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List conversationGroups, bool isLoading, String? error) {
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
