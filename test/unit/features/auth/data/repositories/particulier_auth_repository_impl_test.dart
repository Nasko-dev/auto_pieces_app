import 'package:cente_pice/src/core/errors/exceptions.dart';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/data/datasources/particulier_auth_local_datasource.dart';
import 'package:cente_pice/src/features/auth/data/datasources/particulier_auth_remote_datasource.dart';
import 'package:cente_pice/src/features/auth/data/models/particulier_model.dart';
import 'package:cente_pice/src/features/auth/data/repositories/particulier_auth_repository_impl.dart';
import 'package:cente_pice/src/features/auth/domain/entities/particulier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'particulier_auth_repository_impl_test.mocks.dart';

@GenerateMocks([
  ParticulierAuthRemoteDataSource,
  ParticulierAuthLocalDataSource,
])
void main() {
  late ParticulierAuthRepositoryImpl repository;
  late MockParticulierAuthRemoteDataSource mockRemoteDataSource;
  late MockParticulierAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockParticulierAuthRemoteDataSource();
    mockLocalDataSource = MockParticulierAuthLocalDataSource();
    repository = ParticulierAuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tParticulier = Particulier(
    id: '1',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    phone: '+33123456789',
    address: 'Test Address',
    zipCode: '75001',
    city: 'Paris',
    createdAt: DateTime.now(),
    isActive: true,
  );

  final tParticulierModel = ParticulierModel.fromEntity(tParticulier);

  group('ParticulierAuthRepositoryImpl', () {
    group('signInAnonymously', () {
      test('doit retourner un Particulier quand la connexion anonyme réussit',
          () async {
        // arrange
        when(mockRemoteDataSource.signInAnonymously())
            .thenAnswer((_) async => tParticulierModel);
        when(mockLocalDataSource.cacheParticulier(any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.signInAnonymously();

        // assert
        verify(mockRemoteDataSource.signInAnonymously());
        verify(mockLocalDataSource.cacheParticulier(tParticulierModel));
        expect(result, Right(tParticulierModel));
      });

      test('doit retourner ServerFailure quand la connexion échoue', () async {
        // arrange
        when(mockRemoteDataSource.signInAnonymously())
            .thenThrow(const ServerException('Erreur serveur'));

        // act
        final result = await repository.signInAnonymously();

        // assert
        verify(mockRemoteDataSource.signInAnonymously());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, const Left(ServerFailure('Erreur serveur')));
      });

      test('doit retourner CacheFailure si la mise en cache échoue', () async {
        // arrange
        when(mockRemoteDataSource.signInAnonymously())
            .thenAnswer((_) async => tParticulierModel);
        when(mockLocalDataSource.cacheParticulier(any))
            .thenThrow(const CacheException('Erreur cache'));

        // act
        final result = await repository.signInAnonymously();

        // assert
        verify(mockRemoteDataSource.signInAnonymously());
        verify(mockLocalDataSource.cacheParticulier(tParticulierModel));
        expect(result, const Left(CacheFailure('Erreur cache')));
      });

      test('doit retourner ServerFailure pour toute autre exception', () async {
        // arrange
        when(mockRemoteDataSource.signInAnonymously())
            .thenThrow(Exception('Erreur inattendue'));

        // act
        final result = await repository.signInAnonymously();

        // assert
        expect(
            result,
            const Left(ServerFailure(
                'Erreur lors de la connexion anonyme: Exception: Erreur inattendue')));
      });
    });

    group('logout', () {
      test('doit se déconnecter avec succès et nettoyer le cache', () async {
        // arrange
        when(mockRemoteDataSource.logout()).thenAnswer((_) async => {});
        when(mockLocalDataSource.clearCache()).thenAnswer((_) async => {});

        // act
        final result = await repository.logout();

        // assert
        verify(mockRemoteDataSource.logout());
        verify(mockLocalDataSource.clearCache());
        expect(result, const Right(null));
      });

      test('doit retourner ServerFailure si la déconnexion remote échoue',
          () async {
        // arrange
        when(mockRemoteDataSource.logout())
            .thenThrow(const ServerException('Erreur déconnexion'));

        // act
        final result = await repository.logout();

        // assert
        verify(mockRemoteDataSource.logout());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, const Left(ServerFailure('Erreur déconnexion')));
      });

      test('doit retourner CacheFailure si le nettoyage du cache échoue',
          () async {
        // arrange
        when(mockRemoteDataSource.logout()).thenAnswer((_) async => {});
        when(mockLocalDataSource.clearCache())
            .thenThrow(const CacheException('Erreur nettoyage cache'));

        // act
        final result = await repository.logout();

        // assert
        verify(mockRemoteDataSource.logout());
        verify(mockLocalDataSource.clearCache());
        expect(result, const Left(CacheFailure('Erreur nettoyage cache')));
      });

      test('doit retourner ServerFailure pour toute autre exception', () async {
        // arrange
        when(mockRemoteDataSource.logout())
            .thenThrow(Exception('Erreur inattendue'));

        // act
        final result = await repository.logout();

        // assert
        expect(
            result,
            const Left(ServerFailure(
                'Erreur lors de la déconnexion: Exception: Erreur inattendue')));
      });
    });

    group('getCurrentParticulier', () {
      test('doit retourner le particulier du cache s\'il existe', () async {
        // arrange
        when(mockLocalDataSource.getCachedParticulier())
            .thenAnswer((_) async => tParticulierModel);

        // act
        final result = await repository.getCurrentParticulier();

        // assert
        verify(mockLocalDataSource.getCachedParticulier());
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Right(tParticulierModel));
      });

      test('doit récupérer depuis le serveur si le cache est vide', () async {
        // arrange
        when(mockLocalDataSource.getCachedParticulier())
            .thenAnswer((_) async => null);
        when(mockRemoteDataSource.getCurrentParticulier())
            .thenAnswer((_) async => tParticulierModel);
        when(mockLocalDataSource.cacheParticulier(any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.getCurrentParticulier();

        // assert
        verify(mockLocalDataSource.getCachedParticulier());
        verify(mockRemoteDataSource.getCurrentParticulier());
        verify(mockLocalDataSource.cacheParticulier(tParticulierModel));
        expect(result, Right(tParticulierModel));
      });

      test('doit retourner ServerFailure si la récupération serveur échoue',
          () async {
        // arrange
        when(mockLocalDataSource.getCachedParticulier())
            .thenAnswer((_) async => null);
        when(mockRemoteDataSource.getCurrentParticulier())
            .thenThrow(const ServerException('Non authentifié'));

        // act
        final result = await repository.getCurrentParticulier();

        // assert
        expect(result, const Left(ServerFailure('Non authentifié')));
      });

      test('doit essayer le serveur si le cache échoue', () async {
        // arrange
        when(mockLocalDataSource.getCachedParticulier())
            .thenThrow(const CacheException('Erreur cache'));
        when(mockRemoteDataSource.getCurrentParticulier())
            .thenAnswer((_) async => tParticulierModel);

        // act
        final result = await repository.getCurrentParticulier();

        // assert
        verify(mockLocalDataSource.getCachedParticulier());
        verify(mockRemoteDataSource.getCurrentParticulier());
        expect(result, Right(tParticulierModel));
      });

      test('doit retourner ServerFailure si cache et serveur échouent',
          () async {
        // arrange
        when(mockLocalDataSource.getCachedParticulier())
            .thenThrow(const CacheException('Erreur cache'));
        when(mockRemoteDataSource.getCurrentParticulier())
            .thenThrow(const ServerException('Erreur serveur'));

        // act
        final result = await repository.getCurrentParticulier();

        // assert
        expect(result, const Left(ServerFailure('Erreur serveur')));
      });
    });

    group('isLoggedIn', () {
      test('doit retourner true si l\'utilisateur est connecté', () async {
        // arrange
        when(mockRemoteDataSource.isLoggedIn()).thenAnswer((_) async => true);

        // act
        final result = await repository.isLoggedIn();

        // assert
        verify(mockRemoteDataSource.isLoggedIn());
        expect(result, const Right(true));
      });

      test('doit retourner false si l\'utilisateur n\'est pas connecté',
          () async {
        // arrange
        when(mockRemoteDataSource.isLoggedIn()).thenAnswer((_) async => false);

        // act
        final result = await repository.isLoggedIn();

        // assert
        verify(mockRemoteDataSource.isLoggedIn());
        expect(result, const Right(false));
      });

      test('doit retourner false en cas d\'exception', () async {
        // arrange
        when(mockRemoteDataSource.isLoggedIn()).thenThrow(Exception('Erreur'));

        // act
        final result = await repository.isLoggedIn();

        // assert
        expect(result, const Right(false));
      });
    });

    group('updateParticulier', () {
      test('doit mettre à jour le particulier avec succès', () async {
        // arrange
        when(mockRemoteDataSource.updateParticulier(any))
            .thenAnswer((_) async => tParticulierModel);
        when(mockLocalDataSource.cacheParticulier(any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.updateParticulier(tParticulier);

        // assert
        verify(mockRemoteDataSource.updateParticulier(any));
        verify(mockLocalDataSource.cacheParticulier(tParticulierModel));
        expect(result, Right(tParticulierModel));
      });

      test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
        // arrange
        when(mockRemoteDataSource.updateParticulier(any))
            .thenThrow(const ServerException('Erreur mise à jour'));

        // act
        final result = await repository.updateParticulier(tParticulier);

        // assert
        expect(result, const Left(ServerFailure('Erreur mise à jour')));
      });

      test('doit retourner ServerFailure pour toute autre exception', () async {
        // arrange
        when(mockRemoteDataSource.updateParticulier(any))
            .thenThrow(Exception('Erreur inattendue'));

        // act
        final result = await repository.updateParticulier(tParticulier);

        // assert
        expect(
            result,
            const Left(ServerFailure(
                'Erreur lors de la mise à jour: Exception: Erreur inattendue')));
      });
    });
  });
}
