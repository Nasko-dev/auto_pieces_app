import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:cente_pice/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cente_pice/src/features/auth/data/models/user_model.dart';
import 'package:cente_pice/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cente_pice/src/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([
  AuthRemoteDataSource,
  AuthLocalDataSource,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tUser = User(
    id: '1',
    email: 'test@example.com',
    userType: 'particulier',
    createdAt: DateTime.now(),
  );

  final tUserModel = UserModel.fromEntity(tUser);

  group('AuthRepositoryImpl', () {
    group('loginAsParticulier', () {
      test('doit retourner un User quand la connexion réussit', () async {
        // arrange
        when(mockRemoteDataSource.loginAsParticulier())
            .thenAnswer((_) async => tUserModel);
        when(mockLocalDataSource.cacheUser(any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.loginAsParticulier();

        // assert
        verify(mockRemoteDataSource.loginAsParticulier());
        verify(mockLocalDataSource.cacheUser(tUserModel));
        expect(result, Right(tUserModel));
      });

      test('doit retourner ServerFailure quand la connexion remote échoue', () async {
        // arrange
        when(mockRemoteDataSource.loginAsParticulier())
            .thenThrow(Exception('Erreur connexion'));

        // act
        final result = await repository.loginAsParticulier();

        // assert
        verify(mockRemoteDataSource.loginAsParticulier());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, const Left(ServerFailure('Exception: Erreur connexion')));
      });

      test('doit retourner ServerFailure si la mise en cache échoue', () async {
        // arrange
        when(mockRemoteDataSource.loginAsParticulier())
            .thenAnswer((_) async => tUserModel);
        when(mockLocalDataSource.cacheUser(any))
            .thenThrow(Exception('Erreur cache'));

        // act
        final result = await repository.loginAsParticulier();

        // assert
        verify(mockRemoteDataSource.loginAsParticulier());
        verify(mockLocalDataSource.cacheUser(tUserModel));
        expect(result, const Left(ServerFailure('Exception: Erreur cache')));
      });

      test('doit mettre en cache l\'utilisateur après une connexion réussie', () async {
        // arrange
        when(mockRemoteDataSource.loginAsParticulier())
            .thenAnswer((_) async => tUserModel);
        when(mockLocalDataSource.cacheUser(any))
            .thenAnswer((_) async => {});

        // act
        await repository.loginAsParticulier();

        // assert
        final captured = verify(mockLocalDataSource.cacheUser(captureAny)).captured;
        expect(captured.first, tUserModel);
      });
    });

    group('getCurrentUser', () {
      test('doit retourner l\'utilisateur du cache s\'il existe', () async {
        // arrange
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.getCurrentUser();

        // assert
        verify(mockLocalDataSource.getCachedUser());
        expect(result, Right(tUserModel));
      });

      test('doit retourner CacheFailure si aucun utilisateur en cache', () async {
        // arrange
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => null);

        // act
        final result = await repository.getCurrentUser();

        // assert
        verify(mockLocalDataSource.getCachedUser());
        expect(result, const Left(CacheFailure('Aucun utilisateur en cache')));
      });

      test('doit retourner CacheFailure en cas d\'erreur de cache', () async {
        // arrange
        when(mockLocalDataSource.getCachedUser())
            .thenThrow(Exception('Erreur lecture cache'));

        // act
        final result = await repository.getCurrentUser();

        // assert
        verify(mockLocalDataSource.getCachedUser());
        expect(result, const Left(CacheFailure('Erreur lors de la récupération du cache: Exception: Erreur lecture cache')));
      });
    });

    group('logout', () {
      test('doit se déconnecter avec succès en nettoyant le cache', () async {
        // arrange
        when(mockLocalDataSource.clearCache()).thenAnswer((_) async => {});

        // act
        final result = await repository.logout();

        // assert
        verify(mockLocalDataSource.clearCache());
        expect(result, const Right(null));
      });

      test('doit retourner CacheFailure si le nettoyage du cache échoue', () async {
        // arrange
        when(mockLocalDataSource.clearCache())
            .thenThrow(Exception('Erreur nettoyage'));

        // act
        final result = await repository.logout();

        // assert
        verify(mockLocalDataSource.clearCache());
        expect(result, const Left(CacheFailure('Erreur lors de la suppression du cache: Exception: Erreur nettoyage')));
      });
    });

    group('isLoggedIn', () {
      test('doit retourner true si un utilisateur est en cache', () async {
        // arrange
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.isLoggedIn();

        // assert
        verify(mockLocalDataSource.getCachedUser());
        expect(result, const Right(true));
      });

      test('doit retourner false si aucun utilisateur en cache', () async {
        // arrange
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => null);

        // act
        final result = await repository.isLoggedIn();

        // assert
        verify(mockLocalDataSource.getCachedUser());
        expect(result, const Right(false));
      });

      test('doit retourner false en cas d\'exception', () async {
        // arrange
        when(mockLocalDataSource.getCachedUser())
            .thenThrow(Exception('Erreur lecture'));

        // act
        final result = await repository.isLoggedIn();

        // assert
        verify(mockLocalDataSource.getCachedUser());
        expect(result, const Right(false));
      });
    });

    group('Gestion des états', () {
      test('doit gérer une séquence complète login -> isLoggedIn -> logout', () async {
        // arrange
        when(mockRemoteDataSource.loginAsParticulier())
            .thenAnswer((_) async => tUserModel);
        when(mockLocalDataSource.cacheUser(any))
            .thenAnswer((_) async => {});
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => tUserModel);
        when(mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});

        // act & assert - login
        final loginResult = await repository.loginAsParticulier();
        expect(loginResult.isRight(), true);
        loginResult.fold(
          (failure) => fail('Should return right'),
          (user) => expect(user.id, tUser.id),
        );

        // act & assert - check status
        final statusResult = await repository.isLoggedIn();
        expect(statusResult, const Right(true));

        // act & assert - logout
        final logoutResult = await repository.logout();
        expect(logoutResult, const Right(null));

        // verify calls
        verify(mockRemoteDataSource.loginAsParticulier());
        verify(mockLocalDataSource.cacheUser(tUserModel));
        verify(mockLocalDataSource.getCachedUser());
        verify(mockLocalDataSource.clearCache());
      });

      test('doit maintenir la cohérence après plusieurs appels getCurrentUser', () async {
        // arrange
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => tUserModel);

        // act
        final result1 = await repository.getCurrentUser();
        final result2 = await repository.getCurrentUser();
        final result3 = await repository.getCurrentUser();

        // assert
        expect(result1.isRight(), true);
        expect(result2.isRight(), true);
        expect(result3.isRight(), true);
        result1.fold(
          (failure) => fail('Should return right'),
          (user) => expect(user.id, tUser.id),
        );
        verify(mockLocalDataSource.getCachedUser()).called(3);
      });

      test('doit gérer le passage de connecté à déconnecté', () async {
        // arrange - utilisateur connecté
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => tUserModel);

        // act & assert - vérifier connexion
        final statusResult1 = await repository.isLoggedIn();
        expect(statusResult1, const Right(true));

        // arrange - déconnexion
        when(mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => null);

        // act & assert - déconnexion
        final logoutResult = await repository.logout();
        expect(logoutResult, const Right(null));

        // act & assert - vérifier déconnexion
        final statusResult2 = await repository.isLoggedIn();
        expect(statusResult2, const Right(false));
      });
    });

    group('Gestion des erreurs avancées', () {
      test('doit gérer les erreurs de réseau avec des messages appropriés', () async {
        // arrange
        when(mockRemoteDataSource.loginAsParticulier())
            .thenThrow(Exception('Network timeout'));

        // act
        final result = await repository.loginAsParticulier();

        // assert
        expect(result, const Left(ServerFailure('Exception: Network timeout')));
      });

      test('doit préserver les données utilisateur existantes lors d\'erreurs', () async {
        // arrange - utilisateur déjà en cache
        when(mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => tUserModel);

        // arrange - tentative de connexion échoue
        when(mockRemoteDataSource.loginAsParticulier())
            .thenThrow(Exception('Connexion échouée'));

        // act - tentative de connexion qui échoue
        final loginResult = await repository.loginAsParticulier();
        expect(loginResult.isLeft(), true);

        // act - vérifier que l'utilisateur précédent est toujours en cache
        final currentUserResult = await repository.getCurrentUser();
        expect(currentUserResult.isRight(), true);
        currentUserResult.fold(
          (failure) => fail('Should return right'),
          (user) => expect(user.id, tUser.id),
        );
      });

      test('doit gérer les utilisateurs avec différents types', () async {
        // arrange
        final particulierUser = UserModel(
          id: '1',
          email: 'particulier@test.com',
          userType: 'particulier',
          createdAt: DateTime.now(),
        );

        when(mockRemoteDataSource.loginAsParticulier())
            .thenAnswer((_) async => particulierUser);
        when(mockLocalDataSource.cacheUser(any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.loginAsParticulier();

        // assert
        expect(result, Right(particulierUser));
        result.fold(
          (failure) => fail('Ne devrait pas échouer'),
          (user) => expect(user.userType, 'particulier'),
        );
      });
    });
  });
}