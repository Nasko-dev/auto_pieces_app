import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/conversations_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_conversation_messages.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_conversation_messages_test.mocks.dart';

@GenerateMocks([ConversationsRepository])
void main() {
  late GetConversationMessages usecase;
  late MockConversationsRepository mockRepository;

  setUp(() {
    mockRepository = MockConversationsRepository();
    usecase = GetConversationMessages(mockRepository);
  });

  const tConversationId = 'conversation123';
  final tParams =
      GetConversationMessagesParams(conversationId: tConversationId);

  final tMessage1 = Message(
    id: 'message1',
    conversationId: tConversationId,
    senderId: 'user123',
    senderType: MessageSenderType.user,
    content: 'Bonjour, je cherche cette pièce',
    messageType: MessageType.text,
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  final tMessage2 = Message(
    id: 'message2',
    conversationId: tConversationId,
    senderId: 'seller456',
    senderType: MessageSenderType.seller,
    content: 'Oui, je l\'ai en stock. Voici les photos',
    messageType: MessageType.image,
    attachments: ['photo1.jpg', 'photo2.jpg'],
    isRead: true,
    readAt: DateTime.now().subtract(const Duration(hours: 1)),
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  final tMessage3 = Message(
    id: 'message3',
    conversationId: tConversationId,
    senderId: 'seller456',
    senderType: MessageSenderType.seller,
    content: 'Voici mon offre finale',
    messageType: MessageType.offer,
    offerPrice: 120.0,
    offerAvailability: 'available',
    offerDeliveryDays: 2,
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
  );

  final tMessagesList = [tMessage1, tMessage2, tMessage3];

  group('GetConversationMessages', () {
    test('doit retourner une liste de Messages quand la récupération réussit',
        () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(tMessagesList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tMessagesList));
      verify(mockRepository.getConversationMessages(
          conversationId: tConversationId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner une liste vide quand aucun message n\'existe',
        () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) => expect(messages.isEmpty, true),
      );
      verify(mockRepository.getConversationMessages(
          conversationId: tConversationId));
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé',
        () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => const Left(
              AuthFailure('Accès non autorisé à cette conversation')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result,
          const Left(AuthFailure('Accès non autorisé à cette conversation')));
      verify(mockRepository.getConversationMessages(
          conversationId: tConversationId));
    });

    test('doit retourner ValidationFailure quand la conversation n\'existe pas',
        () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async =>
              const Left(ValidationFailure('Conversation non trouvée')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation non trouvée')));
      verify(mockRepository.getConversationMessages(
          conversationId: tConversationId));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getConversationMessages(
          conversationId: tConversationId));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau',
        () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async =>
              const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getConversationMessages(
          conversationId: tConversationId));
    });

    test('doit appeler le repository avec le bon conversationId', () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(tMessagesList));

      // act
      await usecase(tParams);

      // assert
      final captured = verify(mockRepository.getConversationMessages(
              conversationId: captureAnyNamed('conversationId')))
          .captured;
      expect(captured.first, tConversationId);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tParams),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner les messages avec toutes les propriétés correctes',
        () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(tMessagesList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) {
          expect(messages.length, 3);

          // Premier message (texte)
          final firstMessage = messages[0];
          expect(firstMessage.id, 'message1');
          expect(firstMessage.conversationId, tConversationId);
          expect(firstMessage.senderId, 'user123');
          expect(firstMessage.senderType, MessageSenderType.user);
          expect(firstMessage.content, 'Bonjour, je cherche cette pièce');
          expect(firstMessage.messageType, MessageType.text);
          expect(firstMessage.isRead, false);
          expect(firstMessage.readAt, null);

          // Deuxième message (image)
          final secondMessage = messages[1];
          expect(secondMessage.messageType, MessageType.image);
          expect(secondMessage.attachments.length, 2);
          expect(secondMessage.isRead, true);
          expect(secondMessage.readAt, isNotNull);

          // Troisième message (offre)
          final thirdMessage = messages[2];
          expect(thirdMessage.messageType, MessageType.offer);
          expect(thirdMessage.offerPrice, 120.0);
          expect(thirdMessage.offerAvailability, 'available');
          expect(thirdMessage.offerDeliveryDays, 2);
        },
      );
    });

    test('doit gérer les messages avec différents types de contenu', () async {
      // arrange
      final textMessage = Message(
        id: 'text1',
        conversationId: tConversationId,
        senderId: 'user1',
        senderType: MessageSenderType.user,
        content: 'Message texte simple',
        messageType: MessageType.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final imageMessage = Message(
        id: 'image1',
        conversationId: tConversationId,
        senderId: 'seller1',
        senderType: MessageSenderType.seller,
        content: 'Voici les photos',
        messageType: MessageType.image,
        attachments: ['photo1.jpg', 'photo2.jpg', 'photo3.jpg'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final offerMessage = Message(
        id: 'offer1',
        conversationId: tConversationId,
        senderId: 'seller1',
        senderType: MessageSenderType.seller,
        content: 'Mon offre finale',
        messageType: MessageType.offer,
        offerPrice: 199.99,
        offerAvailability: 'order_needed',
        offerDeliveryDays: 7,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mixedMessagesList = [textMessage, imageMessage, offerMessage];

      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(mixedMessagesList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) {
          expect(messages[0].messageType, MessageType.text);
          expect(messages[0].attachments.isEmpty, true);
          expect(messages[0].offerPrice, null);

          expect(messages[1].messageType, MessageType.image);
          expect(messages[1].attachments.length, 3);
          expect(messages[1].offerPrice, null);

          expect(messages[2].messageType, MessageType.offer);
          expect(messages[2].offerPrice, 199.99);
          expect(messages[2].offerAvailability, 'order_needed');
          expect(messages[2].offerDeliveryDays, 7);
        },
      );
    });

    test('doit gérer les messages avec statuts de lecture différents',
        () async {
      // arrange
      final unreadMessage = Message(
        id: 'unread1',
        conversationId: tConversationId,
        senderId: 'sender1',
        senderType: MessageSenderType.seller,
        content: 'Message non lu',
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final readMessage = Message(
        id: 'read1',
        conversationId: tConversationId,
        senderId: 'sender2',
        senderType: MessageSenderType.user,
        content: 'Message lu',
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(minutes: 10)),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final readStatusList = [unreadMessage, readMessage];

      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(readStatusList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) {
          expect(messages[0].isRead, false);
          expect(messages[0].readAt, null);

          expect(messages[1].isRead, true);
          expect(messages[1].readAt, isNotNull);
        },
      );
    });

    test('doit gérer les conversations avec de nombreux messages', () async {
      // arrange
      final manyMessages = List.generate(
          100,
          (index) => Message(
                id: 'message$index',
                conversationId: tConversationId,
                senderId: index % 2 == 0 ? 'user123' : 'seller456',
                senderType: index % 2 == 0
                    ? MessageSenderType.user
                    : MessageSenderType.seller,
                content: 'Message numéro $index',
                messageType: MessageType.text,
                isRead: index < 80, // Les 80 premiers sont lus
                readAt: index < 80
                    ? DateTime.now().subtract(Duration(minutes: 100 - index))
                    : null,
                createdAt:
                    DateTime.now().subtract(Duration(minutes: 100 - index)),
                updatedAt:
                    DateTime.now().subtract(Duration(minutes: 100 - index)),
              ));

      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(manyMessages));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) {
          expect(messages.length, 100);

          // Vérifier quelques messages spécifiques
          expect(messages[0].content, 'Message numéro 0');
          expect(messages[99].content, 'Message numéro 99');

          // Vérifier le statut de lecture
          final readMessages = messages.where((m) => m.isRead).length;
          expect(readMessages, 80);
        },
      );
    });

    test('doit gérer les messages avec métadonnées complexes', () async {
      // arrange
      final messageWithMetadata = Message(
        id: 'meta1',
        conversationId: tConversationId,
        senderId: 'seller123',
        senderType: MessageSenderType.seller,
        content: 'Message avec métadonnées',
        messageType: MessageType.text,
        metadata: {
          'isUrgent': true,
          'priority': 'high',
          'attachedPartInfo': {
            'partNumber': 'P123456',
            'brand': 'Peugeot',
            'compatibility': ['308', '3008', '5008'],
          },
          'estimatedValue': 250.0,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right([messageWithMetadata]));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) {
          expect(messages.length, 1);
          expect(messages[0].metadata['isUrgent'], true);
          expect(messages[0].metadata['priority'], 'high');
          expect(messages[0].metadata['estimatedValue'], 250.0);
        },
      );
    });

    test('doit fonctionner avec différents conversationId', () async {
      // arrange
      const conversation1Id = 'conv1';
      const conversation2Id = 'conv2';

      final params1 =
          GetConversationMessagesParams(conversationId: conversation1Id);
      final params2 =
          GetConversationMessagesParams(conversationId: conversation2Id);

      when(mockRepository.getConversationMessages(
              conversationId: conversation1Id))
          .thenAnswer((_) async => Right([tMessage1]));
      when(mockRepository.getConversationMessages(
              conversationId: conversation2Id))
          .thenAnswer((_) async => const Right([]));

      // act
      final result1 = await usecase(params1);
      final result2 = await usecase(params2);

      // assert
      expect(result1.isRight(), true);
      result1.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) => expect(messages.length, 1),
      );
      expect(result2.isRight(), true);
      result2.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) => expect(messages.isEmpty, true),
      );
      verify(mockRepository.getConversationMessages(
          conversationId: conversation1Id));
      verify(mockRepository.getConversationMessages(
          conversationId: conversation2Id));
    });

    test('doit retourner les mêmes messages à chaque appel (cohérence)',
        () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(tMessagesList));

      // act
      final result1 = await usecase(tParams);
      final result2 = await usecase(tParams);

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .called(2);
    });

    test('doit gérer les messages avec offres variées', () async {
      // arrange
      final offerWithoutPrice = Message(
        id: 'offer_no_price',
        conversationId: tConversationId,
        senderId: 'seller123',
        senderType: MessageSenderType.seller,
        content: 'Contactez-moi pour le prix',
        messageType: MessageType.offer,
        offerAvailability: 'available',
        offerDeliveryDays: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final offerZeroPrice = Message(
        id: 'offer_zero',
        conversationId: tConversationId,
        senderId: 'seller456',
        senderType: MessageSenderType.seller,
        content: 'Pièce offerte',
        messageType: MessageType.offer,
        offerPrice: 0.0,
        offerAvailability: 'available',
        offerDeliveryDays: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final variousOffersList = [offerWithoutPrice, offerZeroPrice];

      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(variousOffersList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (messages) {
          expect(messages[0].offerPrice, null);
          expect(messages[0].offerAvailability, 'available');
          expect(messages[0].offerDeliveryDays, 5);

          expect(messages[1].offerPrice, 0.0);
          expect(messages[1].offerAvailability, 'available');
          expect(messages[1].offerDeliveryDays, 1);
        },
      );
    });

    test('doit déléguer entièrement au repository', () async {
      // arrange
      when(mockRepository.getConversationMessages(
              conversationId: tConversationId))
          .thenAnswer((_) async => Right(tMessagesList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tMessagesList));
      // Vérifier que l'use case ne fait que déléguer au repository
      verify(mockRepository.getConversationMessages(
          conversationId: tConversationId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
