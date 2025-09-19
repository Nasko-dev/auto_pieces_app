import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/domain/entities/user.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/login_as_particulier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_as_particulier_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginAsParticulier usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginAsParticulier(mockRepository);
  });

  final tUser = User(
    id: '1',
    email: 'particulier@example.com',
    userType: 'particulier',
    createdAt: DateTime.now(),
  );

  group('LoginAsParticulier', () {
    test('doit retourner un User quand la connexion particulier réussit', () async {
      // arrange
      when(mockRepository.loginAsParticulier())
          .thenAnswer((_) async => Right(tUser));

      // act
      final result = await usecase();

      // assert
      expect(result, Right(tUser));
      verify(mockRepository.loginAsParticulier());
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand la connexion échoue', () async {
      // arrange
      when(mockRepository.loginAsParticulier())
          .thenAnswer((_) async => const Left(AuthFailure('Connexion échouée')));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(AuthFailure('Connexion échouée')));
      verify(mockRepository.loginAsParticulier());
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.loginAsParticulier())
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.loginAsParticulier());
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.loginAsParticulier())
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.loginAsParticulier());
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.loginAsParticulier())
          .thenAnswer((_) async => Right(tUser));

      // act
      await usecase();

      // assert
      verify(mockRepository.loginAsParticulier()).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = CacheFailure('Erreur de cache');
      when(mockRepository.loginAsParticulier())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.loginAsParticulier())
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner le même utilisateur à chaque appel (cohérence)', () async {
      // arrange
      when(mockRepository.loginAsParticulier())
          .thenAnswer((_) async => Right(tUser));

      // act
      final result1 = await usecase();
      final result2 = await usecase();

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.loginAsParticulier()).called(2);
    });

    test('doit retourner un utilisateur avec toutes les propriétés correctes', () async {
      // arrange
      when(mockRepository.loginAsParticulier())
          .thenAnswer((_) async => Right(tUser));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (user) {
          expect(user.id, tUser.id);
          expect(user.email, tUser.email);
          expect(user.userType, tUser.userType);
          expect(user.createdAt, tUser.createdAt);
        },
      );
    });
  });
}