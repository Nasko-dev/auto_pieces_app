import 'package:flutter/material.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final bool isLastMessage;
  final MessageSenderType currentUserType;
  final String? otherUserName;
  final String? otherUserAvatarUrl;
  final String? otherUserCompany;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.currentUserType,
    this.isLastMessage = false,
    this.otherUserName,
    this.otherUserAvatarUrl,
    this.otherUserCompany,
  });

  @override
  Widget build(BuildContext context) {
    // Le message est "de nous" si le type correspond à l'utilisateur actuel
    final isFromCurrentUser = message.senderType == currentUserType;
    final isOffer = message.messageType == MessageType.offer;
    

    return Align(
      alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isFromCurrentUser ? 80 : 8,
          right: isFromCurrentUser ? 8 : 80,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar de l'autre utilisateur (seulement si ce n'est pas le message de l'utilisateur actuel)
            if (!isFromCurrentUser) ...[
              Padding(
                padding: const EdgeInsets.only(top: 4), // Petit décalage pour aligner avec le texte
                child: _buildOtherUserAvatar(),
              ),
              const SizedBox(width: 12),
            ],

            // Bulle de message
            Flexible(
              child: Column(
                crossAxisAlignment: isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromCurrentUser
                    ? const Color(0xFF3B82F6) // Bleu Instagram
                    : isOffer
                        ? Colors.green[50]
                        : const Color(0xFFF3F4F6), // Gris clair Instagram
                borderRadius: BorderRadius.circular(20), // Plus arrondi style Instagram
                border: isOffer
                    ? Border.all(color: Colors.green, width: 1)
                    : (!isFromCurrentUser ? Border.all(color: Colors.grey.shade200, width: 1) : null),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOffer) _buildOfferHeader(),
                  
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isFromCurrentUser
                          ? Colors.white
                          : isOffer
                              ? Colors.green[800]
                              : Colors.black87,
                      fontSize: 15, // Légèrement plus petit style Instagram
                      height: 1.4,
                    ),
                  ),
                  
                  if (isOffer) ...[
                    const SizedBox(height: 12),
                    _buildOfferDetails(context),
                  ],
                  
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isFromCurrentUser
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                      if (isFromCurrentUser && isLastMessage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 16,
                          color: message.isRead ? Colors.blue : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                  ],
                ),
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer,
            size: 16,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'OFFRE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.offerPrice != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.euro,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prix: ${message.offerPrice!.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          if (message.offerAvailability != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.inventory,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Disponibilité: ${message.offerAvailability}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          if (message.offerDeliveryDays != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Livraison: ${message.offerDeliveryDays} jour${message.offerDeliveryDays! > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final localTime = timestamp.toLocal(); // Conversion UTC vers heure locale du téléphone
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildOtherUserAvatar() {
    if (otherUserAvatarUrl != null && otherUserAvatarUrl!.isNotEmpty) {
      // Avatar style Instagram avec vraie photo
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            otherUserAvatarUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultOtherUserAvatar();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildDefaultOtherUserAvatar();
            },
          ),
        ),
      );
    } else {
      return _buildDefaultOtherUserAvatar();
    }
  }

  Widget _buildDefaultOtherUserAvatar() {
    // Déterminer l'icône selon le type d'utilisateur
    final isSellerMessage = currentUserType == MessageSenderType.user; // Si l'utilisateur actuel est un particulier, l'autre est un vendeur

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSellerMessage
              ? [const Color(0xFF405DE6), const Color(0xFF5851DB)] // Gradient Instagram bleu
              : [const Color(0xFF9CA3AF), const Color(0xFF6B7280)], // Gradient gris
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isSellerMessage ? Icons.business : Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}