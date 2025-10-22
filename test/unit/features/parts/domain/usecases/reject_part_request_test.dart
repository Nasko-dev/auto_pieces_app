import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/seller_rejection.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_request_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/reject_part_request.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'reject_part_request_test.mocks.dart';

@GenerateMocks([PartRequestRepository])
void main() {
  late RejectPartRequestUseCase usecase;
  late MockPartRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockPartRequestRepository();
    usecase = RejectPartRequestUseCase(repository: mockRepository);
  });

  const tSellerId = 'seller123';
  const tPartRequestId = 'request456';
  const tReason = 'Pièce non compatible avec ce véhicule';

  final tValidParams = RejectPartRequestParams(
    sellerId: tSellerId,
    partRequestId: tPartRequestId,
    reason: tReason,
  );

  final tValidParamsWithoutReason = RejectPartRequestParams(
    sellerId: tSellerId,
    partRequestId: tPartRequestId,
  );

  final tRejection = SellerRejection(
    id: 'rejection123',
    sellerId: tSellerId,
    partRequestId: tPartRequestId,
    rejectedAt: DateTime.now(),
    reason: tReason,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tRejectionWithoutReason = SellerRejection(
    id: 'rejection124',
    sellerId: tSellerId,
    partRequestId: tPartRequestId,
    rejectedAt: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('RejectPartRequestUseCase', () {
    test('doit retourner SellerRejection quand le refus réussit', () async {
      // arrange
      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => Right(tRejection));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, Right(tRejection));
      verify(mockRepository.rejectPartRequest(any));
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'doit retourner SellerRejection sans raison quand aucune raison n\'est fournie',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => Right(tRejectionWithoutReason));

      // act
      final result = await usecase(tValidParamsWithoutReason);

      // assert
      expect(result, Right(tRejectionWithoutReason));
      verify(mockRepository.rejectPartRequest(any));
    });

    test('doit retourner AuthFailure quand le vendeur n\'est pas connecté',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any)).thenAnswer(
          (_) async => const Left(AuthFailure('Vendeur non connecté')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(AuthFailure('Vendeur non connecté')));
      verify(mockRepository.rejectPartRequest(any));
    });

    test('doit retourner ValidationFailure quand la demande n\'existe pas',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any)).thenAnswer(
          (_) async => const Left(ValidationFailure('Demande non trouvée')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(ValidationFailure('Demande non trouvée')));
      verify(mockRepository.rejectPartRequest(any));
    });

    test(
        'doit retourner ValidationFailure quand le vendeur a déjà rejeté cette demande',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any)).thenAnswer((_) async =>
          const Left(ValidationFailure('Vous avez déjà rejeté cette demande')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result,
          const Left(ValidationFailure('Vous avez déjà rejeté cette demande')));
      verify(mockRepository.rejectPartRequest(any));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.rejectPartRequest(any));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any)).thenAnswer(
          (_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.rejectPartRequest(any));
    });

    test('doit appeler le repository avec un objet SellerRejection correct',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => Right(tRejection));

      // act
      await usecase(tValidParams);

      // assert
      final captured =
          verify(mockRepository.rejectPartRequest(captureAny)).captured;
      final capturedRejection = captured.first as SellerRejection;
      expect(capturedRejection.sellerId, tSellerId);
      expect(capturedRejection.partRequestId, tPartRequestId);
      expect(capturedRejection.reason, tReason);
      expect(capturedRejection.id, ''); // ID vide avant sauvegarde
    });

    test('doit gérer les exceptions imprévues', () async {
      // arrange
      when(mockRepository.rejectPartRequest(any))
          .thenThrow(Exception('Erreur inattendue'));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('Erreur lors du refus')),
        (rejection) => fail('Ne devrait pas réussir'),
      );
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result, const Left(failure));
    });

    test('doit créer une rejection avec la date actuelle', () async {
      // arrange
      final beforeCall = DateTime.now();
      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => Right(tRejection));

      // act
      await usecase(tValidParams);

      // assert
      final captured =
          verify(mockRepository.rejectPartRequest(captureAny)).captured;
      final capturedRejection = captured.first as SellerRejection;
      final afterCall = DateTime.now();

      expect(
          capturedRejection.rejectedAt
              .isAfter(beforeCall.subtract(const Duration(seconds: 1))),
          true);
      expect(
          capturedRejection.rejectedAt
              .isBefore(afterCall.add(const Duration(seconds: 1))),
          true);
      expect(
          capturedRejection.createdAt
              .isAfter(beforeCall.subtract(const Duration(seconds: 1))),
          true);
      expect(
          capturedRejection.updatedAt
              .isAfter(beforeCall.subtract(const Duration(seconds: 1))),
          true);
    });

    test('doit gérer les rejets avec des raisons longues', () async {
      // arrange
      final longReason = 'Très ' * 100 + 'longue raison de refus détaillée';
      final longReasonParams = RejectPartRequestParams(
        sellerId: tSellerId,
        partRequestId: tPartRequestId,
        reason: longReason,
      );

      final longReasonRejection = tRejection.copyWith(reason: longReason);

      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => Right(longReasonRejection));

      // act
      final result = await usecase(longReasonParams);

      // assert
      expect(result, Right(longReasonRejection));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (rejection) => expect(rejection.reason!.length, greaterThan(500)),
      );
    });

    test('doit gérer les rejets pour différents vendeurs', () async {
      // arrange
      const seller1Params = RejectPartRequestParams(
        sellerId: 'seller1',
        partRequestId: tPartRequestId,
        reason: 'Raison vendeur 1',
      );

      const seller2Params = RejectPartRequestParams(
        sellerId: 'seller2',
        partRequestId: tPartRequestId,
        reason: 'Raison vendeur 2',
      );

      final rejection1 =
          tRejection.copyWith(sellerId: 'seller1', reason: 'Raison vendeur 1');
      final rejection2 =
          tRejection.copyWith(sellerId: 'seller2', reason: 'Raison vendeur 2');

      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((invocation) async {
        final rejection = invocation.positionalArguments[0] as SellerRejection;
        if (rejection.sellerId == 'seller1') {
          return Right(rejection1);
        } else {
          return Right(rejection2);
        }
      });

      // act
      final result1 = await usecase(seller1Params);
      final result2 = await usecase(seller2Params);

      // assert
      expect(result1, Right(rejection1));
      expect(result2, Right(rejection2));
      verify(mockRepository.rejectPartRequest(any)).called(2);
    });

    test('doit gérer les rejets pour différentes demandes', () async {
      // arrange
      final request1Params = RejectPartRequestParams(
        sellerId: tSellerId,
        partRequestId: 'request1',
        reason: 'Refus demande 1',
      );

      final request2Params = RejectPartRequestParams(
        sellerId: tSellerId,
        partRequestId: 'request2',
        reason: 'Refus demande 2',
      );

      final rejection1 = tRejection.copyWith(
          partRequestId: 'request1', reason: 'Refus demande 1');
      final rejection2 = tRejection.copyWith(
          partRequestId: 'request2', reason: 'Refus demande 2');

      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((invocation) async {
        final rejection = invocation.positionalArguments[0] as SellerRejection;
        if (rejection.partRequestId == 'request1') {
          return Right(rejection1);
        } else {
          return Right(rejection2);
        }
      });

      // act
      final result1 = await usecase(request1Params);
      final result2 = await usecase(request2Params);

      // assert
      expect(result1, Right(rejection1));
      expect(result2, Right(rejection2));
      verify(mockRepository.rejectPartRequest(any)).called(2);
    });

    test('doit maintenir la cohérence des données dans SellerRejection.create',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => Right(tRejection));

      // act
      await usecase(tValidParams);

      // assert
      final captured =
          verify(mockRepository.rejectPartRequest(captureAny)).captured;
      final capturedRejection = captured.first as SellerRejection;

      // Vérifier que toutes les dates sont cohérentes
      expect(capturedRejection.rejectedAt, capturedRejection.createdAt);
      expect(capturedRejection.createdAt, capturedRejection.updatedAt);

      // Vérifier que les IDs sont corrects
      expect(capturedRejection.sellerId, tSellerId);
      expect(capturedRejection.partRequestId, tPartRequestId);
      expect(capturedRejection.reason, tReason);
    });

    test(
        'doit retourner ValidationFailure si le vendeur essaie de rejeter sa propre demande',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any)).thenAnswer((_) async =>
          const Left(
              ValidationFailure('Impossible de rejeter sa propre demande')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(
          result,
          const Left(
              ValidationFailure('Impossible de rejeter sa propre demande')));
      verify(mockRepository.rejectPartRequest(any));
    });

    test('doit gérer les rejets avec des caractères spéciaux dans la raison',
        () async {
      // arrange
      const specialCharReason =
          'Raison avec émojis 🚗 et accents éàù & caractères spéciaux !@#\$%^&*()';
      final specialCharParams = RejectPartRequestParams(
        sellerId: tSellerId,
        partRequestId: tPartRequestId,
        reason: specialCharReason,
      );

      final specialCharRejection =
          tRejection.copyWith(reason: specialCharReason);

      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => Right(specialCharRejection));

      // act
      final result = await usecase(specialCharParams);

      // assert
      expect(result, Right(specialCharRejection));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (rejection) => expect(rejection.reason, specialCharReason),
      );
    });

    test('doit appeler le repository une seule fois par refus', () async {
      // arrange
      when(mockRepository.rejectPartRequest(any))
          .thenAnswer((_) async => Right(tRejection));

      // act
      await usecase(tValidParams);

      // assert
      verify(mockRepository.rejectPartRequest(any)).called(1);
    });

    test('doit retourner ValidationFailure quand la demande est déjà fermée',
        () async {
      // arrange
      when(mockRepository.rejectPartRequest(any)).thenAnswer((_) async =>
          const Left(ValidationFailure('Cette demande est déjà fermée')));

      // act
      final result = await usecase(tValidParams);

      // assert
      expect(result,
          const Left(ValidationFailure('Cette demande est déjà fermée')));
      verify(mockRepository.rejectPartRequest(any));
    });
  });
}
