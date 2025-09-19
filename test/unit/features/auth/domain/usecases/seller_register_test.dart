import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/auth/domain/entities/seller.dart';
import 'package:cente_pice/src/features/auth/domain/repositories/seller_auth_repository.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/seller_register.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'seller_register_test.mocks.dart';

@GenerateMocks([SellerAuthRepository])
void main() {
  late SellerRegister usecase;
  late MockSellerAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerAuthRepository();
    usecase = SellerRegister(mockRepository);
  });

  const String tEmail = 'test@example.com';
  const String tPassword = 'TestPass123!';
  const String tConfirmPassword = 'TestPass123!';
  const String tFirstName = 'Test';
  const String tLastName = 'User';
  const String tCompanyName = 'Test Company';
  const String tPhone = '+33123456789';

  final tSeller = Seller(
    id: '1',
    email: tEmail,
    firstName: tFirstName,
    lastName: tLastName,
    companyName: tCompanyName,
    phone: tPhone,
    createdAt: DateTime.now(),
    isActive: true,
  );

  group('SellerRegister', () {
    test('doit retourner un Seller quand l\'inscription est réussie', () async {
      // arrange
      when(mockRepository.registerSeller(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        companyName: anyNamed('companyName'),
        phone: anyNamed('phone'),
      )).thenAnswer((_) async => Right(tSeller));

      // act
      final result = await usecase(const SellerRegisterParams(
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        firstName: tFirstName,
        lastName: tLastName,
        companyName: tCompanyName,
        phone: tPhone,
      ));

      // assert
      expect(result, Right(tSeller));
      verify(mockRepository.registerSeller(
        email: tEmail.toLowerCase().trim(),
        password: tPassword,
        firstName: tFirstName.trim(),
        lastName: tLastName.trim(),
        companyName: tCompanyName.trim(),
        phone: tPhone.trim(),
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit normaliser l\'email (lowercase et trim)', () async {
      // arrange
      const String emailWithSpaces = '  TEST@EXAMPLE.COM  ';
      when(mockRepository.registerSeller(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        companyName: anyNamed('companyName'),
        phone: anyNamed('phone'),
      )).thenAnswer((_) async => Right(tSeller));

      // act
      await usecase(const SellerRegisterParams(
        email: emailWithSpaces,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        firstName: tFirstName,
        lastName: tLastName,
        companyName: tCompanyName,
        phone: tPhone,
      ));

      // assert
      verify(mockRepository.registerSeller(
        email: 'test@example.com',
        password: tPassword,
        firstName: tFirstName,
        lastName: tLastName,
        companyName: tCompanyName,
        phone: tPhone,
      ));
    });

    group('Validation des paramètres', () {
      test('doit retourner ValidationFailure quand l\'email est vide', () async {
        // act
        final result = await usecase(const SellerRegisterParams(
          email: '',
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ));

        // assert
        expect(result, const Left(ValidationFailure('L\'email est requis')));
        verifyZeroInteractions(mockRepository);
      });

      test('doit retourner ValidationFailure quand le mot de passe est vide', () async {
        // act
        final result = await usecase(const SellerRegisterParams(
          email: tEmail,
          password: '',
          confirmPassword: '',
        ));

        // assert
        expect(result, const Left(ValidationFailure('Le mot de passe est requis')));
        verifyZeroInteractions(mockRepository);
      });

      test('doit retourner ValidationFailure pour un mot de passe trop court', () async {
        // act
        final result = await usecase(const SellerRegisterParams(
          email: tEmail,
          password: 'short',
          confirmPassword: 'short',
        ));

        // assert
        expect(result, const Left(ValidationFailure('Le mot de passe doit contenir au moins 8 caractères')));
        verifyZeroInteractions(mockRepository);
      });

      test('doit retourner ValidationFailure quand les mots de passe ne correspondent pas', () async {
        // act
        final result = await usecase(const SellerRegisterParams(
          email: tEmail,
          password: tPassword,
          confirmPassword: 'DifferentPass123!',
        ));

        // assert
        expect(result, const Left(ValidationFailure('Les mots de passe ne correspondent pas')));
        verifyZeroInteractions(mockRepository);
      });

      test('doit retourner ValidationFailure pour un format d\'email invalide', () async {
        // arrange
        const String invalidEmail = 'invalid-email';

        // act
        final result = await usecase(const SellerRegisterParams(
          email: invalidEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ));

        // assert
        expect(result, const Left(ValidationFailure('Format d\'email invalide')));
        verifyZeroInteractions(mockRepository);
      });

      test('doit retourner ValidationFailure pour un mot de passe faible', () async {
        // arrange
        const String weakPassword = 'password'; // Pas de majuscule, chiffre ou caractère spécial

        // act
        final result = await usecase(const SellerRegisterParams(
          email: tEmail,
          password: weakPassword,
          confirmPassword: weakPassword,
        ));

        // assert
        expect(result, const Left(ValidationFailure(
          'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial'
        )));
        verifyZeroInteractions(mockRepository);
      });

      test('doit retourner ValidationFailure pour un nom d\'entreprise vide', () async {
        // act
        final result = await usecase(const SellerRegisterParams(
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          companyName: '   ', // Espaces uniquement
        ));

        // assert
        expect(result, const Left(ValidationFailure('Le nom d\'entreprise ne peut pas être vide')));
        verifyZeroInteractions(mockRepository);
      });

      test('doit retourner ValidationFailure pour un format de téléphone invalide', () async {
        // act
        final result = await usecase(const SellerRegisterParams(
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          phone: 'invalid-phone',
        ));

        // assert
        expect(result, const Left(ValidationFailure('Format de téléphone invalide')));
        verifyZeroInteractions(mockRepository);
      });
    });

    group('Validation du mot de passe fort', () {
      const validPasswords = [
        'TestPass123!',
        'MyStr0ng@Pass',
        'Secure123#',
        'ValidPass456!',
      ];

      const invalidPasswords = [
        'password', // Pas de majuscule, chiffre ou spécial
        'PASSWORD', // Pas de minuscule, chiffre ou spécial
        'Password', // Pas de chiffre ou spécial
        'Password123', // Pas de caractère spécial
        'short!1', // Trop court (8 caractères mais pas de majuscule)
      ];

      for (final password in validPasswords) {
        test('doit accepter le mot de passe fort: $password', () async {
          // arrange
          when(mockRepository.registerSeller(
            email: anyNamed('email'),
            password: anyNamed('password'),
            firstName: anyNamed('firstName'),
            lastName: anyNamed('lastName'),
            companyName: anyNamed('companyName'),
            phone: anyNamed('phone'),
          )).thenAnswer((_) async => Right(tSeller));

          // act
          final result = await usecase(SellerRegisterParams(
            email: tEmail,
            password: password,
            confirmPassword: password,
          ));

          // assert
          expect(result, Right(tSeller));
        });
      }

      for (final password in invalidPasswords) {
        test('doit rejeter le mot de passe faible: "$password"', () async {
          // act
          final result = await usecase(SellerRegisterParams(
            email: tEmail,
            password: password,
            confirmPassword: password,
          ));

          // assert
          expect(result, isA<Left<Failure, Seller>>());
          verifyZeroInteractions(mockRepository);
        });
      }
    });

    group('Validation du téléphone', () {
      const validPhones = [
        '+33123456789',
        '0123456789',
        '+33 1 23 45 67 89',
        '01.23.45.67.89',
        '01-23-45-67-89',
      ];

      const invalidPhones = [
        '123', // Trop court
        '+44123456789', // Pas français
        'invalid-phone',
        '',
      ];

      for (final phone in validPhones) {
        test('doit accepter le téléphone valide: $phone', () async {
          // arrange
          when(mockRepository.registerSeller(
            email: anyNamed('email'),
            password: anyNamed('password'),
            firstName: anyNamed('firstName'),
            lastName: anyNamed('lastName'),
            companyName: anyNamed('companyName'),
            phone: anyNamed('phone'),
          )).thenAnswer((_) async => Right(tSeller));

          // act
          final result = await usecase(SellerRegisterParams(
            email: tEmail,
            password: tPassword,
            confirmPassword: tConfirmPassword,
            phone: phone,
          ));

          // assert
          expect(result, Right(tSeller));
        });
      }

      for (final phone in invalidPhones) {
        test('doit rejeter le téléphone invalide: "$phone"', () async {
          // act
          final result = await usecase(SellerRegisterParams(
            email: tEmail,
            password: tPassword,
            confirmPassword: tConfirmPassword,
            phone: phone,
          ));

          // assert
          expect(result, isA<Left<Failure, Seller>>());
          verifyZeroInteractions(mockRepository);
        });
      }
    });

    test('doit propager les échecs du repository', () async {
      // arrange
      when(mockRepository.registerSeller(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        companyName: anyNamed('companyName'),
        phone: anyNamed('phone'),
      )).thenAnswer((_) async => const Left(ServerFailure('Email déjà utilisé')));

      // act
      final result = await usecase(const SellerRegisterParams(
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      ));

      // assert
      expect(result, const Left(ServerFailure('Email déjà utilisé')));
    });
  });

  group('SellerRegisterParams', () {
    test('doit être égaux avec les mêmes valeurs', () {
      // arrange
      const params1 = SellerRegisterParams(
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        firstName: tFirstName,
        lastName: tLastName,
        companyName: tCompanyName,
        phone: tPhone,
      );
      const params2 = SellerRegisterParams(
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        firstName: tFirstName,
        lastName: tLastName,
        companyName: tCompanyName,
        phone: tPhone,
      );

      // assert
      expect(params1, equals(params2));
    });

    test('doit avoir des props correctes', () {
      // arrange
      const params = SellerRegisterParams(
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
        firstName: tFirstName,
        lastName: tLastName,
        companyName: tCompanyName,
        phone: tPhone,
      );

      // assert
      expect(params.props, [
        tEmail,
        tPassword,
        tConfirmPassword,
        tFirstName,
        tLastName,
        tCompanyName,
        tPhone,
      ]);
    });
  });
}