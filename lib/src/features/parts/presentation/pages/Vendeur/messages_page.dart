import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../shared/presentation/widgets/seller_header.dart';
import '../../providers/conversations_providers.dart';
import '../../widgets/conversation_group_card.dart';
import '../../../domain/entities/conversation_group.dart';
import '../../../../../core/theme/app_theme.dart';

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
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          const SellerHeader(title: 'Messages'),
          Expanded(
            child: _buildBody(conversationGroups, isLoading, error),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<ConversationGroup> conversationGroups, bool isLoading, String? error) {
    if (isLoading && conversationGroups.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      );
    }

    if (error != null && conversationGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
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

}
