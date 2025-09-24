import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/domain/entities/user.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/auth_repository.dart';

// Mock implementation for testing
class MockAuthRepository implements AuthRepository {
  bool _isLoggedIn = false;
  User? _currentUser;

  @override
  Future<Either<Failure, User>> loginAsParticulier() async {
    if (_isLoggedIn) {
      return Left(ServerFailure('Already logged in'));
    }

    _currentUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      userType: 'particulier',
      createdAt: DateTime.now(),
    );
    _isLoggedIn = true;

    return Right(_currentUser!);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (!_isLoggedIn || _currentUser == null) {
      return Left(CacheFailure('No user logged in'));
    }
    return Right(_currentUser!);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (!_isLoggedIn) {
      return Left(CacheFailure('No user to logout'));
    }

    _currentUser = null;
    _isLoggedIn = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    return Right(_isLoggedIn);
  }

  // Test helpers
  void reset() {
    _isLoggedIn = false;
    _currentUser = null;
  }

  void setLoggedInState(bool loggedIn) {
    _isLoggedIn = loggedIn;
  }
}

void main() {
  group('AuthRepository Tests', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
    });

    tearDown(() {
      repository.reset();
    });

    group('loginAsParticulier', () {
      test('should login successfully when not logged in', () async {
        final result = await repository.loginAsParticulier();

        expect(result, isA<Right<Failure, User>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (user) {
            expect(user.id, equals('test-user-id'));
            expect(user.userType, equals('particulier'));
            expect(user.email, equals('test@example.com'));
          },
        );
      });

      test('should return failure when already logged in', () async {
        // First login
        await repository.loginAsParticulier();

        // Second login attempt
        final result = await repository.loginAsParticulier();

        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (user) => fail('Should not return user'),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return current user when logged in', () async {
        await repository.loginAsParticulier();

        final result = await repository.getCurrentUser();

        expect(result, isA<Right<Failure, User>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (user) {
            expect(user.id, equals('test-user-id'));
            expect(user.userType, equals('particulier'));
          },
        );
      });

      test('should return failure when not logged in', () async {
        final result = await repository.getCurrentUser();

        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (user) => fail('Should not return user'),
        );
      });
    });

    group('logout', () {
      test('should logout successfully when logged in', () async {
        await repository.loginAsParticulier();

        final result = await repository.logout();

        expect(result, isA<Right<Failure, void>>());

        // Verify user is logged out
        final isLoggedInResult = await repository.isLoggedIn();
        isLoggedInResult.fold(
          (failure) => fail('Should not return failure'),
          (loggedIn) => expect(loggedIn, isFalse),
        );
      });

      test('should return failure when not logged in', () async {
        final result = await repository.logout();

        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should not return success'),
        );
      });
    });

    group('isLoggedIn', () {
      test('should return false when not logged in', () async {
        final result = await repository.isLoggedIn();

        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (loggedIn) => expect(loggedIn, isFalse),
        );
      });

      test('should return true when logged in', () async {
        await repository.loginAsParticulier();

        final result = await repository.isLoggedIn();

        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (loggedIn) => expect(loggedIn, isTrue),
        );
      });

      test('should return false after logout', () async {
        await repository.loginAsParticulier();
        await repository.logout();

        final result = await repository.isLoggedIn();

        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (loggedIn) => expect(loggedIn, isFalse),
        );
      });
    });

    group('Integration scenarios', () {
      test('should handle complete auth flow', () async {
        // Initial state - not logged in
        var isLoggedInResult = await repository.isLoggedIn();
        isLoggedInResult.fold(
          (failure) => fail('Should not return failure'),
          (loggedIn) => expect(loggedIn, isFalse),
        );

        // Login
        final loginResult = await repository.loginAsParticulier();
        expect(loginResult, isA<Right<Failure, User>>());

        // Check logged in state
        isLoggedInResult = await repository.isLoggedIn();
        isLoggedInResult.fold(
          (failure) => fail('Should not return failure'),
          (loggedIn) => expect(loggedIn, isTrue),
        );

        // Get current user
        final getUserResult = await repository.getCurrentUser();
        expect(getUserResult, isA<Right<Failure, User>>());

        // Logout
        final logoutResult = await repository.logout();
        expect(logoutResult, isA<Right<Failure, void>>());

        // Check logged out state
        isLoggedInResult = await repository.isLoggedIn();
        isLoggedInResult.fold(
          (failure) => fail('Should not return failure'),
          (loggedIn) => expect(loggedIn, isFalse),
        );
      });

      test('should maintain state consistency', () async {
        await repository.loginAsParticulier();

        // Multiple calls should return same user
        final user1Result = await repository.getCurrentUser();
        final user2Result = await repository.getCurrentUser();

        user1Result.fold(
          (failure) => fail('Should not return failure'),
          (user1) {
            user2Result.fold(
              (failure) => fail('Should not return failure'),
              (user2) => expect(user1.id, equals(user2.id)),
            );
          },
        );
      });
    });

    group('Error handling', () {
      test('should handle repository contract correctly', () {
        // Verify all methods return Either<Failure, T>
        expect(repository.loginAsParticulier(), isA<Future<Either<Failure, User>>>());
        expect(repository.getCurrentUser(), isA<Future<Either<Failure, User>>>());
        expect(repository.logout(), isA<Future<Either<Failure, void>>>());
        expect(repository.isLoggedIn(), isA<Future<Either<Failure, bool>>>());
      });
    });
  });
}