import 'package:cente_pice/src/core/errors/exceptions.dart';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/data/datasources/conversations_remote_datasource.dart';
import 'package:cente_pice/src/features/parts/data/repositories/conversations_repository_impl.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'conversations_repository_impl_test.mocks.dart';

@GenerateMocks([ConversationsRemoteDataSource])
void main() {
  late ConversationsRepositoryImpl repository;
  late MockConversationsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockConversationsRemoteDataSource();
    repository =
        ConversationsRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tUserId = 'user123';
  const tSellerId = 'seller456';
  const tConversationId = 'conv789';
  const tRequestId = 'req123';

  final tConversation = Conversation(
    id: tConversationId,
    requestId: tRequestId,
    userId: tUserId,
    sellerId: tSellerId,
    status: ConversationStatus.active,
    lastMessageAt: DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    sellerName: 'Jean Dupont',
    sellerCompany: 'Pièces Auto Pro',
    userName: 'Marie Martin',
    requestTitle: 'Pare-chocs avant',
    lastMessageContent: 'Bonjour, j\'ai cette pièce disponible',
    lastMessageSenderType: MessageSenderType.seller,
    unreadCount: 2,
    totalMessages: 15,
  );

  final tMessage = Message(
    id: 'msg123',
    conversationId: tConversationId,
    senderId: tSellerId,
    senderType: MessageSenderType.seller,
    content: 'J\'ai cette pièce en stock',
    messageType: MessageType.text,
    isRead: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('getConversations', () {
    test('doit retourner une liste de conversations quand l\'appel réussit',
        () async {
      // arrange
      final conversations = [tConversation];
      when(mockRemoteDataSource.getConversations(userId: tUserId))
          .thenAnswer((_) async => conversations);

      // act
      final result = await repository.getConversations(userId: tUserId);

      // assert
      expect(result, Right(conversations));
      verify(mockRemoteDataSource.getConversations(userId: tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée',
        () async {
      // arrange
      when(mockRemoteDataSource.getConversations(userId: tUserId))
          .thenThrow(const ServerException('Erreur serveur'));

      // act
      final result = await repository.getConversations(userId: tUserId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRemoteDataSource.getConversations(userId: tUserId));
    });

    test(
        'doit retourner ServerFailure avec message générique pour une exception générale',
        () async {
      // arrange
      when(mockRemoteDataSource.getConversations(userId: tUserId))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.getConversations(userId: tUserId);

      // assert
      expect(
          result,
          const Left(ServerFailure(
              'Erreur lors de la récupération des conversations')));
      verify(mockRemoteDataSource.getConversations(userId: tUserId));
    });

    test('doit gérer une liste vide de conversations', () async {
      // arrange
      when(mockRemoteDataSource.getConversations(userId: tUserId))
          .thenAnswer((_) async => <Conversation>[]);

      // act
      final result = await repository.getConversations(userId: tUserId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) => expect(conversations, <Conversation>[]),
      );
      verify(mockRemoteDataSource.getConversations(userId: tUserId));
    });

    test('doit déléguer entièrement au datasource', () async {
      // arrange
      final conversations = [tConversation];
      when(mockRemoteDataSource.getConversations(userId: tUserId))
          .thenAnswer((_) async => conversations);

      // act
      await repository.getConversations(userId: tUserId);

      // assert
      verify(mockRemoteDataSource.getConversations(userId: tUserId));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('getConversationMessages', () {
    test('doit retourner une liste de messages quand l\'appel réussit',
        () async {
      // arrange
      final List<Message> messages = [tMessage];
      when(mockRemoteDataSource.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => messages);

      // act
      final result = await repository.getConversationMessages(
          conversationId: tConversationId);

      // assert
      expect(result, Right(messages));
      verify(mockRemoteDataSource.getConversationMessages(
          conversationId: tConversationId));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée',
        () async {
      // arrange
      when(mockRemoteDataSource.getConversationMessages(
              conversationId: tConversationId))
          .thenThrow(const ServerException('Erreur serveur'));

      // act
      final result = await repository.getConversationMessages(
          conversationId: tConversationId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRemoteDataSource.getConversationMessages(
          conversationId: tConversationId));
    });

    test(
        'doit retourner ServerFailure avec message générique pour une exception générale',
        () async {
      // arrange
      when(mockRemoteDataSource.getConversationMessages(
              conversationId: tConversationId))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await repository.getConversationMessages(
          conversationId: tConversationId);

      // assert
      expect(
          result,
          const Left(
              ServerFailure('Erreur lors de la récupération des messages')));
      verify(mockRemoteDataSource.getConversationMessages(
          conversationId: tConversationId));
    });

    test('doit gérer une conversation sans messages', () async {
      // arrange
      when(mockRemoteDataSource.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => <Message>[]);

      // act
      final result = await repository.getConversationMessages(
          conversationId: tConversationId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) => expect(messages, <Message>[]),
      );
      verify(mockRemoteDataSource.getConversationMessages(
          conversationId: tConversationId));
    });

    test('doit déléguer entièrement au datasource', () async {
      // arrange
      final messages = [tMessage];
      when(mockRemoteDataSource.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => messages);

      // act
      await repository.getConversationMessages(conversationId: tConversationId);

      // assert
      verify(mockRemoteDataSource.getConversationMessages(
          conversationId: tConversationId));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('sendMessage', () {
    const tSenderId = 'sender123';
    const tContent = 'Bonjour, j\'ai cette pièce disponible';

    test('doit retourner un message quand l\'envoi réussit', () async {
      // arrange
      when(mockRemoteDataSource.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.text,
        attachments: const [],
        metadata: const {},
      )).thenAnswer((_) async => tMessage);

      // act
      final result = await repository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
      );

      // assert
      expect(result, Right(tMessage));
      verify(mockRemoteDataSource.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.text,
        attachments: const [],
        metadata: const {},
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('doit envoyer un message avec une offre', () async {
      // arrange
      const offerPrice = 150.0;
      const offerAvailability = 'Immédiatement';
      const offerDeliveryDays = 2;

      when(mockRemoteDataSource.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.offer,
        attachments: const [],
        metadata: const {},
        offerPrice: offerPrice,
        offerAvailability: offerAvailability,
        offerDeliveryDays: offerDeliveryDays,
      )).thenAnswer((_) async => tMessage);

      // act
      final result = await repository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.offer,
        offerPrice: offerPrice,
        offerAvailability: offerAvailability,
        offerDeliveryDays: offerDeliveryDays,
      );

      // assert
      expect(result, Right(tMessage));
      verify(mockRemoteDataSource.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.offer,
        attachments: const [],
        metadata: const {},
        offerPrice: offerPrice,
        offerAvailability: offerAvailability,
        offerDeliveryDays: offerDeliveryDays,
      ));
    });

    test('doit déléguer entièrement au datasource', () async {
      // arrange
      when(mockRemoteDataSource.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.text,
        attachments: const [],
        metadata: const {},
      )).thenAnswer((_) async => tMessage);

      // act
      await repository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
      );

      // assert
      verify(mockRemoteDataSource.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.text,
        attachments: const [],
        metadata: const {},
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('markMessagesAsRead', () {
    test('doit retourner void quand le marquage réussit', () async {
      // arrange
      when(mockRemoteDataSource.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      )).thenAnswer((_) async {});

      // act
      final result = await repository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      );

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée',
        () async {
      // arrange
      when(mockRemoteDataSource.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      )).thenThrow(const ServerException('Erreur serveur'));

      // act
      final result = await repository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      );

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit déléguer entièrement au datasource', () async {
      // arrange
      when(mockRemoteDataSource.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      )).thenAnswer((_) async {});

      // act
      await repository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      );

      // assert
      verify(mockRemoteDataSource.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('deleteConversation', () {
    test('doit retourner void quand la suppression réussit', () async {
      // arrange
      when(mockRemoteDataSource.deleteConversation(
        conversationId: tConversationId,
      )).thenAnswer((_) async {});

      // act
      final result = await repository.deleteConversation(
        conversationId: tConversationId,
      );

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.deleteConversation(
        conversationId: tConversationId,
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée',
        () async {
      // arrange
      when(mockRemoteDataSource.deleteConversation(
        conversationId: tConversationId,
      )).thenThrow(const ServerException('Erreur serveur'));

      // act
      final result = await repository.deleteConversation(
        conversationId: tConversationId,
      );

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit déléguer entièrement au datasource', () async {
      // arrange
      when(mockRemoteDataSource.deleteConversation(
        conversationId: tConversationId,
      )).thenAnswer((_) async {});

      // act
      await repository.deleteConversation(
        conversationId: tConversationId,
      );

      // assert
      verify(mockRemoteDataSource.deleteConversation(
        conversationId: tConversationId,
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('blockConversation', () {
    test('doit retourner void quand le blocage réussit', () async {
      // arrange
      when(mockRemoteDataSource.blockConversation(
        conversationId: tConversationId,
      )).thenAnswer((_) async {});

      // act
      final result = await repository.blockConversation(
        conversationId: tConversationId,
      );

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.blockConversation(
        conversationId: tConversationId,
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée',
        () async {
      // arrange
      when(mockRemoteDataSource.blockConversation(
        conversationId: tConversationId,
      )).thenThrow(const ServerException('Erreur serveur'));

      // act
      final result = await repository.blockConversation(
        conversationId: tConversationId,
      );

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit déléguer entièrement au datasource', () async {
      // arrange
      when(mockRemoteDataSource.blockConversation(
        conversationId: tConversationId,
      )).thenAnswer((_) async {});

      // act
      await repository.blockConversation(
        conversationId: tConversationId,
      );

      // assert
      verify(mockRemoteDataSource.blockConversation(
        conversationId: tConversationId,
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('closeConversation', () {
    test('doit retourner void quand la fermeture réussit', () async {
      // arrange
      when(mockRemoteDataSource.updateConversationStatus(
        conversationId: tConversationId,
        status: ConversationStatus.closed,
      )).thenAnswer((_) async {});

      // act
      final result = await repository.closeConversation(
        conversationId: tConversationId,
      );

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.updateConversationStatus(
        conversationId: tConversationId,
        status: ConversationStatus.closed,
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('doit retourner ServerFailure quand ServerException est lancée',
        () async {
      // arrange
      when(mockRemoteDataSource.updateConversationStatus(
        conversationId: tConversationId,
        status: ConversationStatus.closed,
      )).thenThrow(const ServerException('Erreur serveur'));

      // act
      final result = await repository.closeConversation(
        conversationId: tConversationId,
      );

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit déléguer entièrement au datasource', () async {
      // arrange
      when(mockRemoteDataSource.updateConversationStatus(
        conversationId: tConversationId,
        status: ConversationStatus.closed,
      )).thenAnswer((_) async {});

      // act
      await repository.closeConversation(
        conversationId: tConversationId,
      );

      // assert
      verify(mockRemoteDataSource.updateConversationStatus(
        conversationId: tConversationId,
        status: ConversationStatus.closed,
      ));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });
}
