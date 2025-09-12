import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import '../providers/conversations_providers.dart';

class ConversationItemWidget extends ConsumerWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onBlock;

  const ConversationItemWidget({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onDelete,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(conversationUnreadCountProvider(conversation.id));
    final hasUnread = unreadCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar du vendeur
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 24,
                    child: Text(
                      _getInitials(conversation.sellerName ?? 'Vendeur'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Informations principales
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                conversation.sellerName ?? 'Vendeur inconnu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (hasUnread)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        if (conversation.sellerCompany != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            conversation.sellerCompany!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        
                        if (conversation.requestTitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Demande: ${conversation.requestTitle}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Menu d'actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          onDelete();
                          break;
                        case 'block':
                          onBlock();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Bloquer le vendeur'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              
              // Dernier message et timestamp
              if (conversation.lastMessageContent != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      conversation.lastMessageSenderType == MessageSenderType.user
                          ? Icons.arrow_forward
                          : Icons.arrow_back,
                      size: 16,
                      color: conversation.lastMessageSenderType == MessageSenderType.user
                          ? Colors.blue
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        conversation.lastMessageContent!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (conversation.lastMessageCreatedAt != null)
                      Text(
                        _formatTimestamp(conversation.lastMessageCreatedAt!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ],
              
              // Statut de la conversation
              if (conversation.status != ConversationStatus.active) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(conversation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(conversation.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(conversation.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(conversation.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final localTimestamp = timestamp.toLocal(); // Conversion UTC vers heure locale
    final difference = now.difference(localTimestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Hier';
      if (difference.inDays < 7) return '${difference.inDays}j';
      return '${localTimestamp.day}/${localTimestamp.month}';
    }
    
    if (difference.inHours > 0) {
      return '${difference.inHours}h';
    }
    
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    }
    
    return 'À l\'instant';
  }

  Color _getStatusColor(ConversationStatus status) {
    switch (status) {
      case ConversationStatus.active:
        return Colors.green;
      case ConversationStatus.closed:
        return Colors.grey;
      case ConversationStatus.deletedByUser:
        return Colors.red;
      case ConversationStatus.blockedByUser:
        return Colors.orange;
    }
  }

  String _getStatusText(ConversationStatus status) {
    switch (status) {
      case ConversationStatus.active:
        return 'Active';
      case ConversationStatus.closed:
        return 'Fermée';
      case ConversationStatus.deletedByUser:
        return 'Supprimée';
      case ConversationStatus.blockedByUser:
        return 'Bloquée';
    }
  }
}