import 'package:flutter/material.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final bool isLastMessage;
  final MessageSenderType currentUserType;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.currentUserType,
    this.isLastMessage = false,
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
          left: isFromCurrentUser ? 64 : 0,
          right: isFromCurrentUser ? 0 : 64,
        ),
        child: Column(
          crossAxisAlignment: isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromCurrentUser
                    ? Theme.of(context).primaryColor
                    : isOffer
                        ? Colors.green[50]
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isFromCurrentUser ? const Radius.circular(4) : null,
                  bottomLeft: !isFromCurrentUser ? const Radius.circular(4) : null,
                ),
                border: isOffer
                    ? Border.all(color: Colors.green, width: 1)
                    : null,
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
                      fontSize: 16,
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
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}