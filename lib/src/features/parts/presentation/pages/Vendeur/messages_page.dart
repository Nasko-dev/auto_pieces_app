import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/conversations_providers.dart';
import '../../widgets/conversation_group_card.dart';
import '../../../domain/services/conversation_grouping_service.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/conversation_group.dart';

class SellerMessagesPage extends ConsumerStatefulWidget {
  const SellerMessagesPage({super.key});

  @override
  ConsumerState<SellerMessagesPage> createState() => _SellerMessagesPageState();
}

class _SellerMessagesPageState extends ConsumerState<SellerMessagesPage> {

  @override
  void initState() {
    super.initState();
    // Charger les conversations du vendeur depuis Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(conversationsControllerProvider.notifier);
      controller.loadConversations();
      
      // Initialiser le realtime pour actualisation automatique
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        controller.initializeRealtime(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser les groupes de conversations au lieu des conversations individuelles
    final conversationGroups = ref.watch(conversationGroupsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(conversationsErrorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _buildAppBar(),
      body: _buildBody(conversationGroups, isLoading, error),
    );
  }

  Widget _buildBody(List<ConversationGroup> conversationGroups, bool isLoading, String? error) {
    if (isLoading && conversationGroups.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E66F5)),
        ),
      );
    }

    if (error != null && conversationGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $error'),
          ],
        ),
      );
    }

    if (conversationGroups.isEmpty) {
      return const Center(
        child: Text('Aucune conversation'),
      );
    }


    // Utiliser RefreshIndicator pour permettre l'actualisation manuelle
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(conversationsControllerProvider.notifier).loadConversations();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: conversationGroups.length,
        itemBuilder: (context, index) {
          final group = conversationGroups[index];

          return ConversationGroupCard(
            group: group,
            onConversationTap: (conversationId) {
              context.push('/seller/conversation/$conversationId');
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final totalUnreadCount = ref.watch(totalUnreadCountProvider);
    
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Messages clients',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 0.2,
            ),
          ),
          if (totalUnreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                totalUnreadCount > 99 ? '99+' : '$totalUnreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: const Color(0xFF1E66F5),
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            ref.read(conversationsControllerProvider.notifier).loadConversations();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showDeleteDialog(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette conversation ? '
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(conversationsControllerProvider.notifier)
                  .deleteConversation(conversationId);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation supprimée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquer le client'),
        content: const Text(
          'Êtes-vous sûr de vouloir bloquer ce client ? '
          'Vous ne recevrez plus de messages de sa part.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(conversationsControllerProvider.notifier)
                  .blockConversation(conversationId);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Client bloqué'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Bloquer'),
          ),
        ],
      ),
    );
  }

}

