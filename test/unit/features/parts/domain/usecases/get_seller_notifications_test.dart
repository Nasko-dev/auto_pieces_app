import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_request.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_request_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_seller_notifications.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_seller_notifications_test.mocks.dart';

@GenerateMocks([PartRequestRepository])
void main() {
  late GetSellerNotifications usecase;
  late MockPartRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockPartRequestRepository();
    usecase = GetSellerNotifications(mockRepository);
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
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now(),
  );

  final tPartRequest2 = PartRequest(
    id: '2',
    userId: 'user2',
    vehiclePlate: 'EF-456-GH',
    vehicleBrand: 'Renault',
    vehicleModel: 'Clio',
    vehicleYear: 2020,
    partType: 'body',
    partNames: ['pare-chocs avant', 'phare'],
    status: 'active',
    responseCount: 0,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    updatedAt: DateTime.now(),
  );

  final tPartRequest3 = PartRequest(
    id: '3',
    userId: 'user3',
    vehicleBrand: 'BMW',
    vehicleModel: 'X3',
    vehicleYear: 2019,
    partType: 'engine',
    partNames: ['turbo', 'injecteur'],
    status: 'active',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now(),
  );

  final tPartRequestsList = [tPartRequest1, tPartRequest2, tPartRequest3];

  group('GetSellerNotifications', () {
    test('doit retourner une liste de PartRequest quand la récupération réussit', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(tPartRequestsList));
      verify(mockRepository.getActivePartRequestsForSellerWithRejections());
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner une liste vide quand aucune notification n\'existe', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return right'),
        (requests) => expect(requests, isEmpty),
      );
      verify(mockRepository.getActivePartRequestsForSellerWithRejections());
    });

    test('doit retourner AuthFailure quand le vendeur n\'est pas connecté', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => const Left(AuthFailure('Vendeur non connecté')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(AuthFailure('Vendeur non connecté')));
      verify(mockRepository.getActivePartRequestsForSellerWithRejections());
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getActivePartRequestsForSellerWithRejections());
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getActivePartRequestsForSellerWithRejections());
    });

    test('doit retourner CacheFailure en cas d\'erreur de cache', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => const Left(CacheFailure('Erreur de cache')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(CacheFailure('Erreur de cache')));
      verify(mockRepository.getActivePartRequestsForSellerWithRejections());
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      await usecase(NoParams());

      // assert
      verify(mockRepository.getActivePartRequestsForSellerWithRejections()).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = ValidationFailure('Erreur de validation');
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(NoParams()),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner les notifications avec toutes les propriétés correctes', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests.length, 3);

          final firstRequest = partRequests[0];
          expect(firstRequest.id, tPartRequest1.id);
          expect(firstRequest.vehicleBrand, 'Peugeot');
          expect(firstRequest.vehicleModel, '308');
          expect(firstRequest.partType, 'engine');
          expect(firstRequest.partNames, ['moteur', 'culasse']);
          expect(firstRequest.status, 'active');

          final secondRequest = partRequests[1];
          expect(secondRequest.partType, 'body');
          expect(secondRequest.partNames, ['pare-chocs avant', 'phare']);

          final thirdRequest = partRequests[2];
          expect(thirdRequest.vehicleBrand, 'BMW');
          expect(thirdRequest.partNames, ['turbo', 'injecteur']);
        },
      );
    });

    test('doit retourner seulement les demandes actives', () async {
      // arrange
      final activeRequest = PartRequest(
        id: '4',
        userId: 'user4',
        vehicleBrand: 'Audi',
        vehicleModel: 'A4',
        partType: 'engine',
        partNames: ['alternateur'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right([activeRequest]));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests.length, 1);
          expect(partRequests.first.status, 'active');
          expect(partRequests.first.isActive, true);
        },
      );
    });

    test('doit gérer les demandes avec différents types de pièces', () async {
      // arrange
      final engineRequest = PartRequest(
        id: '5',
        userId: 'user5',
        partType: 'engine',
        partNames: ['vilebrequin'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final bodyRequest = PartRequest(
        id: '6',
        userId: 'user6',
        partType: 'body',
        partNames: ['portière'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mixedTypesList = [engineRequest, bodyRequest];

      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right(mixedTypesList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests[0].partType, 'engine');
          expect(partRequests[1].partType, 'body');
        },
      );
    });

    test('doit fonctionner avec des appels multiples', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, Right(tPartRequestsList));
      expect(result2, Right(tPartRequestsList));
      verify(mockRepository.getActivePartRequestsForSellerWithRejections()).called(2);
    });

    test('doit retourner la même liste à chaque appel (cohérence)', () async {
      // arrange
      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getActivePartRequestsForSellerWithRejections()).called(2);
    });

    test('doit gérer les demandes avec informations véhicule partielles', () async {
      // arrange
      final minimalRequest = PartRequest(
        id: '7',
        userId: 'user7',
        partType: 'engine',
        partNames: ['filtre à huile'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final completeRequest = PartRequest(
        id: '8',
        userId: 'user8',
        vehiclePlate: 'XY-789-ZA',
        vehicleBrand: 'Ford',
        vehicleModel: 'Focus',
        vehicleYear: 2021,
        vehicleEngine: '1.0 EcoBoost',
        partType: 'body',
        partNames: ['rétroviseur'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final variousInfoList = [minimalRequest, completeRequest];

      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right(variousInfoList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests[0].vehicleBrand, null);
          expect(partRequests[0].vehicleModel, null);
          expect(partRequests[1].vehicleBrand, 'Ford');
          expect(partRequests[1].vehicleModel, 'Focus');
          expect(partRequests[1].vehiclePlate, 'XY-789-ZA');
        },
      );
    });

    test('doit gérer les demandes avec différents nombres de réponses', () async {
      // arrange
      final noResponseRequest = PartRequest(
        id: '9',
        userId: 'user9',
        partType: 'engine',
        partNames: ['courroie'],
        status: 'active',
        responseCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final someResponsesRequest = PartRequest(
        id: '10',
        userId: 'user10',
        partType: 'body',
        partNames: ['vitre'],
        status: 'active',
        responseCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final responseVariationsList = [noResponseRequest, someResponsesRequest];

      when(mockRepository.getActivePartRequestsForSellerWithRejections())
          .thenAnswer((_) async => Right(responseVariationsList));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (partRequests) {
          expect(partRequests[0].responseCount, 0);
          expect(partRequests[0].hasResponses, false);
          expect(partRequests[1].responseCount, 5);
          expect(partRequests[1].hasResponses, true);
        },
      );
    });
  });

  group('SellerNotification', () {
    test('doit créer une notification à partir d\'un PartRequest', () async {
      // arrange
      final partRequest = PartRequest(
        id: 'req1',
        vehicleBrand: 'Toyota',
        vehicleModel: 'Corolla',
        partType: 'engine',
        partNames: ['filtre à air'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now(),
      );

      // act
      final notification = SellerNotification.fromPartRequest(partRequest);

      // assert
      expect(notification.id, 'req1');
      expect(notification.vehicleModel, 'Toyota Corolla');
      expect(notification.partType, 'engine');
      expect(notification.partNames, ['filtre à air']);
      expect(notification.isNew, true); // Moins de 24h
    });

    test('doit marquer comme nouvelle si créée il y a moins de 24h', () async {
      // arrange
      final recentRequest = PartRequest(
        id: 'req2',
        partType: 'body',
        partNames: ['pare-brise'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now(),
      );

      // act
      final notification = SellerNotification.fromPartRequest(recentRequest);

      // assert
      expect(notification.isNew, true);
    });

    test('doit marquer comme ancienne si créée il y a plus de 24h', () async {
      // arrange
      final oldRequest = PartRequest(
        id: 'req3',
        partType: 'engine',
        partNames: ['bougie'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      );

      // act
      final notification = SellerNotification.fromPartRequest(oldRequest);

      // assert
      expect(notification.isNew, false);
    });

    test('doit gérer les véhicules sans marque ni modèle', () async {
      // arrange
      final unknownVehicleRequest = PartRequest(
        id: 'req4',
        partType: 'engine',
        partNames: ['radiateur'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // act
      final notification = SellerNotification.fromPartRequest(unknownVehicleRequest);

      // assert
      expect(notification.vehicleModel, 'Véhicule ');
    });

    test('doit gérer les véhicules avec seulement la marque', () async {
      // arrange
      final brandOnlyRequest = PartRequest(
        id: 'req5',
        vehicleBrand: 'Mercedes',
        partType: 'body',
        partNames: ['enjoliveur'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // act
      final notification = SellerNotification.fromPartRequest(brandOnlyRequest);

      // assert
      expect(notification.vehicleModel, 'Mercedes ');
    });

    test('doit gérer les véhicules avec seulement le modèle', () async {
      // arrange
      final modelOnlyRequest = PartRequest(
        id: 'req6',
        vehicleModel: 'Golf',
        partType: 'engine',
        partNames: ['pompe à eau'],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // act
      final notification = SellerNotification.fromPartRequest(modelOnlyRequest);

      // assert
      expect(notification.vehicleModel, 'Véhicule Golf');
    });
  });
}