import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/auth/domain/entities/particulier.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/particulier_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/particulier_anonymous_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'particulier_anonymous_auth_test.mocks.dart';

@GenerateMocks([ParticulierAuthRepository])
void main() {
  late ParticulierAnonymousAuth usecase;
  late MockParticulierAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockParticulierAuthRepository();
    usecase = ParticulierAnonymousAuth(mockRepository);
  });

  final tParticulier = Particulier(
    id: 'anonymous_1',
    email: 'anonymous@example.com',
    firstName: 'Anonyme',
    lastName: 'Utilisateur',
    phone: '',
    address: '',
    zipCode: '',
    city: '',
    createdAt: DateTime.now(),
    isActive: true,
  );

  group('ParticulierAnonymousAuth', () {
    test('doit retourner un Particulier quand la connexion anonyme réussit', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => Right(tParticulier));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(tParticulier));
      verify(mockRepository.signInAnonymously());
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner ServerFailure quand la connexion anonyme échoue', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => const Left(ServerFailure('Échec de la connexion anonyme')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Échec de la connexion anonyme')));
      verify(mockRepository.signInAnonymously());
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
      verify(mockRepository.signInAnonymously());
    });

    test('doit retourner AuthFailure en cas d\'erreur d\'authentification', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => const Left(AuthFailure('Authentification anonyme refusée')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(AuthFailure('Authentification anonyme refusée')));
      verify(mockRepository.signInAnonymously());
    });

    test('doit retourner CacheFailure si la mise en cache échoue', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => const Left(CacheFailure('Erreur de cache')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(CacheFailure('Erreur de cache')));
      verify(mockRepository.signInAnonymously());
    });

    test('doit appeler le repository une seule fois', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => Right(tParticulier));

      // act
      await usecase(NoParams());

      // assert
      verify(mockRepository.signInAnonymously()).called(1);
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      const failure = ValidationFailure('Erreur de validation');
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
    });

    test('doit gérer les exceptions imprévues du repository', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(NoParams()),
        throwsA(isA<Exception>()),
      );
    });

    test('doit retourner un particulier anonyme avec toutes les propriétés', () async {
      // arrange
      when(mockRepository.signInAnonymously())
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
          expect(particulier.isActive, true);
          // Les champs optionnels peuvent être vides pour un utilisateur anonyme
          expect(particulier.phone, tParticulier.phone);
          expect(particulier.address, tParticulier.address);
          expect(particulier.zipCode, tParticulier.zipCode);
          expect(particulier.city, tParticulier.city);
        },
      );
    });

    test('doit créer des sessions anonymes multiples distinctes', () async {
      // arrange
      final particulier1 = Particulier(
        id: 'anonymous_1',
        email: 'anonymous1@example.com',
        firstName: 'Anonyme',
        lastName: 'Un',
        phone: '',
        address: '',
        zipCode: '',
        city: '',
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Second call should create different anonymous user
      // ignore: unused_local_variable
      final secondParticulier = Particulier(
        id: 'anonymous_2',
        email: 'anonymous2@example.com',
        firstName: 'Anonyme',
        lastName: 'Deux',
        phone: '',
        address: '',
        zipCode: '',
        city: '',
        createdAt: DateTime.now(),
        isActive: true,
      );

      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => Right(particulier1));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());

      // assert
      expect(result1, Right(particulier1));
      expect(result2, Right(particulier1));
      verify(mockRepository.signInAnonymously()).called(2);
    });

    test('doit permettre la connexion anonyme même sans données personnelles', () async {
      // arrange
      final anonymousParticulier = Particulier(
        id: 'anonymous_minimal',
        email: '',
        firstName: '',
        lastName: '',
        phone: '',
        address: '',
        zipCode: '',
        city: '',
        createdAt: DateTime.now(),
        isActive: true,
      );

      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => Right(anonymousParticulier));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(anonymousParticulier));
      result.fold(
        (failure) => fail('Ne devrait pas échouer'),
        (particulier) {
          expect(particulier.isActive, true);
          expect(particulier.id.isNotEmpty, true);
        },
      );
    });

    test('doit fonctionner avec plusieurs tentatives de connexion anonyme', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => Right(tParticulier));

      // act
      final result1 = await usecase(NoParams());
      final result2 = await usecase(NoParams());
      final result3 = await usecase(NoParams());

      // assert
      expect(result1, Right(tParticulier));
      expect(result2, Right(tParticulier));
      expect(result3, Right(tParticulier));
      verify(mockRepository.signInAnonymously()).called(3);
    });

    test('doit gérer les limitations du serveur pour les connexions anonymes', () async {
      // arrange
      when(mockRepository.signInAnonymously())
          .thenAnswer((_) async => const Left(ServerFailure('Trop de connexions anonymes')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Trop de connexions anonymes')));
      verify(mockRepository.signInAnonymously());
    });
  });
}