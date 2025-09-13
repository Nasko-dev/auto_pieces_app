import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/particulier_conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import 'package:cente_pice/src/features/parts/domain/entities/particulier_message.dart';

class ConversationItemWidget extends ConsumerStatefulWidget {
  final dynamic conversation; // Accept both Conversation and ParticulierConversation
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onBlock;
  final bool isNewMessage;

  const ConversationItemWidget({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onDelete,
    required this.onBlock,
    this.isNewMessage = false,
  });

  @override
  ConsumerState<ConversationItemWidget> createState() => _ConversationItemWidgetState();
}

class _ConversationItemWidgetState extends ConsumerState<ConversationItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Désactiver l'auto-start de l'animation
    // if (widget.isNewMessage) {
    //   _animationController.repeat(reverse: true);
    // }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Désactiver temporairement tous les effets visuels
    const bool hasUnread = false; // Forcé à false pour désactiver les effets
    const int unreadCount = 0;    // Forcé à 0 pour désactiver les effets
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: hasUnread ? _pulseAnimation.value : 1.0,
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: hasUnread ? 6 : 2,
            shadowColor: hasUnread ? Colors.red.withOpacity(0.4) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: hasUnread
                  ? const BorderSide(
                      color: Colors.red,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: hasUnread
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.withOpacity(0.08),
                          Colors.white,
                        ],
                      )
                    : null,
              ),
              child: InkWell(
                onTap: () {
                  // _animationController.stop(); // Désactivé
                  widget.onTap();
                },
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
                      _getInitials(_getSellerName(widget.conversation) ?? 'Vendeur'),
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
                                _getSellerName(widget.conversation) ?? 'Vendeur inconnu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                            // Badge TOUJOURS visible pour debug - FORCER l'affichage
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: hasUnread ? Colors.red : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: hasUnread ? [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    hasUnread ? Icons.mark_email_unread : Icons.mark_email_read,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        if (_getSellerCompany(widget.conversation) != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _getSellerCompany(widget.conversation)!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        
                        if (_getRequestTitle(widget.conversation) != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Demande: ${_getRequestTitle(widget.conversation)}',
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
                          widget.onDelete();
                          break;
                        case 'block':
                          widget.onBlock();
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
              if (_getLastMessageContent(widget.conversation) != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _getLastMessageSenderType(widget.conversation) == MessageSenderType.user
                          ? Icons.arrow_forward
                          : Icons.arrow_back,
                      size: 16,
                      color: _getLastMessageSenderType(widget.conversation) == MessageSenderType.user
                          ? Colors.blue
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getLastMessageContent(widget.conversation)!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_getLastMessageCreatedAt(widget.conversation) != null)
                      Text(
                        _formatTimestamp(_getLastMessageCreatedAt(widget.conversation)!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ],
              
              // Statut de la conversation
              if (_getStatus(widget.conversation) != ConversationStatus.active) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_getStatus(widget.conversation)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(_getStatus(widget.conversation)),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(_getStatus(widget.conversation)),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(_getStatus(widget.conversation)),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ').where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].isEmpty ? '?' : words[0][0].toUpperCase();
    }
    return words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : words[0].isEmpty ? '?' : words[0][0].toUpperCase();
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
  
  // Helper methods to handle both Conversation and ParticulierConversation
  int _getUnreadCount(dynamic conversation) {
    if (conversation is Conversation) {
      return conversation.unreadCount;
    } else if (conversation is ParticulierConversation) {
      return conversation.unreadCount;
    }
    print('⚠️ [ConversationItem] Type inconnu: ${conversation.runtimeType}');
    return 0;
  }
  
  String? _getSellerName(dynamic conversation) {
    if (conversation is Conversation) {
      return conversation.sellerName;
    } else if (conversation is ParticulierConversation) {
      return conversation.sellerName;
    }
    return null;
  }
  
  String? _getSellerCompany(dynamic conversation) {
    if (conversation is Conversation) {
      return conversation.sellerCompany;
    } else if (conversation is ParticulierConversation) {
      // ParticulierConversation n'a pas sellerCompany, on retourne null
      return null;
    }
    return null;
  }
  
  String? _getRequestTitle(dynamic conversation) {
    if (conversation is Conversation) {
      return conversation.requestTitle;
    } else if (conversation is ParticulierConversation) {
      // Pour ParticulierConversation, on peut utiliser partType ou partNames
      return conversation.partType ?? conversation.partNames?.join(', ');
    }
    return null;
  }
  
  String? _getLastMessageContent(dynamic conversation) {
    if (conversation is Conversation) {
      return conversation.lastMessageContent;
    } else if (conversation is ParticulierConversation) {
      // Pour ParticulierConversation, on prend le dernier message
      if (conversation.messages.isNotEmpty) {
        return conversation.messages.last.content;
      }
    }
    return null;
  }
  
  MessageSenderType? _getLastMessageSenderType(dynamic conversation) {
    if (conversation is Conversation) {
      return conversation.lastMessageSenderType;
    } else if (conversation is ParticulierConversation) {
      // Pour ParticulierConversation, on détermine le type selon isFromParticulier
      if (conversation.messages.isNotEmpty) {
        return conversation.messages.last.isFromParticulier 
            ? MessageSenderType.user 
            : MessageSenderType.seller;
      }
    }
    return null;
  }
  
  DateTime? _getLastMessageCreatedAt(dynamic conversation) {
    if (conversation is Conversation) {
      return conversation.lastMessageCreatedAt;
    } else if (conversation is ParticulierConversation) {
      if (conversation.messages.isNotEmpty) {
        return conversation.messages.last.createdAt;
      }
      return conversation.lastMessageAt;
    }
    return null;
  }
  
  ConversationStatus _getStatus(dynamic conversation) {
    if (conversation is Conversation) {
      return conversation.status;
    } else if (conversation is ParticulierConversation) {
      return conversation.status;
    }
    return ConversationStatus.active;
  }
}