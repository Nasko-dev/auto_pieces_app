import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/conversations_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_conversations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_conversations_test.mocks.dart';

@GenerateMocks([ConversationsRepository])
void main() {
  late GetConversations usecase;
  late MockConversationsRepository mockRepository;

  setUp(() {
    mockRepository = MockConversationsRepository();
    usecase = GetConversations(mockRepository);
  });

  const tUserId = 'user123';
  final tParams = GetConversationsParams(userId: tUserId);

  final tConversation1 = Conversation(
    id: 'conv1',
    requestId: 'request1',
    userId: tUserId,
    sellerId: 'seller1',
    status: ConversationStatus.active,
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    sellerName: 'Jean Dupont',
    sellerCompany: 'Pièces Auto Pro',
    sellerPhone: '+33123456789',
    userName: 'Marie Martin',
    userDisplayName: 'Marie M.',
    requestTitle: 'Recherche moteur Peugeot 308',
    lastMessageContent: 'J\'ai cette pièce disponible',
    lastMessageSenderType: MessageSenderType.seller,
    lastMessageCreatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 2,
    totalMessages: 15,
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2018,
    vehicleEngine: '1.6 BlueHDi',
    partType: 'engine',
    particulierFirstName: 'Marie',
  );

  final tConversation2 = Conversation(
    id: 'conv2',
    requestId: 'request2',
    userId: tUserId,
    sellerId: 'seller2',
    status: ConversationStatus.active,
    lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    sellerName: 'Pierre Durand',
    sellerCompany: 'Auto Recyclage',
    requestTitle: 'Pare-chocs Renault Clio',
    lastMessageContent: 'Quand pouvez-vous venir récupérer ?',
    lastMessageSenderType: MessageSenderType.user,
    lastMessageCreatedAt: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
    totalMessages: 8,
    vehicleBrand: 'Renault',
    vehicleModel: 'Clio',
    vehicleYear: 2020,
    partType: 'body',
    particulierFirstName: 'Marie',
  );

  final tConversation3 = Conversation(
    id: 'conv3',
    requestId: 'request3',
    userId: tUserId,
    sellerId: 'seller3',
    status: ConversationStatus.closed,
    lastMessageAt: DateTime.now().subtract(const Duration(days: 7)),
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    sellerName: 'Sophie Leclerc',
    requestTitle: 'Jantes BMW X3',
    lastMessageContent: 'Transaction terminée, merci !',
    lastMessageSenderType: MessageSenderType.user,
    lastMessageCreatedAt: DateTime.now().subtract(const Duration(days: 7)),
    unreadCount: 0,
    totalMessages: 12,
    vehicleBrand: 'BMW',
    vehicleModel: 'X3',
    vehicleYear: 2019,
    partType: 'wheels',
    particulierFirstName: 'Marie',
  );

  final tConversationsList = [tConversation1, tConversation2, tConversation3];

  group('GetConversations', () {
    test('doit retourner une liste de Conversations quand la récupération réussit', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(tConversationsList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tConversationsList));
      verify(mockRepository.getConversations(userId: tUserId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner une liste vide quand aucune conversation n\'existe', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) => expect(conversations.isEmpty, true),
      );
      verify(mockRepository.getConversations(userId: tUserId));
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas connecté', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => const Left(AuthFailure('Utilisateur non connecté')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(AuthFailure('Utilisateur non connecté')));
      verify(mockRepository.getConversations(userId: tUserId));
    });

    test('doit retourner ValidationFailure quand l\'utilisateur n\'existe pas', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => const Left(ValidationFailure('Utilisateur non trouvé')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(ValidationFailure('Utilisateur non trouvé')));
      verify(mockRepository.getConversations(userId: tUserId));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getConversations(userId: tUserId));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getConversations(userId: tUserId));
    });

    test('doit appeler le repository avec le bon userId', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(tConversationsList));

      // act
      await usecase(tParams);

      // assert
      final captured = verify(mockRepository.getConversations(userId: captureAnyNamed('userId'))).captured;
      expect(captured.first, tUserId);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tParams),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner les conversations avec toutes les propriétés correctes', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(tConversationsList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) {
          expect(conversations.length, 3);

          // Première conversation (active avec messages non lus)
          final firstConv = conversations[0];
          expect(firstConv.id, 'conv1');
          expect(firstConv.requestId, 'request1');
          expect(firstConv.userId, tUserId);
          expect(firstConv.sellerId, 'seller1');
          expect(firstConv.status, ConversationStatus.active);
          expect(firstConv.sellerName, 'Jean Dupont');
          expect(firstConv.sellerCompany, 'Pièces Auto Pro');
          expect(firstConv.userName, 'Marie Martin');
          expect(firstConv.requestTitle, 'Recherche moteur Peugeot 308');
          expect(firstConv.lastMessageContent, 'J\'ai cette pièce disponible');
          expect(firstConv.lastMessageSenderType, MessageSenderType.seller);
          expect(firstConv.unreadCount, 2);
          expect(firstConv.totalMessages, 15);
          expect(firstConv.vehicleBrand, 'Peugeot');
          expect(firstConv.vehicleModel, '308');
          expect(firstConv.vehicleYear, 2018);
          expect(firstConv.partType, 'engine');

          // Deuxième conversation (active sans messages non lus)
          final secondConv = conversations[1];
          expect(secondConv.status, ConversationStatus.active);
          expect(secondConv.unreadCount, 0);
          expect(secondConv.lastMessageSenderType, MessageSenderType.user);
          expect(secondConv.vehicleBrand, 'Renault');
          expect(secondConv.partType, 'body');

          // Troisième conversation (fermée)
          final thirdConv = conversations[2];
          expect(thirdConv.status, ConversationStatus.closed);
          expect(thirdConv.vehicleBrand, 'BMW');
          expect(thirdConv.partType, 'wheels');
        },
      );
    });

    test('doit gérer les conversations avec différents statuts', () async {
      // arrange
      final activeConv = Conversation(
        id: 'active1',
        requestId: 'req1',
        userId: tUserId,
        sellerId: 'seller1',
        status: ConversationStatus.active,
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final closedConv = Conversation(
        id: 'closed1',
        requestId: 'req2',
        userId: tUserId,
        sellerId: 'seller2',
        status: ConversationStatus.closed,
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final deletedConv = Conversation(
        id: 'deleted1',
        requestId: 'req3',
        userId: tUserId,
        sellerId: 'seller3',
        status: ConversationStatus.deletedByUser,
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final blockedConv = Conversation(
        id: 'blocked1',
        requestId: 'req4',
        userId: tUserId,
        sellerId: 'seller4',
        status: ConversationStatus.blockedByUser,
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final statusVariationsList = [activeConv, closedConv, deletedConv, blockedConv];

      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(statusVariationsList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) {
          expect(conversations[0].status, ConversationStatus.active);
          expect(conversations[1].status, ConversationStatus.closed);
          expect(conversations[2].status, ConversationStatus.deletedByUser);
          expect(conversations[3].status, ConversationStatus.blockedByUser);
        },
      );
    });

    test('doit gérer les conversations avec différents comptes de messages non lus', () async {
      // arrange
      final noUnreadConv = Conversation(
        id: 'no_unread',
        requestId: 'req1',
        userId: tUserId,
        sellerId: 'seller1',
        unreadCount: 0,
        totalMessages: 5,
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final someUnreadConv = Conversation(
        id: 'some_unread',
        requestId: 'req2',
        userId: tUserId,
        sellerId: 'seller2',
        unreadCount: 3,
        totalMessages: 10,
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final manyUnreadConv = Conversation(
        id: 'many_unread',
        requestId: 'req3',
        userId: tUserId,
        sellerId: 'seller3',
        unreadCount: 25,
        totalMessages: 50,
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final unreadVariationsList = [noUnreadConv, someUnreadConv, manyUnreadConv];

      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(unreadVariationsList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) {
          expect(conversations[0].unreadCount, 0);
          expect(conversations[0].totalMessages, 5);

          expect(conversations[1].unreadCount, 3);
          expect(conversations[1].totalMessages, 10);

          expect(conversations[2].unreadCount, 25);
          expect(conversations[2].totalMessages, 50);
        },
      );
    });

    test('doit gérer les conversations avec informations incomplètes', () async {
      // arrange
      final minimalConv = Conversation(
        id: 'minimal',
        requestId: 'req_minimal',
        userId: tUserId,
        sellerId: 'seller_minimal',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final completeConv = Conversation(
        id: 'complete',
        requestId: 'req_complete',
        userId: tUserId,
        sellerId: 'seller_complete',
        sellerName: 'Vendeur Complet',
        sellerCompany: 'Société Complète',
        sellerAvatarUrl: 'https://example.com/avatar.jpg',
        sellerPhone: '+33987654321',
        userName: 'Utilisateur Complet',
        userDisplayName: 'User C.',
        userAvatarUrl: 'https://example.com/user_avatar.jpg',
        requestTitle: 'Demande complète',
        lastMessageContent: 'Message complet',
        lastMessageSenderType: MessageSenderType.seller,
        vehicleBrand: 'Toyota',
        vehicleModel: 'Corolla',
        vehicleYear: 2021,
        vehicleEngine: '1.8 Hybrid',
        partType: 'engine',
        particulierFirstName: 'Jean',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final infoVariationsList = [minimalConv, completeConv];

      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(infoVariationsList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) {
          // Conversation minimale
          expect(conversations[0].sellerName, null);
          expect(conversations[0].sellerCompany, null);
          expect(conversations[0].vehicleBrand, null);
          expect(conversations[0].requestTitle, null);

          // Conversation complète
          expect(conversations[1].sellerName, 'Vendeur Complet');
          expect(conversations[1].sellerCompany, 'Société Complète');
          expect(conversations[1].vehicleBrand, 'Toyota');
          expect(conversations[1].vehicleModel, 'Corolla');
          expect(conversations[1].requestTitle, 'Demande complète');
        },
      );
    });

    test('doit gérer les utilisateurs avec de nombreuses conversations', () async {
      // arrange
      final manyConversations = List.generate(50, (index) => Conversation(
        id: 'conv$index',
        requestId: 'request$index',
        userId: tUserId,
        sellerId: 'seller$index',
        status: index % 3 == 0 ? ConversationStatus.closed : ConversationStatus.active,
        sellerName: 'Vendeur $index',
        requestTitle: 'Demande $index',
        unreadCount: index % 5, // 0-4 messages non lus
        totalMessages: index + 1,
        lastMessageAt: DateTime.now().subtract(Duration(hours: index)),
        createdAt: DateTime.now().subtract(Duration(days: index + 1)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
      ));

      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(manyConversations));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) {
          expect(conversations.length, 50);

          // Vérifier quelques conversations spécifiques
          expect(conversations[0].id, 'conv0');
          expect(conversations[0].status, ConversationStatus.closed);
          expect(conversations[49].id, 'conv49');

          // Vérifier la distribution des statuts
          final closedCount = conversations.where((c) => c.status == ConversationStatus.closed).length;
          expect(closedCount, greaterThan(10)); // Environ 1/3 des conversations
        },
      );
    });

    test('doit gérer les conversations avec différents types de véhicules', () async {
      // arrange
      final carConv = Conversation(
        id: 'car1',
        requestId: 'req_car',
        userId: tUserId,
        sellerId: 'seller_car',
        vehicleBrand: 'Peugeot',
        vehicleModel: '308',
        vehicleYear: 2020,
        vehicleEngine: '1.2 PureTech',
        partType: 'engine',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final truckConv = Conversation(
        id: 'truck1',
        requestId: 'req_truck',
        userId: tUserId,
        sellerId: 'seller_truck',
        vehicleBrand: 'Mercedes',
        vehicleModel: 'Sprinter',
        vehicleYear: 2019,
        vehicleEngine: '2.1 CDI',
        partType: 'body',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final motorcycleConv = Conversation(
        id: 'moto1',
        requestId: 'req_moto',
        userId: tUserId,
        sellerId: 'seller_moto',
        vehicleBrand: 'Yamaha',
        vehicleModel: 'MT-07',
        vehicleYear: 2022,
        partType: 'engine',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final vehicleTypesList = [carConv, truckConv, motorcycleConv];

      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(vehicleTypesList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) {
          expect(conversations[0].vehicleBrand, 'Peugeot');
          expect(conversations[0].vehicleModel, '308');
          expect(conversations[0].partType, 'engine');

          expect(conversations[1].vehicleBrand, 'Mercedes');
          expect(conversations[1].vehicleModel, 'Sprinter');
          expect(conversations[1].partType, 'body');

          expect(conversations[2].vehicleBrand, 'Yamaha');
          expect(conversations[2].vehicleModel, 'MT-07');
          expect(conversations[2].partType, 'engine');
        },
      );
    });

    test('doit fonctionner avec différents userId', () async {
      // arrange
      const user1Id = 'user1';
      const user2Id = 'user2';

      final params1 = GetConversationsParams(userId: user1Id);
      final params2 = GetConversationsParams(userId: user2Id);

      when(mockRepository.getConversations(userId: user1Id))
          .thenAnswer((_) async => Right([tConversation1]));
      when(mockRepository.getConversations(userId: user2Id))
          .thenAnswer((_) async => const Right([]));

      // act
      final result1 = await usecase(params1);
      final result2 = await usecase(params2);

      // assert
      expect(result1.isRight(), true);
      result1.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) => expect(conversations.length, 1),
      );
      expect(result2.isRight(), true);
      result2.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) => expect(conversations.isEmpty, true),
      );
      verify(mockRepository.getConversations(userId: user1Id));
      verify(mockRepository.getConversations(userId: user2Id));
    });

    test('doit retourner les mêmes conversations à chaque appel (cohérence)', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(tConversationsList));

      // act
      final result1 = await usecase(tParams);
      final result2 = await usecase(tParams);

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getConversations(userId: tUserId)).called(2);
    });

    test('doit gérer les conversations triées par date de dernier message', () async {
      // arrange
      final oldConv = Conversation(
        id: 'old',
        requestId: 'req_old',
        userId: tUserId,
        sellerId: 'seller_old',
        lastMessageAt: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      );

      final recentConv = Conversation(
        id: 'recent',
        requestId: 'req_recent',
        userId: tUserId,
        sellerId: 'seller_recent',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final sortedList = [recentConv, oldConv]; // Plus récent en premier

      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(sortedList));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (conversations) {
          expect(conversations[0].id, 'recent');
          expect(conversations[1].id, 'old');
          expect(conversations[0].lastMessageAt.isAfter(conversations[1].lastMessageAt), true);
        },
      );
    });

    test('doit déléguer entièrement au repository', () async {
      // arrange
      when(mockRepository.getConversations(userId: tUserId))
          .thenAnswer((_) async => Right(tConversationsList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tConversationsList));
      // Vérifier que l'use case ne fait que déléguer au repository
      verify(mockRepository.getConversations(userId: tUserId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}