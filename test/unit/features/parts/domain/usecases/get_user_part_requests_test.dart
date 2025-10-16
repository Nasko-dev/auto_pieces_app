import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_request.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_request_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_user_part_requests.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_part_requests_test.mocks.dart';

@GenerateMocks([PartRequestRepository])
void main() {
  late GetUserPartRequests usecase;
  late MockPartRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockPartRequestRepository();
    usecase = GetUserPartRequests(mockRepository);
  });

  final tPartRequest1 = PartRequest(
    id: '1',
    userId: 'user1',
    vehiclePlate: 'AB-123-CD',
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2018,
    vehicleEngine: '1.6 BlueHDi',
    partType: 'engine',
    partNames: ['moteur', 'culasse'],
    status: 'active',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tPartRequest2 = PartRequest(
    id: '2',
    userId: 'user1',
    vehiclePlate: 'EF-456-GH',
    vehicleBrand: 'Renault',
    vehicleModel: 'Clio',
    vehicleYear: 2020,
    partType: 'body',
    partNames: ['pare-chocs avant', 'phare'],
    status: 'active',
    responseCount: 3,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tPartRequestsList = [tPartRequest1, tPartRequest2];

  group('GetUserPartRequests', () {
    test(
        'doit retourner une liste de PartRequest quand la récupération réussit',
        () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(tPartRequestsList));
      verify(mockRepository.getUserPartRequests());
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'doit retourner une liste vide quand l\'utilisateur n\'a pas de demandes',
        () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return right'),
        (requests) => expect(requests, isEmpty),
      );
      verify(mockRepository.getUserPartRequests());
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas connecté',
        () async {
      // arrange
      when(mockRepository.getUserPartRequests()).thenAnswer(
          (_) async => const Left(AuthFailure('Utilisateur non connecté')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(AuthFailure('Utilisateur non connecté')));
      verify(mockRepository.getUserPartRequests());
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getUserPartRequests());
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau',
        () async {
      // arrange
      when(mockRepository.getUserPartRequests()).thenAnswer(
          (_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getUserPartRequests());
    });

    test('doit retourner CacheFailure en cas d\'erreur de cache', () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => const Left(CacheFailure('Erreur de cache')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(CacheFailure('Erreur de cache')));
      verify(mockRepository.getUserPartRequests());
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      await usecase(NoParams());

      // assert
      verify(mockRepository.getUserPartRequests()).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = ValidationFailure('Erreur de validation');
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(NoParams()),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner les demandes avec toutes les propriétés correctes',
        () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests.length, 2);

          final firstRequest = partRequests[0];
          expect(firstRequest.id, tPartRequest1.id);
          expect(firstRequest.userId, tPartRequest1.userId);
          expect(firstRequest.vehicleBrand, tPartRequest1.vehicleBrand);
          expect(firstRequest.vehicleModel, tPartRequest1.vehicleModel);
          expect(firstRequest.partType, tPartRequest1.partType);
          expect(firstRequest.partNames, tPartRequest1.partNames);
          expect(firstRequest.status, 'active');

          final secondRequest = partRequests[1];
          expect(secondRequest.id, tPartRequest2.id);
          expect(secondRequest.responseCount, 3);
          expect(secondRequest.partType, 'body');
        },
      );
    });

    test('doit retourner les demandes triées par date de création', () async {
      // arrange
      final olderRequest = PartRequest(
        id: '3',
        userId: 'user1',
        partType: 'engine',
        partNames: ['alternateur'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      );

      final newerRequest = PartRequest(
        id: '4',
        userId: 'user1',
        partType: 'body',
        partNames: ['rétroviseur'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now(),
      );

      final sortedList = [newerRequest, olderRequest];

      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(sortedList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests[0].createdAt.isAfter(partRequests[1].createdAt),
              true);
        },
      );
    });

    test('doit gérer les demandes avec différents statuts', () async {
      // arrange
      final activeRequest = PartRequest(
        id: '5',
        userId: 'user1',
        partType: 'engine',
        partNames: ['courroie'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final closedRequest = PartRequest(
        id: '6',
        userId: 'user1',
        partType: 'body',
        partNames: ['enjoliveur'],
        status: 'closed',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mixedStatusList = [activeRequest, closedRequest];

      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(mixedStatusList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests.length, 2);
          expect(partRequests[0].status, 'active');
          expect(partRequests[1].status, 'closed');
        },
      );
    });

    test('doit gérer les demandes anonymes et non-anonymes', () async {
      // arrange
      final normalRequest = PartRequest(
        id: '7',
        userId: 'user1',
        partType: 'engine',
        partNames: ['filtre'],
        status: 'active',
        isAnonymous: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final anonymousRequest = PartRequest(
        id: '8',
        userId: 'user1',
        partType: 'body',
        partNames: ['vitre'],
        status: 'active',
        isAnonymous: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mixedAnonymityList = [normalRequest, anonymousRequest];

      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(mixedAnonymityList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests[0].isAnonymous, false);
          expect(partRequests[1].isAnonymous, true);
        },
      );
    });

    test('doit fonctionner avec des appels multiples', () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, Right(tPartRequestsList));
      expect(result2, Right(tPartRequestsList));
      verify(mockRepository.getUserPartRequests()).called(2);
    });

    test('doit retourner la même liste à chaque appel (cohérence)', () async {
      // arrange
      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getUserPartRequests()).called(2);
    });

    test('doit gérer les demandes avec compteurs de réponses variés', () async {
      // arrange
      final noResponseRequest = PartRequest(
        id: '9',
        userId: 'user1',
        partType: 'engine',
        partNames: ['bougie'],
        status: 'active',
        responseCount: 0,
        pendingResponseCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final manyResponsesRequest = PartRequest(
        id: '10',
        userId: 'user1',
        partType: 'body',
        partNames: ['capot'],
        status: 'active',
        responseCount: 15,
        pendingResponseCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final variousResponsesList = [noResponseRequest, manyResponsesRequest];

      when(mockRepository.getUserPartRequests())
          .thenAnswer((_) async => Right(variousResponsesList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests[0].responseCount, 0);
          expect(partRequests[0].hasResponses, false);
          expect(partRequests[1].responseCount, 15);
          expect(partRequests[1].hasResponses, true);
          expect(partRequests[1].pendingResponseCount, 3);
        },
      );
    });
  });
}
