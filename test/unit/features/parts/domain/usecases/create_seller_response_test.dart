import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/seller_response.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_request_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/create_seller_response.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_seller_response_test.mocks.dart';

@GenerateMocks([PartRequestRepository])
void main() {
  late CreateSellerResponse usecase;
  late MockPartRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockPartRequestRepository();
    usecase = CreateSellerResponse(mockRepository);
  });

  const tRequestId = 'request123';
  const tMessage = 'J\'ai cette pièce en excellent état';
  const tPrice = 150.00;
  const tAvailability = 'available';
  const tEstimatedDeliveryDays = 3;
  const tAttachments = ['photo1.jpg', 'photo2.jpg'];

  final tValidParams = CreateSellerResponseParams(
    requestId: tRequestId,
    message: tMessage,
    price: tPrice,
    availability: tAvailability,
    estimatedDeliveryDays: tEstimatedDeliveryDays,
    attachments: tAttachments,
  );

  final tCreatedResponse = SellerResponse(
    id: 'response123',
    requestId: tRequestId,
    sellerId: 'seller123',
    sellerName: 'Jean Dupont',
    sellerCompany: 'Pièces Auto Pro',
    sellerEmail: 'jean@piecesauto.com',
    message: tMessage,
    price: tPrice,
    availability: tAvailability,
    estimatedDeliveryDays: tEstimatedDeliveryDays,
    attachments: tAttachments,
    status: 'pending',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CreateSellerResponse', () {
    test('doit retourner SellerResponse quand la création réussit', () async {
      // arrange
      when(mockRepository.createSellerResponse(any))
          .thenAnswer((_) async => Right(tCreatedResponse));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, Right(tCreatedResponse));
      verify(mockRepository.createSellerResponse(tValidParams));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand requestId est vide', () async {
      // arrange
      final invalidParams = CreateSellerResponseParams(
        requestId: '',
        message: tMessage,
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result, const Left(ValidationFailure('L\'ID de la demande est requis')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand message est vide', () async {
      // arrange
      final invalidParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: '',
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result, const Left(ValidationFailure('Le message est requis')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand message est trop court', () async {
      // arrange
      final invalidParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: 'Ok',
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result, const Left(ValidationFailure('Le message doit contenir au moins 10 caractères')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand le prix est négatif', () async {
      // arrange
      final invalidParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: tMessage,
        price: -10.00,
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result, const Left(ValidationFailure('Le prix ne peut pas être négatif')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand les jours de livraison sont négatifs', () async {
      // arrange
      final invalidParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: tMessage,
        estimatedDeliveryDays: -1,
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result, const Left(ValidationFailure('Les jours de livraison ne peuvent pas être négatifs')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure pour une disponibilité invalide', () async {
      // arrange
      final invalidParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: tMessage,
        availability: 'invalid_availability',
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result, const Left(ValidationFailure('Disponibilité invalide')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit accepter les disponibilités valides', () async {
      // arrange
      final validAvailabilities = ['available', 'order_needed', 'unavailable'];

      for (final availability in validAvailabilities) {
        final params = CreateSellerResponseParams(
          requestId: tRequestId,
          message: tMessage,
          availability: availability,
        );

        final response = tCreatedResponse.copyWith(availability: availability);

        when(mockRepository.createSellerResponse(params))
            .thenAnswer((_) async => Right(response));

        // act
        final result = await usecase(params);

        // assert
        expect(result.isRight(), true);
        verify(mockRepository.createSellerResponse(params));
      }
    });

    test('doit retourner AuthFailure quand le vendeur n\'est pas connecté', () async {
      // arrange
      when(mockRepository.createSellerResponse(any))
          .thenAnswer((_) async => const Left(AuthFailure('Vendeur non connecté')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(AuthFailure('Vendeur non connecté')));
      verify(mockRepository.createSellerResponse(tValidParams));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.createSellerResponse(any))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.createSellerResponse(tValidParams));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.createSellerResponse(any))
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.createSellerResponse(tValidParams));
    });

    test('doit retourner ValidationFailure quand la demande n\'existe pas', () async {
      // arrange
      when(mockRepository.createSellerResponse(any))
          .thenAnswer((_) async => const Left(ValidationFailure('Demande non trouvée')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(ValidationFailure('Demande non trouvée')));
      verify(mockRepository.createSellerResponse(tValidParams));
    });

    test('doit retourner ValidationFailure pour une réponse déjà existante', () async {
      // arrange
      when(mockRepository.createSellerResponse(any))
          .thenAnswer((_) async => const Left(ValidationFailure('Vous avez déjà répondu à cette demande')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(ValidationFailure('Vous avez déjà répondu à cette demande')));
      verify(mockRepository.createSellerResponse(tValidParams));
    });

    test('doit appeler le repository avec les bons paramètres', () async {
      // arrange
      when(mockRepository.createSellerResponse(any))
          .thenAnswer((_) async => Right(tCreatedResponse));

      // act
      await usecase(tValidParams);

      // assert
      final captured = verify(mockRepository.createSellerResponse(captureAny)).captured;
      final capturedParams = captured.first as CreateSellerResponseParams;
      expect(capturedParams.requestId, tRequestId);
      expect(capturedParams.message, tMessage);
      expect(capturedParams.price, tPrice);
      expect(capturedParams.availability, tAvailability);
      expect(capturedParams.estimatedDeliveryDays, tEstimatedDeliveryDays);
      expect(capturedParams.attachments, tAttachments);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.createSellerResponse(any))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.createSellerResponse(any))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tValidParams),
        throwsA(isA<Exception>()),
      );
    });

    test('doit créer une réponse sans prix ni délai de livraison', () async {
      // arrange
      final minimalParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: 'Contactez-moi pour plus d\'informations',
      );

      final minimalResponse = tCreatedResponse.copyWith(
        message: 'Contactez-moi pour plus d\'informations',
        price: null,
        estimatedDeliveryDays: null,
      );

      when(mockRepository.createSellerResponse(minimalParams))
          .thenAnswer((_) async => Right(minimalResponse));

      // act
      final result = await usecase(minimalParams);

      // assert
      expect(result, Right(minimalResponse));
      verify(mockRepository.createSellerResponse(minimalParams));
    });

    test('doit créer une réponse avec un prix de zéro', () async {
      // arrange
      final freeParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: 'Pièce offerte pour récupération',
        price: 0.0,
      );

      final freeResponse = tCreatedResponse.copyWith(
        message: 'Pièce offerte pour récupération',
        price: 0.0,
      );

      when(mockRepository.createSellerResponse(freeParams))
          .thenAnswer((_) async => Right(freeResponse));

      // act
      final result = await usecase(freeParams);

      // assert
      expect(result, Right(freeResponse));
      verify(mockRepository.createSellerResponse(freeParams));
    });

    test('doit créer une réponse avec des jours de livraison à zéro (immédiat)', () async {
      // arrange
      final immediateParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: 'Livraison immédiate possible',
        estimatedDeliveryDays: 0,
      );

      final immediateResponse = tCreatedResponse.copyWith(
        message: 'Livraison immédiate possible',
        estimatedDeliveryDays: 0,
      );

      when(mockRepository.createSellerResponse(immediateParams))
          .thenAnswer((_) async => Right(immediateResponse));

      // act
      final result = await usecase(immediateParams);

      // assert
      expect(result, Right(immediateResponse));
      verify(mockRepository.createSellerResponse(immediateParams));
    });

    test('doit créer une réponse avec de nombreuses pièces jointes', () async {
      // arrange
      final manyAttachments = List.generate(10, (i) => 'photo$i.jpg');
      final attachmentParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: 'Voici plusieurs photos de la pièce',
        attachments: manyAttachments,
      );

      final attachmentResponse = tCreatedResponse.copyWith(
        message: 'Voici plusieurs photos de la pièce',
        attachments: manyAttachments,
      );

      when(mockRepository.createSellerResponse(attachmentParams))
          .thenAnswer((_) async => Right(attachmentResponse));

      // act
      final result = await usecase(attachmentParams);

      // assert
      expect(result, Right(attachmentResponse));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (response) => expect(response.attachments.length, 10),
      );
    });

    test('doit créer une réponse avec un message très long', () async {
      // arrange
      final longMessage = 'Très ' * 100 + 'long message détaillé';
      final longMessageParams = CreateSellerResponseParams(
        requestId: tRequestId,
        message: longMessage,
      );

      final longMessageResponse = tCreatedResponse.copyWith(
        message: longMessage,
      );

      when(mockRepository.createSellerResponse(longMessageParams))
          .thenAnswer((_) async => Right(longMessageResponse));

      // act
      final result = await usecase(longMessageParams);

      // assert
      expect(result, Right(longMessageResponse));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (response) => expect(response.message.length, greaterThan(500)),
      );
    });

    test('doit gérer la création de réponses pour différentes demandes', () async {
      // arrange
      final request1Params = CreateSellerResponseParams(
        requestId: 'request1',
        message: 'Réponse pour demande 1',
      );

      final request2Params = CreateSellerResponseParams(
        requestId: 'request2',
        message: 'Réponse pour demande 2',
      );

      final response1 = tCreatedResponse.copyWith(
        requestId: 'request1',
        message: 'Réponse pour demande 1',
      );

      final response2 = tCreatedResponse.copyWith(
        requestId: 'request2',
        message: 'Réponse pour demande 2',
      );

      when(mockRepository.createSellerResponse(request1Params))
          .thenAnswer((_) async => Right(response1));
      when(mockRepository.createSellerResponse(request2Params))
          .thenAnswer((_) async => Right(response2));

      // act
      final result1 = await usecase(request1Params);
      final result2 = await usecase(request2Params);

      // assert
      expect(result1, Right(response1));
      expect(result2, Right(response2));
      verify(mockRepository.createSellerResponse(request1Params));
      verify(mockRepository.createSellerResponse(request2Params));
    });
  });
}