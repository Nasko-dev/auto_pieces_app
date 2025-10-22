import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/auth/domain/entities/particulier.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/particulier_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/get_current_particulier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_current_particulier_test.mocks.dart';

@GenerateMocks([ParticulierAuthRepository])
void main() {
  late GetCurrentParticulier usecase;
  late MockParticulierAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockParticulierAuthRepository();
    usecase = GetCurrentParticulier(mockRepository);
  });

  final tParticulier = Particulier(
    id: '1',
    email: 'particulier@example.com',
    firstName: 'Jean',
    lastName: 'Dupont',
    phone: '+33123456789',
    address: 'Test Address',
    zipCode: '75001',
    city: 'Paris',
    createdAt: DateTime.now(),
    isActive: true,
  );

  group('GetCurrentParticulier', () {
    test('doit retourner un Particulier quand la récupération réussit',
        () async {
      // arrange
      when(mockRepository.getCurrentParticulier())
          .thenAnswer((_) async => Right(tParticulier));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(tParticulier));
      verify(mockRepository.getCurrentParticulier());
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas connecté',
        () async {
      // arrange
      when(mockRepository.getCurrentParticulier()).thenAnswer(
          (_) async => const Left(AuthFailure('Utilisateur non connecté')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(AuthFailure('Utilisateur non connecté')));
      verify(mockRepository.getCurrentParticulier());
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.getCurrentParticulier())
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
      verify(mockRepository.getCurrentParticulier());
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau',
        () async {
      // arrange
      when(mockRepository.getCurrentParticulier()).thenAnswer(
          (_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.getCurrentParticulier());
    });

    test('doit retourner CacheFailure si l\'utilisateur n\'est pas en cache',
        () async {
      // arrange
      when(mockRepository.getCurrentParticulier()).thenAnswer(
          (_) async => const Left(CacheFailure('Aucun utilisateur en cache')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(CacheFailure('Aucun utilisateur en cache')));
      verify(mockRepository.getCurrentParticulier());
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.getCurrentParticulier())
          .thenAnswer((_) async => Right(tParticulier));

      // act
      await usecase(NoParams());

      // assert
      verify(mockRepository.getCurrentParticulier()).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = ValidationFailure('Erreur de validation');
      when(mockRepository.getCurrentParticulier())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.getCurrentParticulier())
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(NoParams()),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner le particulier avec toutes les propriétés correctes',
        () async {
      // arrange
      when(mockRepository.getCurrentParticulier())
          .thenAnswer((_) async => Right(tParticulier));

      // act
      final result = await usecase(NoParams());

      // assert
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (particulier) {
          expect(particulier.id, tParticulier.id);
          expect(particulier.email, tParticulier.email);
          expect(particulier.firstName, tParticulier.firstName);
          expect(particulier.lastName, tParticulier.lastName);
          expect(particulier.phone, tParticulier.phone);
          expect(particulier.address, tParticulier.address);
          expect(particulier.zipCode, tParticulier.zipCode);
          expect(particulier.city, tParticulier.city);
          expect(particulier.isActive, tParticulier.isActive);
        },
      );
    });

    test('doit fonctionner avec des appels multiples', () async {
      // arrange
      when(mockRepository.getCurrentParticulier())
          .thenAnswer((_) async => Right(tParticulier));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, Right(tParticulier));
      expect(result2, Right(tParticulier));
      verify(mockRepository.getCurrentParticulier()).called(2);
    });

    test('doit retourner le même particulier à chaque appel (cohérence)',
        () async {
      // arrange
      when(mockRepository.getCurrentParticulier())
          .thenAnswer((_) async => Right(tParticulier));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, equals(result2));
      verify(mockRepository.getCurrentParticulier()).called(2);
    });

    test('doit gérer la récupération d\'un particulier inactif', () async {
      // arrange
      final inactiveParticulier = Particulier(
        id: '2',
        email: 'inactive@example.com',
        firstName: 'Inactive',
        lastName: 'User',
        phone: '+33987654321',
        address: 'Inactive Address',
        zipCode: '69000',
        city: 'Lyon',
        createdAt: DateTime.now(),
        isActive: false,
      );
      when(mockRepository.getCurrentParticulier())
          .thenAnswer((_) async => Right(inactiveParticulier));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(inactiveParticulier));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (particulier) => expect(particulier.isActive, false),
      );
    });
  });
}
