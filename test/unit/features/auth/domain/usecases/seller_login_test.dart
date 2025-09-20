import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/domain/entities/seller.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/seller_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/seller_login.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'seller_login_test.mocks.dart';

@GenerateMocks([SellerAuthRepository])
void main() {
  late SellerLogin usecase;
  late MockSellerAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerAuthRepository();
    usecase = SellerLogin(mockRepository);
  });

  const String tEmail = 'test@example.com';
  const String tPassword = 'password123';

  final tSeller = Seller(
    id: '1',
    email: tEmail,
    firstName: 'Test',
    lastName: 'User',
    phone: '+33123456789',
    companyName: 'Test Company',
    siret: '12345678901234',
    address: 'Test Address',
    zipCode: '75001',
    city: 'Paris',
    createdAt: DateTime.now(),
    isActive: true,
  );

  group('SellerLogin', () {
    test('doit retourner un Seller quand la connexion est réussie', () async {
      // arrange
      when(mockRepository.loginSeller(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(tSeller));

      // act
      final result = await usecase(const SellerLoginParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, Right(tSeller));
      verify(mockRepository.loginSeller(
        email: tEmail.toLowerCase().trim(),
        password: tPassword,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit normaliser l\'email (lowercase et trim)', () async {
      // arrange
      const String emailWithSpaces = '  TEST@EXAMPLE.COM  ';
      when(mockRepository.loginSeller(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(tSeller));

      // act
      await usecase(const SellerLoginParams(
        email: emailWithSpaces,
        password: tPassword,
      ));

      // assert
      verify(mockRepository.loginSeller(
        email: 'test@example.com',
        password: tPassword,
      ));
    });

    test('doit retourner ValidationFailure quand l\'email est vide', () async {
      // act
      final result = await usecase(const SellerLoginParams(
        email: '',
        password: tPassword,
      ));

      // assert
      expect(result, const Left(ValidationFailure('L\'email est requis')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure quand le mot de passe est vide', () async {
      // act
      final result = await usecase(const SellerLoginParams(
        email: tEmail,
        password: '',
      ));

      // assert
      expect(result, const Left(ValidationFailure('Le mot de passe est requis')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner ValidationFailure pour un format d\'email invalide', () async {
      // arrange
      const String invalidEmail = 'invalid-email';

      // act
      final result = await usecase(const SellerLoginParams(
        email: invalidEmail,
        password: tPassword,
      ));

      // assert
      expect(result, const Left(ValidationFailure('Format d\'email invalide')));
      verifyZeroInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand les identifiants sont incorrects', () async {
      // arrange
      when(mockRepository.loginSeller(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(AuthFailure('Identifiants incorrects')));

      // act
      final result = await usecase(const SellerLoginParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, const Left(AuthFailure('Identifiants incorrects')));
      verify(mockRepository.loginSeller(
        email: tEmail.toLowerCase().trim(),
        password: tPassword,
      ));
    });

    test('doit retourner NetworkFailure quand il y a un problème réseau', () async {
      // arrange
      when(mockRepository.loginSeller(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(NetworkFailure('Pas de connexion internet')));

      // act
      final result = await usecase(const SellerLoginParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, const Left(NetworkFailure('Pas de connexion internet')));
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
          when(mockRepository.loginSeller(
            email: anyNamed('email'),
            password: anyNamed('password'),
          )).thenAnswer((_) async => Right(tSeller));

          // act
          final result = await usecase(SellerLoginParams(
            email: email,
            password: tPassword,
          ));

          // assert
          expect(result, Right(tSeller));
        });
      }

      for (final email in invalidEmails) {
        test('doit rejeter l\'email invalide: "$email"', () async {
          // act
          final result = await usecase(SellerLoginParams(
            email: email,
            password: tPassword,
          ));

          // assert
          expect(result, isA<Left<Failure, Seller>>());
          verifyZeroInteractions(mockRepository);
        });
      }
    });
  });

  group('SellerLoginParams', () {
    test('doit être égaux avec les mêmes valeurs', () {
      // arrange
      const params1 = SellerLoginParams(email: tEmail, password: tPassword);
      const params2 = SellerLoginParams(email: tEmail, password: tPassword);

      // assert
      expect(params1, equals(params2));
    });

    test('doit avoir des props correctes', () {
      // arrange
      const params = SellerLoginParams(email: tEmail, password: tPassword);

      // assert
      expect(params.props, [tEmail, tPassword]);
    });
  });
}