import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/seller_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/seller_logout.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'seller_logout_test.mocks.dart';

@GenerateMocks([SellerAuthRepository])
void main() {
  late SellerLogout usecase;
  late MockSellerAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerAuthRepository();
    usecase = SellerLogout(mockRepository);
  });

  group('SellerLogout', () {
    test('doit se déconnecter avec succès', () async {
      // arrange
      when(mockRepository.logoutSeller())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(null));
      verify(mockRepository.logoutSeller());
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner ServerFailure en cas d\'erreur de déconnexion', () async {
      // arrange
      when(mockRepository.logoutSeller())
          .thenAnswer((_) async => const Left(ServerFailure('Erreur lors de la déconnexion')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Erreur lors de la déconnexion')));
      verify(mockRepository.logoutSeller());
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.logoutSeller())
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.logoutSeller());
    });

    test('doit retourner AuthFailure si l\'utilisateur n\'est pas connecté', () async {
      // arrange
      when(mockRepository.logoutSeller())
          .thenAnswer((_) async => const Left(AuthFailure('Utilisateur non connecté')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(AuthFailure('Utilisateur non connecté')));
      verify(mockRepository.logoutSeller());
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.logoutSeller())
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(NoParams());

      // assert
      verify(mockRepository.logoutSeller()).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.logoutSeller())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.logoutSeller())
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(NoParams()),
        throwsA(isA<Exception>()),
      );
    });
  });
}