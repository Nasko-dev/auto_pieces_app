import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/particulier_conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';

class ConversationItemWidget extends ConsumerWidget {
  final dynamic
  conversation; // Accept both Conversation and ParticulierConversation
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
    // Déterminer le type de conversation et récupérer le compteur local
    final isParticulier = conversation is ParticulierConversation;
    int unreadCount = 0;

    if (isParticulier) {
      // Pour les particuliers, utiliser les compteurs DB de la conversation
      unreadCount = (conversation as ParticulierConversation).unreadCount;
    } else {
      // Pour les vendeurs, utiliser les compteurs DB
      unreadCount = (conversation as Conversation).unreadCount;
    }

    final hasUnread = unreadCount > 0;
    final sellerName =
        isParticulier
            ? _getSellerDisplayName() // Côté particulier : afficher le nom de l'entreprise ou fallback
            : (_getParticulierDisplayName() ?? 'Particulier'); // Côté vendeur : afficher le nom du particulier
    final lastMessage = _getLastMessageContent();
    final timestamp = _getLastMessageCreatedAt();
    final requestTitle = _getRequestTitle();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: hasUnread ? const Color(0xFFF0F8FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            hasUnread
                ? Border.all(color: const Color(0xFF007AFF), width: 1.5)
                : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color:
                hasUnread
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar du vendeur/client
                _buildAvatar(sellerName, hasUnread),

                const SizedBox(width: 12),

                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne du haut : Nom + Badge unread + Menu
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sellerName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color:
                                    hasUnread
                                        ? const Color(0xFF007AFF)
                                        : Colors.black87,
                              ),
                            ),
                          ),

                          // Badge de messages non lus
                          if (hasUnread) _buildUnreadBadge(unreadCount),

                          const SizedBox(width: 8),

                          // Menu d'actions
                          _buildActionMenu(context),
                        ],
                      ),

                      // Titre de la demande si disponible
                      if (requestTitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          requestTitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Dernier message si disponible
                      if (lastMessage != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Icône de direction du message
                            Icon(
                              _getLastMessageSenderType() ==
                                      MessageSenderType.user
                                  ? Icons.reply
                                  : Icons.chat_bubble_outline,
                              size: 14,
                              color:
                                  _getLastMessageSenderType() ==
                                          MessageSenderType.user
                                      ? const Color(0xFF007AFF)
                                      : const Color(0xFF5AC8FA),
                            ),
                            const SizedBox(width: 6),

                            // Contenu du dernier message
                            Expanded(
                              child: Text(
                                lastMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      hasUnread
                                          ? Colors.black87
                                          : Colors.grey[600],
                                  fontWeight:
                                      hasUnread
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Timestamp
                            if (timestamp != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                _formatTimestamp(timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      hasUnread
                                          ? const Color(0xFF007AFF)
                                          : Colors.grey[500],
                                  fontWeight:
                                      hasUnread
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, bool hasUnread) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: hasUnread ? const Color(0xFF007AFF) : const Color(0xFF5AC8FA),
        shape: BoxShape.circle,
        border:
            hasUnread
                ? Border.all(
                  color: const Color(0xFF007AFF).withOpacity(0.3),
                  width: 2,
                )
                : null,
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
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
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  SizedBox(width: 12),
                  Text('Supprimer', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.orange, size: 18),
                  SizedBox(width: 12),
                  Text('Bloquer', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
    );
  }

  String _getInitials(String name) {
    final words =
        name.trim().split(' ').where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].isEmpty ? '?' : words[0][0].toUpperCase();
    }
    return words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : words[0].isEmpty
        ? '?'
        : words[0][0].toUpperCase();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final localTimestamp = timestamp.toLocal();
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

    return 'Maintenant';
  }

  // Helper methods pour récupérer les données selon le type de conversation

  String? _getRequestTitle() {
    if (conversation is Conversation) {
      return (conversation as Conversation).requestTitle;
    } else if (conversation is ParticulierConversation) {
      final particConv = conversation as ParticulierConversation;
      return particConv.partType ?? particConv.partNames?.join(', ');
    }
    return null;
  }

  String? _getLastMessageContent() {
    if (conversation is Conversation) {
      return (conversation as Conversation).lastMessageContent;
    } else if (conversation is ParticulierConversation) {
      final particConv = conversation as ParticulierConversation;
      if (particConv.messages.isNotEmpty) {
        return particConv.messages.last.content;
      }
    }
    return null;
  }

  MessageSenderType? _getLastMessageSenderType() {
    if (conversation is Conversation) {
      return (conversation as Conversation).lastMessageSenderType;
    } else if (conversation is ParticulierConversation) {
      final particConv = conversation as ParticulierConversation;
      if (particConv.messages.isNotEmpty) {
        return particConv.messages.last.isFromParticulier
            ? MessageSenderType.user
            : MessageSenderType.seller;
      }
    }
    return null;
  }

  DateTime? _getLastMessageCreatedAt() {
    if (conversation is Conversation) {
      return (conversation as Conversation).lastMessageCreatedAt;
    } else if (conversation is ParticulierConversation) {
      final particConv = conversation as ParticulierConversation;
      if (particConv.messages.isNotEmpty) {
        return particConv.messages.last.createdAt;
      }
      return particConv.lastMessageAt;
    }
    return null;
  }

  String _getSellerDisplayName() {
    if (conversation is ParticulierConversation) {
      final conv = conversation as ParticulierConversation;

      // Priorité 1 : Utiliser le nom de l'entreprise si disponible
      if (conv.sellerCompany != null && conv.sellerCompany!.isNotEmpty) {
        return conv.sellerCompany!;
      }

      // Fallback : utiliser le nom complet du vendeur
      if (conv.sellerName.isNotEmpty) {
        return conv.sellerName;
      }
    }

    // Fallback final
    return 'Vendeur Professionnel';
  }

  String? _getParticulierDisplayName() {
    if (conversation is Conversation) {
      final conv = conversation as Conversation;

      // Priorité 1 : Utiliser le nom d'affichage complet du particulier
      if (conv.userDisplayName != null && conv.userDisplayName!.isNotEmpty) {
        return conv.userDisplayName!;
      }

      // Priorité 2 : Utiliser le prénom du particulier si disponible
      if (conv.particulierFirstName != null && conv.particulierFirstName!.isNotEmpty) {
        return conv.particulierFirstName!;
      }

      // Priorité 3 : Utiliser le nom d'utilisateur (téléphone)
      if (conv.userName != null && conv.userName!.isNotEmpty) {
        return conv.userName!;
      }

      // Fallback : utiliser le nom du véhicule si pas de prénom
      return _getMotorName();
    }
    return null;
  }

  String? _getMotorName() {
    if (conversation is Conversation) {
      final conv = conversation as Conversation;

      // Construire le nom du véhicule selon le type de pièce
      if (conv.partType == 'engine') {
        // Pour les pièces moteur : afficher seulement la motorisation
        if (conv.vehicleEngine != null && conv.vehicleEngine!.isNotEmpty) {
          return conv.vehicleEngine!;
        }
      } else if (conv.partType == 'body') {
        // Pour les pièces carrosserie : afficher marque + modèle + année
        final parts = <String>[];
        if (conv.vehicleBrand != null) parts.add(conv.vehicleBrand!);
        if (conv.vehicleModel != null) parts.add(conv.vehicleModel!);
        if (conv.vehicleYear != null) parts.add(conv.vehicleYear.toString());

        if (parts.isNotEmpty) {
          return parts.join(' ');
        }
      }

      // Fallback : essayer toutes les infos disponibles
      final parts = <String>[];
      if (conv.vehicleBrand != null) parts.add(conv.vehicleBrand!);
      if (conv.vehicleModel != null) parts.add(conv.vehicleModel!);
      if (conv.vehicleYear != null) parts.add(conv.vehicleYear.toString());

      if (parts.isEmpty && conv.vehicleEngine != null) {
        return conv.vehicleEngine!;
      }

      if (parts.isNotEmpty) {
        return parts.join(' ');
      }

      return 'Véhicule';
    }

    return null;
  }
}
