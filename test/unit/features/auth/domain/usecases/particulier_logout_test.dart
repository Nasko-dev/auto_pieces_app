import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/particulier_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/particulier_logout.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'particulier_logout_test.mocks.dart';

@GenerateMocks([ParticulierAuthRepository])
void main() {
  late ParticulierLogout usecase;
  late MockParticulierAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockParticulierAuthRepository();
    usecase = ParticulierLogout(mockRepository);
  });

  group('ParticulierLogout', () {
    test('doit se déconnecter avec succès', () async {
      // arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(null));
      verify(mockRepository.logout());
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner ServerFailure en cas d\'erreur de déconnexion', () async {
      // arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(ServerFailure('Erreur lors de la déconnexion')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Erreur lors de la déconnexion')));
      verify(mockRepository.logout());
    });

    test('doit retourner CacheFailure si le nettoyage du cache échoue', () async {
      // arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(CacheFailure('Erreur nettoyage cache')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(CacheFailure('Erreur nettoyage cache')));
      verify(mockRepository.logout());
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.logout());
    });

    test('doit retourner AuthFailure si l\'utilisateur n\'est pas connecté', () async {
      // arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(AuthFailure('Utilisateur non connecté')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(AuthFailure('Utilisateur non connecté')));
      verify(mockRepository.logout());
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(NoParams());

      // assert
      verify(mockRepository.logout()).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = ValidationFailure('Erreur de validation');
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.logout())
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(NoParams()),
        throwsA(isA<Exception>()),
      );
    });

    test('doit nettoyer complètement la session utilisateur', () async {
      // arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(null));
      // Vérifier que la méthode logout est appelée (qui doit nettoyer cache + remote)
      verify(mockRepository.logout());
    });

    test('doit fonctionner même avec des appels multiples', () async {
      // arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, const Right(null));
      expect(result2, const Right(null));
      verify(mockRepository.logout()).called(2);
    });
  });
}