import 'package:cente_pice/src/features/parts/domain/entities/conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';

/// Fixtures pour les tests de conversations
class ConversationFixtures {
  static final tConversation = Conversation(
    id: 'test-conversation-id-1',
    requestId: 'test-request-id-1',
    userId: 'test-user-id',
    sellerId: 'test-seller-id',
    status: ConversationStatus.active,
    lastMessageAt: DateTime(2024, 1, 5, 14, 30),
    createdAt: DateTime(2024, 1, 1, 10, 0),
    updatedAt: DateTime(2024, 1, 5, 14, 30),
    sellerName: 'Jean Dupont',
    sellerCompany: 'Pièces Auto Pro',
    sellerAvatarUrl: 'https://example.com/avatar1.jpg',
    sellerPhone: '0612345678',
    userName: 'Marie Martin',
    userDisplayName: 'Marie M.',
    userAvatarUrl: 'https://example.com/avatar2.jpg',
    requestTitle: 'Capot Renault Clio 2015',
    lastMessageContent: 'Bonjour, j\'ai la pièce en stock',
    lastMessageSenderType: MessageSenderType.seller,
    lastMessageCreatedAt: DateTime(2024, 1, 5, 14, 30),
    unreadCount: 1,
    totalMessages: 5,
    vehicleBrand: 'Renault',
    vehicleModel: 'Clio',
    vehicleYear: 2015,
    partType: 'body',
    particulierFirstName: 'Marie',
  );

  static final tConversationClosed = Conversation(
    id: 'test-conversation-id-2',
    requestId: 'test-request-id-2',
    userId: 'test-user-id',
    sellerId: 'test-seller-id-2',
    status: ConversationStatus.closed,
    lastMessageAt: DateTime(2024, 1, 3, 10, 0),
    createdAt: DateTime(2024, 1, 1, 9, 0),
    updatedAt: DateTime(2024, 1, 3, 10, 0),
    sellerName: 'Pierre Durand',
    sellerCompany: 'Auto Pièces +',
    lastMessageContent: 'Transaction terminée, merci',
    lastMessageSenderType: MessageSenderType.user,
    lastMessageCreatedAt: DateTime(2024, 1, 3, 10, 0),
    unreadCount: 0,
    totalMessages: 12,
    vehicleEngine: '2.0 TDI',
    partType: 'engine',
  );

  static final tMessage = Message(
    id: 'test-message-id-1',
    conversationId: 'test-conversation-id-1',
    senderId: 'test-seller-id',
    senderType: MessageSenderType.seller,
    content: 'Bonjour, j\'ai la pièce en stock',
    messageType: MessageType.text,
    createdAt: DateTime(2024, 1, 5, 14, 30),
    updatedAt: DateTime(2024, 1, 5, 14, 30),
    isRead: false,
  );

  static final tMessageOffer = Message(
    id: 'test-message-id-2',
    conversationId: 'test-conversation-id-1',
    senderId: 'test-seller-id',
    senderType: MessageSenderType.seller,
    content: 'Voici mon offre pour les pièces demandées',
    messageType: MessageType.offer,
    offerPrice: 150.0,
    offerAvailability: 'available',
    offerDeliveryDays: 2,
    createdAt: DateTime(2024, 1, 5, 15, 0),
    updatedAt: DateTime(2024, 1, 5, 15, 0),
    isRead: false,
  );

  static final tMessageUser = Message(
    id: 'test-message-id-3',
    conversationId: 'test-conversation-id-1',
    senderId: 'test-user-id',
    senderType: MessageSenderType.user,
    content: 'Merci, est-ce que la pièce est garantie ?',
    messageType: MessageType.text,
    createdAt: DateTime(2024, 1, 5, 15, 30),
    updatedAt: DateTime(2024, 1, 5, 15, 30),
    isRead: true,
  );

  static List<Conversation> get tConversationList => [
        tConversation,
        tConversationClosed,
      ];

  static List<Message> get tMessageList => [
        tMessage,
        tMessageOffer,
        tMessageUser,
      ];
}
