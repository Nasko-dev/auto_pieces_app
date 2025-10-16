import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_request_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/delete_part_request.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'delete_part_request_test.mocks.dart';

@GenerateMocks([PartRequestRepository])
void main() {
  late DeletePartRequest usecase;
  late MockPartRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockPartRequestRepository();
    usecase = DeletePartRequest(mockRepository);
  });

  const tRequestId = 'request123';

  group('DeletePartRequest', () {
    test('doit retourner void quand la suppression réussit', () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.deletePartRequest(tRequestId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer(
          (_) async => const Left(AuthFailure('Accès non autorisé')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(AuthFailure('Accès non autorisé')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test('doit retourner ValidationFailure quand la demande n\'existe pas',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer(
          (_) async => const Left(ValidationFailure('Demande non trouvée')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(ValidationFailure('Demande non trouvée')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test(
        'doit retourner ValidationFailure quand l\'utilisateur n\'est pas propriétaire de la demande',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer((_) async =>
          const Left(ValidationFailure(
              'Vous ne pouvez supprimer que vos propres demandes')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(
          result,
          const Left(ValidationFailure(
              'Vous ne pouvez supprimer que vos propres demandes')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test(
        'doit retourner ValidationFailure quand la demande a déjà des réponses',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer((_) async =>
          const Left(ValidationFailure(
              'Impossible de supprimer une demande avec des réponses')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(
          result,
          const Left(ValidationFailure(
              'Impossible de supprimer une demande avec des réponses')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer(
          (_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test('doit appeler le repository avec le bon requestId', () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId))
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(tRequestId);

      // assert
      final captured =
          verify(mockRepository.deletePartRequest(captureAny)).captured;
      expect(captured.first, tRequestId);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.deletePartRequest(tRequestId))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer la suppression de différentes demandes', () async {
      // arrange
      const request1Id = 'request1';
      const request2Id = 'request2';

      when(mockRepository.deletePartRequest(request1Id))
          .thenAnswer((_) async => const Right(null));
      when(mockRepository.deletePartRequest(request2Id))
          .thenAnswer((_) async => const Right(null));

      // act
      final result1 = await usecase(request1Id);
      final result2 = await usecase(request2Id);

      // assert
      expect(result1, const Right(null));
      expect(result2, const Right(null));
      verify(mockRepository.deletePartRequest(request1Id));
      verify(mockRepository.deletePartRequest(request2Id));
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId))
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(tRequestId);

      // assert
      verify(mockRepository.deletePartRequest(tRequestId)).called(1);
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId))
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tRequestId),
        throwsA(isA<Exception>()),
      );
    });

    test('doit gérer les IDs de demande avec différents formats', () async {
      // arrange & act & assert
      final validIds = [
        'req123',
        'request-456',
        'REQ_789',
        '12345',
        'long-request-id-with-many-characters',
        'uuid-style-f47ac10b-58cc-4372-a567-0e02b2c3d479',
      ];

      for (final validId in validIds) {
        when(mockRepository.deletePartRequest(validId))
            .thenAnswer((_) async => const Right(null));

        final result = await usecase(validId);
        expect(result, const Right(null));
        verify(mockRepository.deletePartRequest(validId));
      }
    });

    test('doit maintenir la cohérence lors de suppressions multiples',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId))
          .thenAnswer((_) async => const Right(null));

      // act - plusieurs appels
      final result1 = await usecase(tRequestId);
      final result2 = await usecase(tRequestId);
      final result3 = await usecase(tRequestId);

      // assert
      expect(result1, const Right(null));
      expect(result2, const Right(null));
      expect(result3, const Right(null));
      verify(mockRepository.deletePartRequest(tRequestId)).called(3);
    });

    test('doit retourner ValidationFailure pour une demande déjà supprimée',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer((_) async =>
          const Left(ValidationFailure('Cette demande a déjà été supprimée')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result,
          const Left(ValidationFailure('Cette demande a déjà été supprimée')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test(
        'doit retourner ValidationFailure quand la demande est en cours de traitement',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer((_) async =>
          const Left(ValidationFailure(
              'Impossible de supprimer une demande en cours de traitement')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(
          result,
          const Left(ValidationFailure(
              'Impossible de supprimer une demande en cours de traitement')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test('doit gérer les suppressions avec des erreurs de concurrence',
        () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer((_) async =>
          const Left(ServerFailure(
              'Erreur de concurrence - la demande a été modifiée par un autre utilisateur')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('concurrence')),
        (success) => fail('Ne devrait pas réussir'),
      );
    });

    test('doit gérer les timeouts de suppression', () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId)).thenAnswer((_) async =>
          const Left(NetworkFailure('Timeout lors de la suppression')));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(
          result, const Left(NetworkFailure('Timeout lors de la suppression')));
      verify(mockRepository.deletePartRequest(tRequestId));
    });

    test('doit déléguer entièrement la logique au repository', () async {
      // arrange
      when(mockRepository.deletePartRequest(tRequestId))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tRequestId);

      // assert
      expect(result, const Right(null));
      // Vérifier que l'use case ne fait que déléguer au repository
      verify(mockRepository.deletePartRequest(tRequestId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
