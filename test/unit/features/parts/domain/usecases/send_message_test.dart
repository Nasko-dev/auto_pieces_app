import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/conversations_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/send_message.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'send_message_test.mocks.dart';

@GenerateMocks([ConversationsRepository])
void main() {
  late SendMessage usecase;
  late MockConversationsRepository mockRepository;

  setUp(() {
    mockRepository = MockConversationsRepository();
    usecase = SendMessage(mockRepository);
  });

  const tConversationId = 'conversation123';
  const tSenderId = 'sender456';
  const tContent = 'Salut ! J\'ai cette pièce disponible.';
  const tAttachments = ['photo1.jpg', 'photo2.jpg'];
  final tMetadata = {'isUrgent': true, 'referenceNumber': 'REF123'};
  const tOfferPrice = 150.0;
  const tOfferAvailability = 'available';
  const tOfferDeliveryDays = 3;

  final tTextParams = SendMessageParams(
    conversationId: tConversationId,
    senderId: tSenderId,
    content: tContent,
    messageType: MessageType.text,
  );

  final tImageParams = SendMessageParams(
    conversationId: tConversationId,
    senderId: tSenderId,
    content: 'Voici les photos de la pièce',
    messageType: MessageType.image,
    attachments: tAttachments,
  );

  final tOfferParams = SendMessageParams(
    conversationId: tConversationId,
    senderId: tSenderId,
    content: 'Voici mon offre pour cette pièce',
    messageType: MessageType.offer,
    offerPrice: tOfferPrice,
    offerAvailability: tOfferAvailability,
    offerDeliveryDays: tOfferDeliveryDays,
  );

  final tComplexParams = SendMessageParams(
    conversationId: tConversationId,
    senderId: tSenderId,
    content: tContent,
    messageType: MessageType.text,
    attachments: tAttachments,
    metadata: tMetadata,
  );

  final tMessage = Message(
    id: 'message123',
    conversationId: tConversationId,
    senderId: tSenderId,
    senderType: MessageSenderType.seller,
    content: tContent,
    messageType: MessageType.text,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tImageMessage = Message(
    id: 'message124',
    conversationId: tConversationId,
    senderId: tSenderId,
    senderType: MessageSenderType.seller,
    content: 'Voici les photos de la pièce',
    messageType: MessageType.image,
    attachments: tAttachments,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tOfferMessage = Message(
    id: 'message125',
    conversationId: tConversationId,
    senderId: tSenderId,
    senderType: MessageSenderType.seller,
    content: 'Voici mon offre pour cette pièce',
    messageType: MessageType.offer,
    offerPrice: tOfferPrice,
    offerAvailability: tOfferAvailability,
    offerDeliveryDays: tOfferDeliveryDays,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('SendMessage', () {
    test('doit retourner Message quand l\'envoi d\'un message texte réussit',
        () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(tMessage));

      // act
      final result = await usecase(tTextParams);

      // assert
      expect(result, Right(tMessage));
      verify(mockRepository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.text,
        attachments: const [],
        metadata: const {},
        offerPrice: null,
        offerAvailability: null,
        offerDeliveryDays: null,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner Message quand l\'envoi d\'un message image réussit',
        () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(tImageMessage));

      // act
      final result = await usecase(tImageParams);

      // assert
      expect(result, Right(tImageMessage));
      verify(mockRepository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: 'Voici les photos de la pièce',
        messageType: MessageType.image,
        attachments: tAttachments,
        metadata: const {},
        offerPrice: null,
        offerAvailability: null,
        offerDeliveryDays: null,
      ));
    });

    test('doit retourner Message quand l\'envoi d\'une offre réussit',
        () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(tOfferMessage));

      // act
      final result = await usecase(tOfferParams);

      // assert
      expect(result, Right(tOfferMessage));
      verify(mockRepository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: 'Voici mon offre pour cette pièce',
        messageType: MessageType.offer,
        attachments: const [],
        metadata: const {},
        offerPrice: tOfferPrice,
        offerAvailability: tOfferAvailability,
        offerDeliveryDays: tOfferDeliveryDays,
      ));
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé',
        () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => const Left(AuthFailure('Accès non autorisé')));

      // act
      final result = await usecase(tTextParams);

      // assert
      expect(result, const Left(AuthFailure('Accès non autorisé')));
      verify(mockRepository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.text,
        attachments: const [],
        metadata: const {},
        offerPrice: null,
        offerAvailability: null,
        offerDeliveryDays: null,
      ));
    });

    test('doit retourner ValidationFailure quand la conversation n\'existe pas',
        () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async =>
          const Left(ValidationFailure('Conversation non trouvée')));

      // act
      final result = await usecase(tTextParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation non trouvée')));
    });

    test('doit retourner ValidationFailure quand la conversation est fermée',
        () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async =>
          const Left(ValidationFailure('Cette conversation est fermée')));

      // act
      final result = await usecase(tTextParams);

      // assert
      expect(result,
          const Left(ValidationFailure('Cette conversation est fermée')));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tTextParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau',
        () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer(
          (_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tTextParams);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
    });

    test('doit passer tous les paramètres au repository correctement',
        () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(tMessage));

      // act
      await usecase(tComplexParams);

      // assert
      verify(mockRepository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.text,
        attachments: tAttachments,
        metadata: tMetadata,
        offerPrice: null,
        offerAvailability: null,
        offerDeliveryDays: null,
      ));
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tTextParams);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tTextParams),
        throwsA(isA<Exception>()),
      );
    });

    test('doit gérer les messages avec différents types de contenu', () async {
      // arrange
      final longContentParams = SendMessageParams(
        conversationId: tConversationId,
        senderId: tSenderId,
        content:
            'Très ' * 200 + 'long message avec beaucoup de contenu détaillé',
        messageType: MessageType.text,
      );

      final longContentMessage = tMessage.copyWith(
        content: longContentParams.content,
      );

      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(longContentMessage));

      // act
      final result = await usecase(longContentParams);

      // assert
      expect(result, Right(longContentMessage));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (message) => expect(message.content.length, greaterThan(1000)),
      );
    });

    test('doit gérer les messages avec de nombreuses pièces jointes', () async {
      // arrange
      final manyAttachments = List.generate(20, (i) => 'photo$i.jpg');
      final manyAttachmentsParams = SendMessageParams(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: 'Message avec beaucoup de photos',
        messageType: MessageType.image,
        attachments: manyAttachments,
      );

      final manyAttachmentsMessage = tImageMessage.copyWith(
        content: 'Message avec beaucoup de photos',
        attachments: manyAttachments,
      );

      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(manyAttachmentsMessage));

      // act
      final result = await usecase(manyAttachmentsParams);

      // assert
      expect(result, Right(manyAttachmentsMessage));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (message) => expect(message.attachments.length, 20),
      );
    });

    test('doit gérer les offres avec prix zéro', () async {
      // arrange
      final freePriceParams = SendMessageParams(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: 'Pièce offerte gratuitement',
        messageType: MessageType.offer,
        offerPrice: 0.0,
        offerAvailability: 'available',
        offerDeliveryDays: 1,
      );

      final freePriceMessage = tOfferMessage.copyWith(
        content: 'Pièce offerte gratuitement',
        offerPrice: 0.0,
        offerDeliveryDays: 1,
      );

      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(freePriceMessage));

      // act
      final result = await usecase(freePriceParams);

      // assert
      expect(result, Right(freePriceMessage));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (message) => expect(message.offerPrice, 0.0),
      );
    });

    test('doit gérer les métadonnées complexes', () async {
      // arrange
      final complexMetadata = {
        'isUrgent': true,
        'priority': 'high',
        'referenceNumber': 'REF-2024-001',
        'estimatedWeight': 5.5,
        'dimensions': {'length': 30, 'width': 20, 'height': 15},
        'condition': 'excellent',
        'warranty': {'duration': 12, 'type': 'full'},
      };

      final complexMetadataParams = SendMessageParams(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: 'Message avec métadonnées complexes',
        messageType: MessageType.text,
        metadata: complexMetadata,
      );

      final complexMetadataMessage = tMessage.copyWith(
        content: 'Message avec métadonnées complexes',
        metadata: complexMetadata,
      );

      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(complexMetadataMessage));

      // act
      final result = await usecase(complexMetadataParams);

      // assert
      expect(result, Right(complexMetadataMessage));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (message) => expect(message.metadata.keys.length, 7),
      );
    });

    test('doit gérer l\'envoi de messages pour différentes conversations',
        () async {
      // arrange
      final conversation1Params = SendMessageParams(
        conversationId: 'conv1',
        senderId: tSenderId,
        content: 'Message conversation 1',
      );

      final conversation2Params = SendMessageParams(
        conversationId: 'conv2',
        senderId: tSenderId,
        content: 'Message conversation 2',
      );

      final message1 = tMessage.copyWith(
        conversationId: 'conv1',
        content: 'Message conversation 1',
      );

      final message2 = tMessage.copyWith(
        conversationId: 'conv2',
        content: 'Message conversation 2',
      );

      when(mockRepository.sendMessage(
        conversationId: 'conv1',
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(message1));

      when(mockRepository.sendMessage(
        conversationId: 'conv2',
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(message2));

      // act
      final result1 = await usecase(conversation1Params);
      final result2 = await usecase(conversation2Params);

      // assert
      expect(result1, Right(message1));
      expect(result2, Right(message2));
    });

    test('doit déléguer entièrement au repository', () async {
      // arrange
      when(mockRepository.sendMessage(
        conversationId: anyNamed('conversationId'),
        senderId: anyNamed('senderId'),
        content: anyNamed('content'),
        messageType: anyNamed('messageType'),
        attachments: anyNamed('attachments'),
        metadata: anyNamed('metadata'),
        offerPrice: anyNamed('offerPrice'),
        offerAvailability: anyNamed('offerAvailability'),
        offerDeliveryDays: anyNamed('offerDeliveryDays'),
      )).thenAnswer((_) async => Right(tMessage));

      // act
      final result = await usecase(tTextParams);

      // assert
      expect(result, Right(tMessage));
      // Vérifier que l'use case ne fait que déléguer au repository
      verify(mockRepository.sendMessage(
        conversationId: tConversationId,
        senderId: tSenderId,
        content: tContent,
        messageType: MessageType.text,
        attachments: const [],
        metadata: const {},
        offerPrice: null,
        offerAvailability: null,
        offerDeliveryDays: null,
      ));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
