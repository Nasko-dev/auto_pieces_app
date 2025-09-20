import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/seller_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/seller_forgot_password.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'seller_forgot_password_test.mocks.dart';

@GenerateMocks([SellerAuthRepository])
void main() {
  late SellerForgotPassword usecase;
  late MockSellerAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerAuthRepository();
    usecase = SellerForgotPassword(mockRepository);
  });

  const String tEmail = 'test@example.com';

  group('SellerForgotPassword', () {
    test('doit envoyer l\'email de réinitialisation avec succès', () async {
      // arrange
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(const SellerForgotPasswordParams(
        email: tEmail,
      ));

      // assert
      expect(result, const Right(null));
      verify(mockRepository.sendPasswordResetEmail(tEmail.toLowerCase().trim()));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit normaliser l\'email (lowercase et trim)', () async {
      // arrange
      const String emailWithSpaces = '  TEST@EXAMPLE.COM  ';
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(const SellerForgotPasswordParams(
        email: emailWithSpaces,
      ));

      // assert
      verify(mockRepository.sendPasswordResetEmail('test@example.com'));
    });

    test('doit retourner ValidationFailure quand l\'email est vide', () async {
      // act
      final result = await usecase(const SellerForgotPasswordParams(
        email: '',
      ));

      // assert
      expect(result, const Left(ValidationFailure('L\'email est requis')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure pour un format d\'email invalide', () async {
      // arrange
      const String invalidEmail = 'invalid-email';

      // act
      final result = await usecase(const SellerForgotPasswordParams(
        email: invalidEmail,
      ));

      // assert
      expect(result, const Left(ValidationFailure('Format d\'email invalide')));
      verifyZeroInteractions(mockRepository);
    });

    group('Validation d\'email', () {
      const validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@example.org',
        'test123@test-domain.com',
      ];

      const invalidEmails = [
        'invalid-email',
        '@example.com',
        'test@',
        'test.example.com',
        'test@@example.com',
        '',
        ' ',
      ];

      for (final email in validEmails) {
        test('doit accepter l\'email valide: $email', () async {
          // arrange
          when(mockRepository.sendPasswordResetEmail(any))
              .thenAnswer((_) async => const Right(null));

          // act
          final result = await usecase(SellerForgotPasswordParams(
            email: email,
          ));

          // assert
          expect(result, const Right(null));
        });
      }

      for (final email in invalidEmails) {
        test('doit rejeter l\'email invalide: "$email"', () async {
          // act
          final result = await usecase(SellerForgotPasswordParams(
            email: email,
          ));

          // assert
          expect(result, isA<Left<Failure, void>>());
          verifyZeroInteractions(mockRepository);
        });
      }
    });

    test('doit retourner AuthFailure quand l\'email n\'existe pas', () async {
      // arrange
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => const Left(AuthFailure('Email non trouvé')));

      // act
      final result = await usecase(const SellerForgotPasswordParams(
        email: tEmail,
      ));

      // assert
      expect(result, const Left(AuthFailure('Email non trouvé')));
      verify(mockRepository.sendPasswordResetEmail(tEmail));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(const SellerForgotPasswordParams(
        email: tEmail,
      ));

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
    });

    test('doit retourner ServerFailure pour une erreur serveur', () async {
      // arrange
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(const SellerForgotPasswordParams(
        email: tEmail,
      ));

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });
  });

  group('SellerForgotPasswordParams', () {
    test('doit être égaux avec les mêmes valeurs', () {
      // arrange
      const params1 = SellerForgotPasswordParams(email: tEmail);
      const params2 = SellerForgotPasswordParams(email: tEmail);

      // assert
      expect(params1, equals(params2));
    });

    test('doit avoir des props correctes', () {
      // arrange
      const params = SellerForgotPasswordParams(email: tEmail);

      // assert
      expect(params.props, [tEmail]);
    });
  });
}