import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/conversation_group.dart';
import '../../domain/entities/conversation.dart';
import '../providers/conversations_providers.dart';

class ConversationGroupCard extends ConsumerStatefulWidget {
  final ConversationGroup group;
  final Function(String conversationId) onConversationTap;

  const ConversationGroupCard({
    super.key,
    required this.group,
    required this.onConversationTap,
  });

  @override
  ConsumerState<ConversationGroupCard> createState() => _ConversationGroupCardState();
}

class _ConversationGroupCardState extends ConsumerState<ConversationGroupCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final hasUnread = group.hasUnreadMessages;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: hasUnread ? const Color(0xFFF0F8FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasUnread
            ? Border.all(color: const Color(0xFF007AFF), width: 1.5)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: hasUnread
                ? const Color(0xFF007AFF).withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: hasUnread ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du groupe
                _buildGroupHeader(group, hasUnread),

                // Liste des conversations (si développé)
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
                  const SizedBox(height: 12),
                  _buildConversationsList(group.conversations),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(ConversationGroup group, bool hasUnread) {
    return Row(
      children: [
        // Icône de la pièce
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: hasUnread ? const Color(0xFF007AFF) : const Color(0xFF5AC8FA),
            shape: BoxShape.circle,
            border: hasUnread
                ? Border.all(
                    color: const Color(0xFF007AFF).withOpacity(0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Icon(
            _getPartIcon(group.partType),
            color: Colors.white,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // Informations du groupe
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal
              Text(
                group.displayTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                  color: hasUnread ? const Color(0xFF007AFF) : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Compteur de conversations
              Text(
                '${group.conversationCount} demande${group.conversationCount > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Badge messages non lus
        if (hasUnread) _buildUnreadBadge(group.totalUnreadCount),

        const SizedBox(width: 8),

        // Icône expand/collapse
        Icon(
          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.grey[600],
          size: 24,
        ),
      ],
    );
  }

  Widget _buildUnreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildConversationsList(List<Conversation> conversations) {
    return Column(
      children: conversations.map((conversation) {
        return _buildConversationItem(conversation);
      }).toList(),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    // Utiliser les compteurs locaux au lieu de conversation.unreadCount
    final localUnreadCount = ref.watch(conversationUnreadCountProvider(conversation.id));
    final hasUnread = localUnreadCount > 0;
    final lastMessage = conversation.lastMessageContent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onConversationTap(conversation.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              // Avatar du particulier
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hasUnread
                      ? const Color(0xFF007AFF)
                      : const Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              const SizedBox(width: 12),

              // Infos de la conversation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Particulier',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                            color: hasUnread ? const Color(0xFF007AFF) : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (hasUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    if (lastMessage != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPartIcon(String? partType) {
    switch (partType) {
      case 'engine':
        return Icons.settings;
      case 'body':
        return Icons.car_repair;
      default:
        return Icons.auto_fix_high;
    }
  }
}