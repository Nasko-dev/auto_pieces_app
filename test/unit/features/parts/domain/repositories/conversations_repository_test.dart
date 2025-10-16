import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'dart:async';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/conversations_repository.dart';

// Mock implementation pour les tests
class MockConversationsRepository implements ConversationsRepository {
  final List<Conversation> _conversations = [];
  final Map<String, List<Message>> _messages = {};
  final Map<String, int> _unreadCounts = {};
  final StreamController<Either<Failure, Message>> _messageStreamController =
      StreamController<Either<Failure, Message>>.broadcast();
  final StreamController<Either<Failure, List<Conversation>>>
      _conversationStreamController =
      StreamController<Either<Failure, List<Conversation>>>.broadcast();

  @override
  Future<Either<Failure, List<Conversation>>> getConversations(
      {required String userId}) async {
    try {
      final userConversations = _conversations
          .where((conv) => conv.userId == userId || conv.sellerId == userId)
          .toList();

      return Right(userConversations);
    } catch (e) {
      return Left(
          ServerFailure('Erreur lors de la récupération des conversations'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getConversationMessages(
      {required String conversationId}) async {
    try {
      final messages = _messages[conversationId] ?? [];
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la récupération des messages'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType messageType = MessageType.text,
    List<String> attachments = const [],
    Map<String, dynamic> metadata = const {},
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
  }) async {
    try {
      if (content.isEmpty) {
        return Left(
            ValidationFailure('Le contenu du message ne peut pas être vide'));
      }

      final message = Message(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: senderId,
        senderType: MessageSenderType.user, // Simplified for tests
        content: content,
        messageType: messageType,
        attachments: attachments,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        offerPrice: offerPrice,
        offerAvailability: offerAvailability,
        offerDeliveryDays: offerDeliveryDays,
      );

      if (!_messages.containsKey(conversationId)) {
        _messages[conversationId] = [];
      }
      _messages[conversationId]!.add(message);

      // Émettre le nouveau message dans le stream
      _messageStreamController.add(Right(message));

      return Right(message);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de l\'envoi du message'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      final messages = _messages[conversationId] ?? [];
      for (int i = 0; i < messages.length; i++) {
        if (!messages[i].isRead && messages[i].senderId != userId) {
          _messages[conversationId]![i] = messages[i].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      }
      _unreadCounts[conversationId] = 0;
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors du marquage des messages'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCount({
    required String conversationId,
  }) async {
    try {
      _unreadCounts[conversationId] = (_unreadCounts[conversationId] ?? 0) + 1;
      return const Right(null);
    } catch (e) {
      return Left(
          ServerFailure('Erreur lors de l\'incrémentation du compteur'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCountForUser({
    required String conversationId,
  }) async {
    return incrementUnreadCount(conversationId: conversationId);
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCountForSeller({
    required String conversationId,
  }) async {
    return incrementUnreadCount(conversationId: conversationId);
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCountForRecipient({
    required String conversationId,
    required String recipientId,
  }) async {
    return incrementUnreadCount(conversationId: conversationId);
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
      {required String conversationId}) async {
    try {
      _conversations.removeWhere((conv) => conv.id == conversationId);
      _messages.remove(conversationId);
      _unreadCounts.remove(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la suppression'));
    }
  }

  @override
  Future<Either<Failure, void>> blockConversation(
      {required String conversationId}) async {
    try {
      final index =
          _conversations.indexWhere((conv) => conv.id == conversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          status: ConversationStatus.blockedByUser,
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors du blocage'));
    }
  }

  @override
  Future<Either<Failure, void>> closeConversation(
      {required String conversationId}) async {
    try {
      final index =
          _conversations.indexWhere((conv) => conv.id == conversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          status: ConversationStatus.closed,
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la fermeture'));
    }
  }

  @override
  Stream<Either<Failure, Message>> subscribeToNewMessages(
      {required String conversationId}) {
    return _messageStreamController.stream;
  }

  @override
  Stream<Either<Failure, List<Conversation>>> subscribeToConversationUpdates(
      {required String userId}) {
    return _conversationStreamController.stream;
  }

  // Helpers pour les tests
  void addTestConversation(Conversation conversation) {
    _conversations.add(conversation);
  }

  void reset() {
    _conversations.clear();
    _messages.clear();
    _unreadCounts.clear();
  }

  int getUnreadCount(String conversationId) {
    return _unreadCounts[conversationId] ?? 0;
  }

  void dispose() {
    _messageStreamController.close();
    _conversationStreamController.close();
  }
}

void main() {
  group('ConversationsRepository Tests', () {
    late MockConversationsRepository repository;

    setUp(() {
      repository = MockConversationsRepository();
    });

    tearDown(() {
      repository.reset();
      repository.dispose();
    });

    group('getConversations', () {
      test('devrait retourner les conversations pour un utilisateur', () async {
        // Ajouter des conversations test
        final conversation1 = Conversation(
          id: 'conv-1',
          requestId: 'req-1',
          userId: 'user-123',
          sellerId: 'seller-1',
          lastMessageAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final conversation2 = Conversation(
          id: 'conv-2',
          requestId: 'req-2',
          userId: 'user-456',
          sellerId: 'seller-1',
          lastMessageAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        repository.addTestConversation(conversation1);
        repository.addTestConversation(conversation2);

        final result = await repository.getConversations(userId: 'user-123');

        expect(result, isA<Right<Failure, List<Conversation>>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (conversations) {
            expect(conversations.length, equals(1));
            expect(conversations.first.id, equals('conv-1'));
            expect(conversations.first.userId, equals('user-123'));
          },
        );
      });

      test('devrait retourner une liste vide s\'il n\'y a pas de conversations',
          () async {
        final result =
            await repository.getConversations(userId: 'user-inexistant');

        expect(result, isA<Right<Failure, List<Conversation>>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (conversations) => expect(conversations, isEmpty),
        );
      });
    });

    group('sendMessage', () {
      test('devrait envoyer un message texte avec succès', () async {
        final result = await repository.sendMessage(
          conversationId: 'conv-1',
          senderId: 'user-123',
          content: 'Bonjour, avez-vous cette pièce en stock ?',
        );

        expect(result, isA<Right<Failure, Message>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (message) {
            expect(message.conversationId, equals('conv-1'));
            expect(message.senderId, equals('user-123'));
            expect(message.content,
                equals('Bonjour, avez-vous cette pièce en stock ?'));
            expect(message.messageType, equals(MessageType.text));
            expect(message.id, isNotEmpty);
          },
        );
      });

      test('devrait envoyer un message avec offre de prix', () async {
        final result = await repository.sendMessage(
          conversationId: 'conv-1',
          senderId: 'seller-1',
          content: 'Je vous propose cette pièce',
          messageType: MessageType.offer,
          offerPrice: 150.0,
          offerAvailability: 'En stock',
          offerDeliveryDays: 3,
        );

        expect(result, isA<Right<Failure, Message>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (message) {
            expect(message.messageType, equals(MessageType.offer));
            expect(message.offerPrice, equals(150.0));
            expect(message.offerAvailability, equals('En stock'));
            expect(message.offerDeliveryDays, equals(3));
          },
        );
      });

      test('devrait retourner une erreur pour un contenu vide', () async {
        final result = await repository.sendMessage(
          conversationId: 'conv-1',
          senderId: 'user-123',
          content: '',
        );

        expect(result, isA<Left<Failure, Message>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (message) => fail('Ne devrait pas retourner de message'),
        );
      });

      test('devrait ajouter le message aux messages de la conversation',
          () async {
        await repository.sendMessage(
          conversationId: 'conv-test',
          senderId: 'user-123',
          content: 'Premier message',
        );

        final messagesResult = await repository.getConversationMessages(
          conversationId: 'conv-test',
        );

        messagesResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (messages) {
            expect(messages.length, equals(1));
            expect(messages.first.content, equals('Premier message'));
          },
        );
      });
    });

    group('getConversationMessages', () {
      test('devrait retourner les messages d\'une conversation', () async {
        // Ajouter quelques messages
        await repository.sendMessage(
          conversationId: 'conv-1',
          senderId: 'user-123',
          content: 'Premier message',
        );
        await repository.sendMessage(
          conversationId: 'conv-1',
          senderId: 'seller-1',
          content: 'Réponse du vendeur',
        );

        final result = await repository.getConversationMessages(
          conversationId: 'conv-1',
        );

        expect(result, isA<Right<Failure, List<Message>>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (messages) {
            expect(messages.length, equals(2));
            expect(messages.first.content, equals('Premier message'));
            expect(messages.last.content, equals('Réponse du vendeur'));
          },
        );
      });

      test('devrait retourner une liste vide pour une conversation inexistante',
          () async {
        final result = await repository.getConversationMessages(
          conversationId: 'conv-inexistante',
        );

        expect(result, isA<Right<Failure, List<Message>>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (messages) => expect(messages, isEmpty),
        );
      });
    });

    group('markMessagesAsRead', () {
      test('devrait marquer les messages comme lus', () async {
        // Envoyer des messages
        await repository.sendMessage(
          conversationId: 'conv-1',
          senderId: 'seller-1',
          content: 'Message du vendeur',
        );

        final result = await repository.markMessagesAsRead(
          conversationId: 'conv-1',
          userId: 'user-123',
        );

        expect(result, isA<Right<Failure, void>>());
        expect(repository.getUnreadCount('conv-1'), equals(0));
      });
    });

    group('Unread count management', () {
      test('devrait incrémenter le compteur de messages non lus', () async {
        final result = await repository.incrementUnreadCount(
          conversationId: 'conv-1',
        );

        expect(result, isA<Right<Failure, void>>());
        expect(repository.getUnreadCount('conv-1'), equals(1));
      });

      test('devrait incrémenter pour un utilisateur spécifique', () async {
        await repository.incrementUnreadCountForUser(conversationId: 'conv-1');
        await repository.incrementUnreadCountForUser(conversationId: 'conv-1');

        expect(repository.getUnreadCount('conv-1'), equals(2));
      });

      test('devrait incrémenter pour un vendeur', () async {
        await repository.incrementUnreadCountForSeller(
            conversationId: 'conv-1');

        expect(repository.getUnreadCount('conv-1'), equals(1));
      });

      test('devrait incrémenter pour un destinataire', () async {
        await repository.incrementUnreadCountForRecipient(
          conversationId: 'conv-1',
          recipientId: 'user-123',
        );

        expect(repository.getUnreadCount('conv-1'), equals(1));
      });
    });

    group('Conversation management', () {
      test('devrait supprimer une conversation', () async {
        final conversation = Conversation(
          id: 'conv-to-delete',
          requestId: 'req-1',
          userId: 'user-123',
          sellerId: 'seller-1',
          lastMessageAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        repository.addTestConversation(conversation);

        final result = await repository.deleteConversation(
          conversationId: 'conv-to-delete',
        );

        expect(result, isA<Right<Failure, void>>());

        // Vérifier que la conversation n'existe plus
        final conversationsResult =
            await repository.getConversations(userId: 'user-123');
        conversationsResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (conversations) => expect(conversations, isEmpty),
        );
      });

      test('devrait bloquer une conversation', () async {
        final conversation = Conversation(
          id: 'conv-to-block',
          requestId: 'req-1',
          userId: 'user-123',
          sellerId: 'seller-1',
          status: ConversationStatus.active,
          lastMessageAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        repository.addTestConversation(conversation);

        final result = await repository.blockConversation(
          conversationId: 'conv-to-block',
        );

        expect(result, isA<Right<Failure, void>>());

        // Vérifier que le statut a changé
        final conversationsResult =
            await repository.getConversations(userId: 'user-123');
        conversationsResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (conversations) {
            expect(conversations.first.status,
                equals(ConversationStatus.blockedByUser));
          },
        );
      });

      test('devrait fermer une conversation', () async {
        final conversation = Conversation(
          id: 'conv-to-close',
          requestId: 'req-1',
          userId: 'user-123',
          sellerId: 'seller-1',
          status: ConversationStatus.active,
          lastMessageAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        repository.addTestConversation(conversation);

        final result = await repository.closeConversation(
          conversationId: 'conv-to-close',
        );

        expect(result, isA<Right<Failure, void>>());

        // Vérifier que le statut a changé
        final conversationsResult =
            await repository.getConversations(userId: 'user-123');
        conversationsResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (conversations) {
            expect(
                conversations.first.status, equals(ConversationStatus.closed));
          },
        );
      });
    });

    group('Streams', () {
      test('devrait émettre les nouveaux messages dans le stream', () async {
        final stream =
            repository.subscribeToNewMessages(conversationId: 'conv-1');

        // Écouter le stream
        final completer = Completer<Message>();
        final subscription = stream.listen((either) {
          either.fold(
            (failure) => fail('Ne devrait pas retourner d\'erreur'),
            (message) => completer.complete(message),
          );
        });

        // Envoyer un message
        await repository.sendMessage(
          conversationId: 'conv-1',
          senderId: 'user-123',
          content: 'Message dans le stream',
        );

        final receivedMessage = await completer.future;
        expect(receivedMessage.content, equals('Message dans le stream'));

        await subscription.cancel();
      });

      test('devrait fournir un stream pour les mises à jour de conversations',
          () async {
        final stream =
            repository.subscribeToConversationUpdates(userId: 'user-123');
        expect(stream, isA<Stream<Either<Failure, List<Conversation>>>>());
      });
    });

    group('Types de messages', () {
      test('devrait gérer différents types de messages', () async {
        // Message texte
        final textResult = await repository.sendMessage(
          conversationId: 'conv-types',
          senderId: 'user-123',
          content: 'Message texte',
          messageType: MessageType.text,
        );
        expect(textResult, isA<Right<Failure, Message>>());

        // Message avec image
        final imageResult = await repository.sendMessage(
          conversationId: 'conv-types',
          senderId: 'user-123',
          content: 'Voici une photo de la pièce',
          messageType: MessageType.image,
          attachments: ['image1.jpg', 'image2.jpg'],
        );
        expect(imageResult, isA<Right<Failure, Message>>());

        // Message offre
        final offerResult = await repository.sendMessage(
          conversationId: 'conv-types',
          senderId: 'seller-1',
          content: 'Offre de prix',
          messageType: MessageType.offer,
          offerPrice: 75.50,
          metadata: {'discount': '10%'},
        );
        expect(offerResult, isA<Right<Failure, Message>>());

        // Vérifier que tous les messages sont enregistrés
        final messagesResult = await repository.getConversationMessages(
          conversationId: 'conv-types',
        );
        messagesResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (messages) => expect(messages.length, equals(3)),
        );
      });
    });
  });
}
