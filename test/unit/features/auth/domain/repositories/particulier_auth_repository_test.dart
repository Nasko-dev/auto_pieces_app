import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/domain/entities/particulier.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/particulier_auth_repository.dart';

// Mock implementation pour les tests
class MockParticulierAuthRepository implements ParticulierAuthRepository {
  bool _isLoggedIn = false;
  Particulier? _currentParticulier;

  @override
  Future<Either<Failure, Particulier>> signInAnonymously() async {
    if (_isLoggedIn) {
      return Left(ServerFailure('Déjà connecté'));
    }

    _currentParticulier = Particulier(
      id: 'test-particulier-id',
      deviceId: 'test-device-123',
      isAnonymous: true,
      isVerified: false,
      isActive: true,
      createdAt: DateTime.now(),
    );
    _isLoggedIn = true;

    return Right(_currentParticulier!);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (!_isLoggedIn) {
      return Left(CacheFailure('Aucun utilisateur connecté'));
    }

    _currentParticulier = null;
    _isLoggedIn = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, Particulier>> getCurrentParticulier() async {
    if (!_isLoggedIn || _currentParticulier == null) {
      return Left(CacheFailure('Aucun particulier connecté'));
    }
    return Right(_currentParticulier!);
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    return Right(_isLoggedIn);
  }

  @override
  Future<Either<Failure, Particulier>> updateParticulier(
      Particulier particulier) async {
    if (!_isLoggedIn || _currentParticulier == null) {
      return Left(CacheFailure('Aucun particulier connecté'));
    }

    _currentParticulier = particulier.copyWith(
      updatedAt: DateTime.now(),
    );

    return Right(_currentParticulier!);
  }

  // Helpers pour les tests
  void reset() {
    _isLoggedIn = false;
    _currentParticulier = null;
  }

  void setLoggedInState(bool loggedIn) {
    _isLoggedIn = loggedIn;
  }
}

void main() {
  group('ParticulierAuthRepository Tests', () {
    late MockParticulierAuthRepository repository;

    setUp(() {
      repository = MockParticulierAuthRepository();
    });

    tearDown(() {
      repository.reset();
    });

    group('signInAnonymously', () {
      test('devrait se connecter avec succès en mode anonyme', () async {
        final result = await repository.signInAnonymously();

        expect(result, isA<Right<Failure, Particulier>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (particulier) {
            expect(particulier.id, equals('test-particulier-id'));
            expect(particulier.isAnonymous, isTrue);
            expect(particulier.isActive, isTrue);
            expect(particulier.isVerified, isFalse);
            expect(particulier.deviceId, equals('test-device-123'));
          },
        );
      });

      test('devrait retourner une erreur si déjà connecté', () async {
        // Première connexion
        await repository.signInAnonymously();

        // Deuxième tentative
        final result = await repository.signInAnonymously();

        expect(result, isA<Left<Failure, Particulier>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (particulier) => fail('Ne devrait pas retourner de particulier'),
        );
      });
    });

    group('getCurrentParticulier', () {
      test('devrait retourner le particulier connecté', () async {
        await repository.signInAnonymously();

        final result = await repository.getCurrentParticulier();

        expect(result, isA<Right<Failure, Particulier>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (particulier) {
            expect(particulier.id, equals('test-particulier-id'));
            expect(particulier.isAnonymous, isTrue);
          },
        );
      });

      test('devrait retourner une erreur si non connecté', () async {
        final result = await repository.getCurrentParticulier();

        expect(result, isA<Left<Failure, Particulier>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (particulier) => fail('Ne devrait pas retourner de particulier'),
        );
      });
    });

    group('isLoggedIn', () {
      test('devrait retourner false par défaut', () async {
        final result = await repository.isLoggedIn();

        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (loggedIn) => expect(loggedIn, isFalse),
        );
      });

      test('devrait retourner true après connexion', () async {
        await repository.signInAnonymously();

        final result = await repository.isLoggedIn();

        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (loggedIn) => expect(loggedIn, isTrue),
        );
      });
    });

    group('logout', () {
      test('devrait se déconnecter avec succès', () async {
        await repository.signInAnonymously();

        final result = await repository.logout();

        expect(result, isA<Right<Failure, void>>());

        // Vérifier que l'utilisateur est bien déconnecté
        final isLoggedInResult = await repository.isLoggedIn();
        isLoggedInResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (loggedIn) => expect(loggedIn, isFalse),
        );
      });

      test('devrait retourner une erreur si non connecté', () async {
        final result = await repository.logout();

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Ne devrait pas retourner de succès'),
        );
      });
    });

    group('updateParticulier', () {
      test('devrait mettre à jour le profil avec succès', () async {
        await repository.signInAnonymously();

        final updatedParticulier = Particulier(
          id: 'test-particulier-id',
          firstName: 'Jean',
          lastName: 'Dupont',
          email: 'jean.dupont@example.com',
          phone: '+33123456789',
          isAnonymous: false,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final result = await repository.updateParticulier(updatedParticulier);

        expect(result, isA<Right<Failure, Particulier>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (particulier) {
            expect(particulier.firstName, equals('Jean'));
            expect(particulier.lastName, equals('Dupont'));
            expect(particulier.email, equals('jean.dupont@example.com'));
            expect(particulier.isAnonymous, isFalse);
            expect(particulier.updatedAt, isNotNull);
          },
        );
      });

      test('devrait retourner une erreur si non connecté', () async {
        final testParticulier = Particulier(
          id: 'test-id',
          createdAt: DateTime.now(),
        );

        final result = await repository.updateParticulier(testParticulier);

        expect(result, isA<Left<Failure, Particulier>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (particulier) => fail('Ne devrait pas retourner de particulier'),
        );
      });
    });

    group('Flux complet d\'authentification', () {
      test(
          'devrait gérer un cycle complet connexion → mise à jour → déconnexion',
          () async {
        // État initial - non connecté
        var isLoggedInResult = await repository.isLoggedIn();
        isLoggedInResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (loggedIn) => expect(loggedIn, isFalse),
        );

        // Connexion anonyme
        final loginResult = await repository.signInAnonymously();
        expect(loginResult, isA<Right<Failure, Particulier>>());

        // Vérification de l'état connecté
        isLoggedInResult = await repository.isLoggedIn();
        isLoggedInResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (loggedIn) => expect(loggedIn, isTrue),
        );

        // Mise à jour du profil
        final updatedParticulier = Particulier(
          id: 'test-particulier-id',
          firstName: 'Marie',
          lastName: 'Martin',
          email: 'marie.martin@example.com',
          isAnonymous: false,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final updateResult =
            await repository.updateParticulier(updatedParticulier);
        expect(updateResult, isA<Right<Failure, Particulier>>());

        // Déconnexion
        final logoutResult = await repository.logout();
        expect(logoutResult, isA<Right<Failure, void>>());

        // Vérification de l'état déconnecté
        isLoggedInResult = await repository.isLoggedIn();
        isLoggedInResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (loggedIn) => expect(loggedIn, isFalse),
        );
      });
    });

    group('Gestion d\'erreur', () {
      test('devrait respecter le contrat du repository', () {
        // Vérifier que toutes les méthodes retournent Either<Failure, T>
        expect(repository.signInAnonymously(),
            isA<Future<Either<Failure, Particulier>>>());
        expect(repository.getCurrentParticulier(),
            isA<Future<Either<Failure, Particulier>>>());
        expect(repository.logout(), isA<Future<Either<Failure, void>>>());
        expect(repository.isLoggedIn(), isA<Future<Either<Failure, bool>>>());
        expect(
            repository.updateParticulier(
                Particulier(id: 'test', createdAt: DateTime.now())),
            isA<Future<Either<Failure, Particulier>>>());
      });

      test('devrait maintenir la cohérence d\'état', () async {
        await repository.signInAnonymously();

        // Plusieurs appels devraient retourner le même utilisateur
        final user1Result = await repository.getCurrentParticulier();
        final user2Result = await repository.getCurrentParticulier();

        user1Result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (user1) {
            user2Result.fold(
              (failure) => fail('Ne devrait pas retourner d\'erreur'),
              (user2) => expect(user1.id, equals(user2.id)),
            );
          },
        );
      });
    });
  });
}
