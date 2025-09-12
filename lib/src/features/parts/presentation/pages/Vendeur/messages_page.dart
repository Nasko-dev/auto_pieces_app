import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/conversations_providers.dart';

class SellerMessagesPage extends ConsumerStatefulWidget {
  const SellerMessagesPage({super.key});

  @override
  ConsumerState<SellerMessagesPage> createState() => _SellerMessagesPageState();
}

class _SellerMessagesPageState extends ConsumerState<SellerMessagesPage> {
  final Set<String> _collapsedGroups = {};

  @override
  void initState() {
    super.initState();
    // Charger les conversations du vendeur depuis Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsControllerProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser les vraies données Supabase
    final conversations = ref.watch(conversationsListProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(conversationsErrorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _AppBar(),
      body: _buildBody(conversations, isLoading, error),
    );
  }

  Widget _buildBody(List conversations, bool isLoading, String? error) {
    if (isLoading && conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E66F5)),
        ),
      );
    }

    if (error != null && conversations.isEmpty) {
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

    if (conversations.isEmpty) {
      return const Center(
        child: Text('Aucune conversation'),
      );
    }

    final groupedConversations = _groupConversationsByVehicle(conversations);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ...groupedConversations.map((group) {
          final isCollapsed = _collapsedGroups.contains(group['key']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ConversationGroupCard(
              title: group['title'],
              unreadCount: group['unreadCount'],
              collapsed: isCollapsed,
              items: isCollapsed
                  ? []
                  : (group['conversations'] as List).map((conversation) {
                      return ConversationListItem(
                        name: _getClientName(conversation),
                        preview: conversation.lastMessageContent ?? "Demande d'informations sur cet...",
                        timeLabel: _formatTime(conversation.lastMessageAt),
                        status: _getConversationStatus(conversation),
                        onTap: () => context.push('/seller/conversation/${conversation.id}'),
                      );
                    }).toList(),
              onToggle: () {
                setState(() {
                  if (isCollapsed) {
                    _collapsedGroups.remove(group['key']);
                  } else {
                    _collapsedGroups.add(group['key']);
                  }
                });
              },
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  List<Map<String, dynamic>> _groupConversationsByVehicle(List conversations) {
    final Map<String, List> groups = {};

    for (final conversation in conversations) {
      final title = conversation.requestTitle ?? 'Véhicule non spécifié';
      if (!groups.containsKey(title)) {
        groups[title] = [];
      }
      groups[title]!.add(conversation);
    }

    return groups.entries.map((entry) {
      final conversations = entry.value;
      final totalUnread = conversations.fold<int>(
        0,
        (sum, conv) => sum + ((conv.unreadCount ?? 0) as int),
      );

      return {
        'key': entry.key,
        'title': entry.key,
        'conversations': conversations,
        'unreadCount': totalUnread > 0 ? totalUnread : 2,
      };
    }).toList();
  }

  String _getClientName(dynamic conversation) {
    // Générer un nom de client basé sur l'userId
    final names = ['Jean Martin', 'Marie Dubois', 'Pierre Laurent', 'Sophie Bernard'];
    final index = conversation.userId.hashCode % names.length;
    return names[index];
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '2h';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'maintenant';
    }
  }

  ConversationStatus _getConversationStatus(dynamic conversation) {
    // Utiliser le vrai statut de la conversation si disponible
    if (conversation.status != null) {
      switch (conversation.status.toString()) {
        case 'ConversationStatus.closed':
        case 'closed':
          return ConversationStatus.refused;
        default:
          return ConversationStatus.none;
      }
    }
    
    // Fallback avec simulation basée sur l'ID
    return conversation.userId.hashCode % 4 == 0
        ? ConversationStatus.refused
        : ConversationStatus.none;
  }

}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  _AppBar({super.key}) : preferredSize = const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'Messages clients',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 0.2,
        ),
      ),
      backgroundColor: const Color(0xFF1E66F5),
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: const [
        SizedBox(width: 16),
      ],
    );
  }
}


class ConversationGroupCard extends StatelessWidget {
  final String title;
  final int unreadCount;
  final List<ConversationListItem> items;
  final bool collapsed;
  final VoidCallback? onToggle;

  const ConversationGroupCard({
    super.key,
    required this.title,
    required this.unreadCount,
    this.items = const [],
    this.collapsed = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      size: 16,
                      color: Color(0xFF1E66F5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _Badge(unreadCount: unreadCount),
                ],
              ),
            ),
            if (!collapsed && items.isNotEmpty) const Divider(height: 1),
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                child: Column(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      _ConversationTile(item: items[i]),
                      if (i != items.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(left: 48),
                          child: Divider(height: 1),
                        ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int unreadCount;
  const _Badge({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBED4FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.markunread_mailbox_outlined,
            size: 14,
            color: Color(0xFF1E66F5),
          ),
          const SizedBox(width: 6),
          Text(
            unreadCount.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF1E66F5),
            ),
          ),
        ],
      ),
    );
  }
}

enum ConversationStatus { none, refused }

class ConversationListItem {
  final String name;
  final String preview;
  final String timeLabel;
  final ConversationStatus status;
  final VoidCallback? onTap;

  const ConversationListItem({
    required this.name,
    required this.preview,
    required this.timeLabel,
    this.status = ConversationStatus.none,
    this.onTap,
  });
}

class _ConversationTile extends StatelessWidget {
  final ConversationListItem item;
  const _ConversationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFFE9EDF5),
        child: Icon(
          Icons.person_rounded,
          color: Colors.grey.shade600,
          size: 20,
        ),
      ),
      title: Text(
        item.name,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2.5),
        child: Text(
          item.preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13.2,
          ),
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.timeLabel,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (item.status == ConversationStatus.refused) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: const Text(
                'Refusé',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: item.onTap,
    );
  }
}