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
    // Calculer le nombre de conversations avec messages non lus
    final conversationsWithUnread = _getConversationsWithUnreadCount(group);

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

              // Compteur de conversations avec statut messages non lus
              _buildConversationStatus(group.conversationCount, conversationsWithUnread),
            ],
          ),
        ),

        // Badge nombre de conversations non lues
        if (hasUnread) _buildUnreadConversationsBadge(conversationsWithUnread),

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
    final lastMessageTime = conversation.lastMessageCreatedAt ?? conversation.lastMessageAt;

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
                        Expanded(
                          child: Text(
                            'Particulier',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                              color: hasUnread ? const Color(0xFF007AFF) : Colors.black87,
                            ),
                          ),
                        ),
                        // Badge avec nombre de messages non lus
                        if (hasUnread) _buildMessageCountBadge(localUnreadCount),
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

              // Heure du dernier message
              if (lastMessageTime != null) ...[
                const SizedBox(width: 8),
                Text(
                  _formatMessageTime(lastMessageTime),
                  style: TextStyle(
                    fontSize: 11,
                    color: hasUnread ? const Color(0xFF007AFF) : Colors.grey[500],
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
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

  // Calculer le nombre de conversations avec messages non lus
  int _getConversationsWithUnreadCount(ConversationGroup group) {
    int count = 0;
    for (final conversation in group.conversations) {
      final localUnreadCount = ref.watch(conversationUnreadCountProvider(conversation.id));
      if (localUnreadCount > 0) {
        count++;
      }
    }
    return count;
  }

  // Widget pour afficher le statut des conversations
  Widget _buildConversationStatus(int totalConversations, int conversationsWithUnread) {
    if (conversationsWithUnread == 0) {
      // Aucun message non lu
      return Text(
        '$totalConversations demande${totalConversations > 1 ? 's' : ''}',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
        ),
      );
    } else {
      // Conversations avec messages non lus
      return Text(
        '$conversationsWithUnread/$totalConversations non lue${conversationsWithUnread > 1 ? 's' : ''}',
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF007AFF),
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  // Badge pour le nombre de conversations non lues
  Widget _buildUnreadConversationsBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Badge pour le nombre de messages non lus d'une conversation individuelle
  Widget _buildMessageCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Formater l'heure du dernier message
  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final difference = now.difference(localTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Hier';
      if (difference.inDays < 7) return '${difference.inDays}j';
      return '${localTime.day}/${localTime.month}';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours}h';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    }

    return 'Maintenant';
  }
}