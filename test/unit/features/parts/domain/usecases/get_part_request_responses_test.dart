import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/seller_response.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_request_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_part_request_responses.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_part_request_responses_test.mocks.dart';

@GenerateMocks([PartRequestRepository])
void main() {
  late GetPartRequestResponses usecase;
  late MockPartRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockPartRequestRepository();
    usecase = GetPartRequestResponses(mockRepository);
  });

  const tRequestId = 'request123';

  final tSellerResponse1 = SellerResponse(
    id: 'response1',
    requestId: tRequestId,
    sellerId: 'seller1',
    sellerName: 'Jean Dupont',
    sellerCompany: 'Pièces Auto Pro',
    sellerEmail: 'jean@piecesauto.com',
    sellerPhone: '+33123456789',
    message: 'J\'ai cette pièce en stock, excellente qualité',
    price: 150.00,
    availability: 'available',
    estimatedDeliveryDays: 2,
    attachments: ['photo1.jpg', 'photo2.jpg'],
    status: 'pending',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tSellerResponse2 = SellerResponse(
    id: 'response2',
    requestId: tRequestId,
    sellerId: 'seller2',
    sellerName: 'Marie Martin',
    sellerCompany: 'Auto Recyclage',
    sellerEmail: 'marie@autorecyclage.com',
    message: 'Pièce d\'occasion en bon état',
    price: 80.00,
    availability: 'order_needed',
    estimatedDeliveryDays: 7,
    status: 'pending',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tSellerResponsesList = [tSellerResponse1, tSellerResponse2];

  group('GetPartRequestResponses', () {
    test('doit retourner une liste de SellerResponse quand la récupération réussit', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => Right(tSellerResponsesList));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, Right(tSellerResponsesList));
      verify(mockRepository.getPartRequestResponses(tRequestId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner une liste vide quand aucune réponse n\'existe', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (responses) => expect(responses.isEmpty, true),
      );
      verify(mockRepository.getPartRequestResponses(tRequestId));
    });

    test('doit retourner ValidationFailure quand requestId est vide', () async {
      // act
      final result = await usecase('');

      // assert
      expect(result, const Left(ValidationFailure('L\'ID de la demande est requis')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand requestId est une chaîne d\'espaces', () async {
      // act
      final result = await usecase('   ');

      // assert
      expect(result, const Left(ValidationFailure('L\'ID de la demande est requis')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => const Left(AuthFailure('Accès non autorisé')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(AuthFailure('Accès non autorisé')));
      verify(mockRepository.getPartRequestResponses(tRequestId));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getPartRequestResponses(tRequestId));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getPartRequestResponses(tRequestId));
    });

    test('doit retourner ValidationFailure quand la demande n\'existe pas', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => const Left(ValidationFailure('Demande non trouvée')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(ValidationFailure('Demande non trouvée')));
      verify(mockRepository.getPartRequestResponses(tRequestId));
    });

    test('doit appeler le repository avec le bon requestId', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => Right(tSellerResponsesList));

      // act
      await usecase(tRequestId);

      // assert
      final captured = verify(mockRepository.getPartRequestResponses(captureAny)).captured;
      expect(captured.first, tRequestId);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tRequestId),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner les réponses avec toutes les propriétés correctes', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => Right(tSellerResponsesList));

      // act
      final result = await usecase(tRequestId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (responses) {
          expect(responses.length, 2);

          final firstResponse = responses[0];
          expect(firstResponse.id, tSellerResponse1.id);
          expect(firstResponse.requestId, tRequestId);
          expect(firstResponse.sellerId, tSellerResponse1.sellerId);
          expect(firstResponse.sellerName, tSellerResponse1.sellerName);
          expect(firstResponse.sellerCompany, tSellerResponse1.sellerCompany);
          expect(firstResponse.message, tSellerResponse1.message);
          expect(firstResponse.price, 150.00);
          expect(firstResponse.availability, 'available');
          expect(firstResponse.estimatedDeliveryDays, 2);
          expect(firstResponse.attachments.length, 2);
          expect(firstResponse.status, 'pending');

          final secondResponse = responses[1];
          expect(secondResponse.price, 80.00);
          expect(secondResponse.availability, 'order_needed');
          expect(secondResponse.estimatedDeliveryDays, 7);
        },
      );
    });

    test('doit gérer les réponses avec différents statuts', () async {
      // arrange
      final pendingResponse = SellerResponse(
        id: 'response3',
        requestId: tRequestId,
        sellerId: 'seller3',
        message: 'Réponse en attente',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final acceptedResponse = SellerResponse(
        id: 'response4',
        requestId: tRequestId,
        sellerId: 'seller4',
        message: 'Réponse acceptée',
        status: 'accepted',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final rejectedResponse = SellerResponse(
        id: 'response5',
        requestId: tRequestId,
        sellerId: 'seller5',
        message: 'Réponse rejetée',
        status: 'rejected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mixedStatusList = [pendingResponse, acceptedResponse, rejectedResponse];

      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => Right(mixedStatusList));

      // act
      final result = await usecase(tRequestId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (responses) {
          expect(responses.length, 3);
          expect(responses[0].isPending, true);
          expect(responses[0].isAccepted, false);
          expect(responses[0].isRejected, false);

          expect(responses[1].isPending, false);
          expect(responses[1].isAccepted, true);
          expect(responses[1].isRejected, false);

          expect(responses[2].isPending, false);
          expect(responses[2].isAccepted, false);
          expect(responses[2].isRejected, true);
        },
      );
    });

    test('doit gérer les réponses avec différentes disponibilités', () async {
      // arrange
      final availableResponse = SellerResponse(
        id: 'response6',
        requestId: tRequestId,
        sellerId: 'seller6',
        message: 'Disponible',
        availability: 'available',
        estimatedDeliveryDays: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderNeededResponse = SellerResponse(
        id: 'response7',
        requestId: tRequestId,
        sellerId: 'seller7',
        message: 'Sur commande',
        availability: 'order_needed',
        estimatedDeliveryDays: 14,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final unavailableResponse = SellerResponse(
        id: 'response8',
        requestId: tRequestId,
        sellerId: 'seller8',
        message: 'Indisponible',
        availability: 'unavailable',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final availabilityList = [availableResponse, orderNeededResponse, unavailableResponse];

      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => Right(availabilityList));

      // act
      final result = await usecase(tRequestId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (responses) {
          expect(responses[0].isAvailable, true);
          expect(responses[0].availabilityText, 'Disponible');
          expect(responses[0].deliveryText, 'Livraison immédiate');

          expect(responses[1].isAvailable, false);
          expect(responses[1].availabilityText, 'Sur commande');
          expect(responses[1].deliveryText, '14 jours');

          expect(responses[2].isAvailable, false);
          expect(responses[2].availabilityText, 'Indisponible');
          expect(responses[2].deliveryText, 'Non précisé');
        },
      );
    });

    test('doit gérer les réponses avec et sans prix', () async {
      // arrange
      final withPriceResponse = SellerResponse(
        id: 'response9',
        requestId: tRequestId,
        sellerId: 'seller9',
        message: 'Avec prix',
        price: 99.99,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final withoutPriceResponse = SellerResponse(
        id: 'response10',
        requestId: tRequestId,
        sellerId: 'seller10',
        message: 'Sans prix',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final zeroPriceResponse = SellerResponse(
        id: 'response11',
        requestId: tRequestId,
        sellerId: 'seller11',
        message: 'Prix zéro',
        price: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final priceVariationsList = [withPriceResponse, withoutPriceResponse, zeroPriceResponse];

      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => Right(priceVariationsList));

      // act
      final result = await usecase(tRequestId);

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (responses) {
          expect(responses[0].hasPrice, true);
          expect(responses[0].price, 99.99);

          expect(responses[1].hasPrice, false);
          expect(responses[1].price, null);

          expect(responses[2].hasPrice, false);
          expect(responses[2].price, 0.0);
        },
      );
    });

    test('doit fonctionner avec des requestId différents', () async {
      // arrange
      const anotherRequestId = 'request456';
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => Right(tSellerResponsesList));
      when(mockRepository.getPartRequestResponses(anotherRequestId))
          .thenAnswer((_) async => const Right([]));

      // act
      final result1 = await usecase(tRequestId);
      final result2 = await usecase(anotherRequestId);

      // assert
      expect(result1, Right(tSellerResponsesList));
      expect(result2.isRight(), true);
      result2.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (responses) => expect(responses.isEmpty, true),
      );
      verify(mockRepository.getPartRequestResponses(tRequestId));
      verify(mockRepository.getPartRequestResponses(anotherRequestId));
    });

    test('doit retourner les mêmes réponses à chaque appel (cohérence)', () async {
      // arrange
      when(mockRepository.getPartRequestResponses(tRequestId))
          .thenAnswer((_) async => Right(tSellerResponsesList));

      // act
      final result1 = await usecase(tRequestId);
      final result2 = await usecase(tRequestId);

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getPartRequestResponses(tRequestId)).called(2);
    });

    test('doit valider les IDs de demande avec des formats différents', () async {
      // arrange & act & assert
      final validIds = [
        'req123',
        'request-456',
        'REQ_789',
        '12345',
        'long-request-id-with-many-characters',
      ];

      for (final validId in validIds) {
        when(mockRepository.getPartRequestResponses(validId))
            .thenAnswer((_) async => const Right([]));

        final result = await usecase(validId);
        expect(result.isRight(), true);
        verify(mockRepository.getPartRequestResponses(validId));
      }
    });
  });
}