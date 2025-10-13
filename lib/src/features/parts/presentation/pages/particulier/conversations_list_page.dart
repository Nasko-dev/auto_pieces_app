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
import '../../widgets/conversation_item_widget.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/ios_dialog.dart';

class ConversationsListPage extends ConsumerStatefulWidget {
  const ConversationsListPage({super.key});

  @override
  ConsumerState<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends ConsumerState<ConversationsListPage> {
  @override
  void initState() {
    super.initState();
    // Charger les conversations au démarrage et initialiser le realtime
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(particulierConversationsControllerProvider.notifier);
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
          
      final allUserIds = allParticuliersWithDevice
          .map((p) => p['id'] as String)
          .toList();
          
      
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
    final conversations = state.conversations;
    final isLoading = state.isLoading;
    final error = state.error;


    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Mes Conversations',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(particulierConversationsControllerProvider.notifier).loadConversations();
                },
              ),
              const AppMenu(),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(particulierConversationsControllerProvider.notifier).loadConversations();
              },
              child: _buildBody(conversations, isLoading, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List conversations, bool isLoading, String? error) {
    if (isLoading && conversations.isEmpty) {
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

    if (error != null && conversations.isEmpty) {
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
                ref.read(particulierConversationsControllerProvider.notifier).loadConversations();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (conversations.isEmpty) {
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
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        
        return ConversationItemWidget(
          conversation: conversation,
          onTap: () {
            context.push('/conversations/${conversation.id}');
          },
          onDelete: () => _showDeleteDialog(conversation.id),
          onBlock: () => _showBlockDialog(conversation.id),
        );
      },
    );
  }

  void _showDeleteDialog(String conversationId) async {
    final result = await context.showDestructiveDialog(
      title: 'Supprimer la conversation',
      message: 'Êtes-vous sûr de vouloir supprimer cette conversation ? Cette action ne peut pas être annulée.',
      destructiveText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      ref.read(particulierConversationsControllerProvider.notifier)
          .deleteConversation(conversationId);

      if (mounted) {
        notificationService.success(context, 'Conversation supprimée');
      }
    }
  }

  void _showBlockDialog(String conversationId) async {
    final result = await context.showWarningDialog(
      title: 'Bloquer le vendeur',
      message: 'Êtes-vous sûr de vouloir bloquer ce vendeur ? Vous ne recevrez plus de messages de sa part.',
      confirmText: 'Bloquer',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      ref.read(particulierConversationsControllerProvider.notifier)
          .blockConversation(conversationId);

      if (mounted) {
        notificationService.warning(context, 'Vendeur bloqué');
      }
    }
  }
}