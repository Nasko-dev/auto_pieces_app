import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/domain/entities/seller.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/seller_auth_repository.dart';

// Mock implementation pour les tests
class MockSellerAuthRepository implements SellerAuthRepository {
  final Map<String, String> _registeredUsers = {};
  Seller? _currentSeller;
  bool _isLoggedIn = false;
  bool _emailVerified = false;

  @override
  Future<Either<Failure, Seller>> registerSeller({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
  }) async {
    if (_registeredUsers.containsKey(email)) {
      return Left(ServerFailure('Email déjà utilisé'));
    }

    if (password.length < 6) {
      return Left(ValidationFailure('Mot de passe trop court'));
    }

    _registeredUsers[email] = password;
    final seller = Seller(
      id: 'test-seller-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      firstName: firstName,
      lastName: lastName,
      companyName: companyName,
      phone: phone,
      createdAt: DateTime.now(),
    );

    return Right(seller);
  }

  @override
  Future<Either<Failure, Seller>> loginSeller({
    required String email,
    required String password,
  }) async {
    if (_isLoggedIn) {
      return Left(ServerFailure('Déjà connecté'));
    }

    if (!_registeredUsers.containsKey(email) || _registeredUsers[email] != password) {
      return Left(ServerFailure('Identifiants incorrects'));
    }

    _currentSeller = Seller(
      id: 'test-seller-login',
      email: email,
      firstName: 'Jean',
      lastName: 'Vendeur',
      companyName: 'Ma Société',
      createdAt: DateTime.now(),
      emailVerifiedAt: _emailVerified ? DateTime.now() : null,
    );
    _isLoggedIn = true;

    return Right(_currentSeller!);
  }

  @override
  Future<Either<Failure, void>> logoutSeller() async {
    if (!_isLoggedIn) {
      return Left(CacheFailure('Aucun vendeur connecté'));
    }

    _currentSeller = null;
    _isLoggedIn = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!_registeredUsers.containsKey(email)) {
      return Left(ServerFailure('Email non trouvé'));
    }

    // Simuler l'envoi d'email
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!_isLoggedIn || _currentSeller == null) {
      return Left(CacheFailure('Aucun vendeur connecté'));
    }

    if (!_registeredUsers.containsKey(_currentSeller!.email) ||
        _registeredUsers[_currentSeller!.email] != currentPassword) {
      return Left(ServerFailure('Mot de passe actuel incorrect'));
    }

    if (newPassword.length < 6) {
      return Left(ValidationFailure('Nouveau mot de passe trop court'));
    }

    _registeredUsers[_currentSeller!.email] = newPassword;
    return const Right(null);
  }

  @override
  Future<Either<Failure, Seller>> getCurrentSeller() async {
    if (!_isLoggedIn || _currentSeller == null) {
      return Left(CacheFailure('Aucun vendeur connecté'));
    }
    return Right(_currentSeller!);
  }

  @override
  Future<Either<Failure, Seller>> updateSellerProfile(Seller seller) async {
    if (!_isLoggedIn || _currentSeller == null) {
      return Left(CacheFailure('Aucun vendeur connecté'));
    }

    _currentSeller = seller.copyWith(
      updatedAt: DateTime.now(),
    );

    return Right(_currentSeller!);
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    if (!_isLoggedIn || _currentSeller == null) {
      return Left(CacheFailure('Aucun vendeur connecté'));
    }

    // Simuler l'envoi d'email de vérification
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    if (!_isLoggedIn || _currentSeller == null) {
      return Left(CacheFailure('Aucun vendeur connecté'));
    }

    if (token != 'valid-token') {
      return Left(ServerFailure('Token de vérification invalide'));
    }

    _emailVerified = true;
    _currentSeller = _currentSeller!.copyWith(
      emailVerifiedAt: DateTime.now(),
    );

    return const Right(null);
  }

  // Helpers pour les tests
  void reset() {
    _registeredUsers.clear();
    _currentSeller = null;
    _isLoggedIn = false;
    _emailVerified = false;
  }

  void setEmailVerified(bool verified) {
    _emailVerified = verified;
  }
}

void main() {
  group('SellerAuthRepository Tests', () {
    late MockSellerAuthRepository repository;

    setUp(() {
      repository = MockSellerAuthRepository();
    });

    tearDown(() {
      repository.reset();
    });

    group('registerSeller', () {
      test('devrait enregistrer un vendeur avec succès', () async {
        final result = await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
          firstName: 'Jean',
          lastName: 'Dupont',
          companyName: 'Ma Société',
          phone: '+33123456789',
        );

        expect(result, isA<Right<Failure, Seller>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (seller) {
            expect(seller.email, equals('test@example.com'));
            expect(seller.firstName, equals('Jean'));
            expect(seller.lastName, equals('Dupont'));
            expect(seller.companyName, equals('Ma Société'));
            expect(seller.phone, equals('+33123456789'));
            expect(seller.id, isNotEmpty);
          },
        );
      });

      test('devrait retourner une erreur pour un email déjà utilisé', () async {
        // Premier enregistrement
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        // Deuxième tentative avec le même email
        final result = await repository.registerSeller(
          email: 'test@example.com',
          password: 'autremotp123',
        );

        expect(result, isA<Left<Failure, Seller>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (seller) => fail('Ne devrait pas retourner de vendeur'),
        );
      });

      test('devrait retourner une erreur pour un mot de passe trop court', () async {
        final result = await repository.registerSeller(
          email: 'test@example.com',
          password: '123',
        );

        expect(result, isA<Left<Failure, Seller>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (seller) => fail('Ne devrait pas retourner de vendeur'),
        );
      });
    });

    group('loginSeller', () {
      test('devrait se connecter avec succès', () async {
        // Enregistrer un vendeur
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final result = await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        expect(result, isA<Right<Failure, Seller>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (seller) {
            expect(seller.email, equals('test@example.com'));
            expect(seller.firstName, equals('Jean'));
            expect(seller.companyName, equals('Ma Société'));
          },
        );
      });

      test('devrait retourner une erreur pour des identifiants incorrects', () async {
        final result = await repository.loginSeller(
          email: 'inexistant@example.com',
          password: 'mauvaismdp',
        );

        expect(result, isA<Left<Failure, Seller>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (seller) => fail('Ne devrait pas retourner de vendeur'),
        );
      });

      test('devrait retourner une erreur si déjà connecté', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        // Première connexion
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        // Deuxième tentative
        final result = await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        expect(result, isA<Left<Failure, Seller>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (seller) => fail('Ne devrait pas retourner de vendeur'),
        );
      });
    });

    group('getCurrentSeller', () {
      test('devrait retourner le vendeur connecté', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final result = await repository.getCurrentSeller();

        expect(result, isA<Right<Failure, Seller>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (seller) => expect(seller.email, equals('test@example.com')),
        );
      });

      test('devrait retourner une erreur si non connecté', () async {
        final result = await repository.getCurrentSeller();

        expect(result, isA<Left<Failure, Seller>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (seller) => fail('Ne devrait pas retourner de vendeur'),
        );
      });
    });

    group('logoutSeller', () {
      test('devrait se déconnecter avec succès', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final result = await repository.logoutSeller();

        expect(result, isA<Right<Failure, void>>());

        // Vérifier que l'utilisateur est déconnecté
        final getCurrentResult = await repository.getCurrentSeller();
        expect(getCurrentResult, isA<Left<Failure, Seller>>());
      });

      test('devrait retourner une erreur si non connecté', () async {
        final result = await repository.logoutSeller();

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Ne devrait pas retourner de succès'),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      test('devrait envoyer un email de réinitialisation', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final result = await repository.sendPasswordResetEmail('test@example.com');

        expect(result, isA<Right<Failure, void>>());
      });

      test('devrait retourner une erreur pour un email inexistant', () async {
        final result = await repository.sendPasswordResetEmail('inexistant@example.com');

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Ne devrait pas retourner de succès'),
        );
      });
    });

    group('updatePassword', () {
      test('devrait mettre à jour le mot de passe avec succès', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'ancienmdp123',
        );
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'ancienmdp123',
        );

        final result = await repository.updatePassword(
          currentPassword: 'ancienmdp123',
          newPassword: 'nouveaumdp123',
        );

        expect(result, isA<Right<Failure, void>>());
      });

      test('devrait retourner une erreur pour un mot de passe actuel incorrect', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final result = await repository.updatePassword(
          currentPassword: 'mauvaismdp',
          newPassword: 'nouveaumdp123',
        );

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Ne devrait pas retourner de succès'),
        );
      });

      test('devrait retourner une erreur si non connecté', () async {
        final result = await repository.updatePassword(
          currentPassword: 'ancien',
          newPassword: 'nouveau',
        );

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Ne devrait pas retourner de succès'),
        );
      });
    });

    group('updateSellerProfile', () {
      test('devrait mettre à jour le profil avec succès', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final updatedSeller = Seller(
          id: 'test-seller-login',
          email: 'test@example.com',
          firstName: 'Pierre',
          lastName: 'Martin',
          companyName: 'Nouvelle Société',
          phone: '+33987654321',
          createdAt: DateTime.now(),
        );

        final result = await repository.updateSellerProfile(updatedSeller);

        expect(result, isA<Right<Failure, Seller>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (seller) {
            expect(seller.firstName, equals('Pierre'));
            expect(seller.lastName, equals('Martin'));
            expect(seller.companyName, equals('Nouvelle Société'));
            expect(seller.phone, equals('+33987654321'));
            expect(seller.updatedAt, isNotNull);
          },
        );
      });
    });

    group('Email Verification', () {
      test('devrait envoyer un email de vérification', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final result = await repository.sendEmailVerification();

        expect(result, isA<Right<Failure, void>>());
      });

      test('devrait vérifier l\'email avec un token valide', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final result = await repository.verifyEmail('valid-token');

        expect(result, isA<Right<Failure, void>>());

        // Vérifier que l'email est marqué comme vérifié
        final currentSellerResult = await repository.getCurrentSeller();
        currentSellerResult.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (seller) => expect(seller.emailVerifiedAt, isNotNull),
        );
      });

      test('devrait retourner une erreur pour un token invalide', () async {
        await repository.registerSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );
        await repository.loginSeller(
          email: 'test@example.com',
          password: 'motdepasse123',
        );

        final result = await repository.verifyEmail('invalid-token');

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Ne devrait pas retourner de succès'),
        );
      });
    });

    group('Flux complet', () {
      test('devrait gérer un cycle complet d\'authentification vendeur', () async {
        // Enregistrement
        final registerResult = await repository.registerSeller(
          email: 'vendeur@example.com',
          password: 'motdepasse123',
          firstName: 'Jean',
          lastName: 'Vendeur',
          companyName: 'Auto Pièces SARL',
        );
        expect(registerResult, isA<Right<Failure, Seller>>());

        // Connexion
        final loginResult = await repository.loginSeller(
          email: 'vendeur@example.com',
          password: 'motdepasse123',
        );
        expect(loginResult, isA<Right<Failure, Seller>>());

        // Vérification email
        await repository.sendEmailVerification();
        final verifyResult = await repository.verifyEmail('valid-token');
        expect(verifyResult, isA<Right<Failure, void>>());

        // Mise à jour profil
        final updatedSeller = Seller(
          id: 'test-seller-login',
          email: 'vendeur@example.com',
          firstName: 'Jean',
          lastName: 'Vendeur',
          companyName: 'Auto Pièces Premium SARL',
          phone: '+33123456789',
          createdAt: DateTime.now(),
        );
        final updateResult = await repository.updateSellerProfile(updatedSeller);
        expect(updateResult, isA<Right<Failure, Seller>>());

        // Déconnexion
        final logoutResult = await repository.logoutSeller();
        expect(logoutResult, isA<Right<Failure, void>>());
      });
    });
  });
}