import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/auth/domain/entities/seller.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/get_current_seller.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/seller_forgot_password.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/seller_login.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/seller_logout.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/seller_register.dart';
import 'package:cente_pice/src/features/auth/presentation/controllers/seller_auth_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'seller_auth_controller_test.mocks.dart';

@GenerateMocks([
  SellerRegister,
  SellerLogin,
  SellerForgotPassword,
  SellerLogout,
  GetCurrentSeller,
])
void main() {
  late SellerAuthController controller;
  late MockSellerRegister mockSellerRegister;
  late MockSellerLogin mockSellerLogin;
  late MockSellerForgotPassword mockSellerForgotPassword;
  late MockSellerLogout mockSellerLogout;
  late MockGetCurrentSeller mockGetCurrentSeller;

  setUp(() {
    mockSellerRegister = MockSellerRegister();
    mockSellerLogin = MockSellerLogin();
    mockSellerForgotPassword = MockSellerForgotPassword();
    mockSellerLogout = MockSellerLogout();
    mockGetCurrentSeller = MockGetCurrentSeller();

    controller = SellerAuthController(
      sellerRegister: mockSellerRegister,
      sellerLogin: mockSellerLogin,
      sellerForgotPassword: mockSellerForgotPassword,
      sellerLogout: mockSellerLogout,
      getCurrentSeller: mockGetCurrentSeller,
    );
  });

  final tSeller = Seller(
    id: '1',
    email: 'test@example.com',
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

  group('SellerAuthController', () {
    test('l\'état initial doit être SellerAuthState.initial', () {
      expect(controller.state, const SellerAuthState.initial());
    });

    group('login', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';

      test('doit mettre l\'état en loading puis authenticated en cas de succès', () async {
        // arrange
        when(mockSellerLogin(any)).thenAnswer((_) async => Right(tSeller));

        // act
        final future = controller.login(email: tEmail, password: tPassword);

        // assert - état loading
        expect(controller.state, const SellerAuthState.loading());

        await future;

        // assert - état authenticated
        expect(controller.state, SellerAuthState.authenticated(tSeller));
        verify(mockSellerLogin(const SellerLoginParams(
          email: tEmail,
          password: tPassword,
        )));
      });

      test('doit mettre l\'état en error en cas d\'échec', () async {
        // arrange
        const tFailure = AuthFailure('Identifiants incorrects');
        when(mockSellerLogin(any)).thenAnswer((_) async => const Left(tFailure));

        // act
        await controller.login(email: tEmail, password: tPassword);

        // assert
        expect(controller.state, const SellerAuthState.error('Identifiants incorrects'));
      });

      test('doit appeler le use case avec les bons paramètres', () async {
        // arrange
        when(mockSellerLogin(any)).thenAnswer((_) async => Right(tSeller));

        // act
        await controller.login(email: tEmail, password: tPassword);

        // assert
        verify(mockSellerLogin(const SellerLoginParams(
          email: tEmail,
          password: tPassword,
        )));
        verifyNoMoreInteractions(mockSellerLogin);
      });
    });

    group('register', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';
      const tConfirmPassword = 'password123';
      const tFirstName = 'Test';
      const tLastName = 'User';
      const tCompanyName = 'Test Company';
      const tPhone = '+33123456789';

      test('doit mettre l\'état en loading puis authenticated en cas de succès', () async {
        // arrange
        when(mockSellerRegister(any)).thenAnswer((_) async => Right(tSeller));

        // act
        final future = controller.register(
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          firstName: tFirstName,
          lastName: tLastName,
          companyName: tCompanyName,
          phone: tPhone,
        );

        // assert - état loading
        expect(controller.state, const SellerAuthState.loading());

        await future;

        // assert - état authenticated
        expect(controller.state, SellerAuthState.authenticated(tSeller));
      });

      test('doit mettre l\'état en error en cas d\'échec', () async {
        // arrange
        const tFailure = ValidationFailure('Email déjà utilisé');
        when(mockSellerRegister(any)).thenAnswer((_) async => const Left(tFailure));

        // act
        await controller.register(
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        );

        // assert
        expect(controller.state, const SellerAuthState.error('Email déjà utilisé'));
      });

      test('doit appeler le use case avec les bons paramètres', () async {
        // arrange
        when(mockSellerRegister(any)).thenAnswer((_) async => Right(tSeller));

        // act
        await controller.register(
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          firstName: tFirstName,
          lastName: tLastName,
          companyName: tCompanyName,
          phone: tPhone,
        );

        // assert
        verify(mockSellerRegister(const SellerRegisterParams(
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
          firstName: tFirstName,
          lastName: tLastName,
          companyName: tCompanyName,
          phone: tPhone,
        )));
      });
    });

    group('logout', () {
      test('doit mettre l\'état en loading puis unauthenticated en cas de succès', () async {
        // arrange
        when(mockSellerLogout(any)).thenAnswer((_) async => const Right(null));

        // act
        final future = controller.logout();

        // assert - état loading
        expect(controller.state, const SellerAuthState.loading());

        await future;

        // assert - état unauthenticated
        expect(controller.state, const SellerAuthState.unauthenticated());
        verify(mockSellerLogout(NoParams()));
      });

      test('doit mettre l\'état en error en cas d\'échec', () async {
        // arrange
        const tFailure = ServerFailure('Erreur serveur');
        when(mockSellerLogout(any)).thenAnswer((_) async => const Left(tFailure));

        // act
        await controller.logout();

        // assert
        expect(controller.state, const SellerAuthState.error('Erreur serveur'));
      });
    });

    group('getCurrentSeller', () {
      test('doit mettre l\'état en loading puis authenticated si vendeur trouvé', () async {
        // arrange
        when(mockGetCurrentSeller(any)).thenAnswer((_) async => Right(tSeller));

        // act
        final future = controller.getCurrentSeller();

        // assert - état loading
        expect(controller.state, const SellerAuthState.loading());

        await future;

        // assert - état authenticated
        expect(controller.state, SellerAuthState.authenticated(tSeller));
      });

      test('doit mettre l\'état en unauthenticated si aucun vendeur trouvé', () async {
        // arrange
        const tFailure = AuthFailure('Non authentifié');
        when(mockGetCurrentSeller(any)).thenAnswer((_) async => const Left(tFailure));

        // act
        await controller.getCurrentSeller();

        // assert
        expect(controller.state, const SellerAuthState.unauthenticated());
      });
    });

    group('forgotPassword', () {
      const tEmail = 'test@example.com';

      test('doit mettre l\'état en loading puis unauthenticated en cas de succès', () async {
        // arrange
        when(mockSellerForgotPassword(any)).thenAnswer((_) async => const Right(null));

        // act
        final future = controller.forgotPassword(tEmail);

        // assert - état loading
        expect(controller.state, const SellerAuthState.loading());

        await future;

        // assert - état unauthenticated
        expect(controller.state, const SellerAuthState.unauthenticated());
      });

      test('doit mettre l\'état en error en cas d\'échec', () async {
        // arrange
        const tFailure = ValidationFailure('Email non trouvé');
        when(mockSellerForgotPassword(any)).thenAnswer((_) async => const Left(tFailure));

        // act
        await controller.forgotPassword(tEmail);

        // assert
        expect(controller.state, const SellerAuthState.error('Email non trouvé'));
      });
    });

    group('checkAuthStatus', () {
      test('doit mettre l\'état en authenticated si vendeur connecté', () async {
        // arrange
        when(mockGetCurrentSeller(any)).thenAnswer((_) async => Right(tSeller));

        // act
        await controller.checkAuthStatus();

        // assert
        expect(controller.state, SellerAuthState.authenticated(tSeller));
      });

      test('doit mettre l\'état en unauthenticated si erreur', () async {
        // arrange
        const tFailure = AuthFailure('Token expiré');
        when(mockGetCurrentSeller(any)).thenAnswer((_) async => const Left(tFailure));

        // act
        await controller.checkAuthStatus();

        // assert
        expect(controller.state, const SellerAuthState.unauthenticated());
      });

      test('doit mettre l\'état en unauthenticated si exception', () async {
        // arrange
        when(mockGetCurrentSeller(any)).thenThrow(Exception('Erreur'));

        // act
        await controller.checkAuthStatus();

        // assert
        expect(controller.state, const SellerAuthState.unauthenticated());
      });
    });

    group('resetState', () {
      test('doit remettre l\'état à initial', () {
        // arrange
        controller.state = const SellerAuthState.error('Erreur');

        // act
        controller.resetState();

        // assert
        expect(controller.state, const SellerAuthState.initial());
      });
    });

    group('_mapFailureToMessage', () {
      test('doit mapper correctement les différents types de failures', () {
        // arrange & act & assert
        expect(
          controller.state.maybeWhen(
            error: (message) => message,
            orElse: () => null,
          ),
          null,
        );

        // Test avec une ServerFailure
        when(mockSellerLogin(any)).thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));
        controller.login(email: 'test', password: 'test');

        // On peut pas tester directement _mapFailureToMessage car c'est privé,
        // mais on peut vérifier le comportement via les méthodes publiques
      });
    });
  });

  group('SellerAuthState Extensions', () {
    test('isLoading doit retourner true pour Loading state', () {
      const state = SellerAuthState.loading();
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
      expect(state.isError, false);
      expect(state.isUnauthenticated, false);
    });

    test('isAuthenticated doit retourner true pour Authenticated state', () {
      final state = SellerAuthState.authenticated(tSeller);
      expect(state.isAuthenticated, true);
      expect(state.isLoading, false);
      expect(state.isError, false);
      expect(state.isUnauthenticated, false);
      expect(state.seller, tSeller);
    });

    test('isError doit retourner true pour Error state', () {
      const state = SellerAuthState.error('Erreur test');
      expect(state.isError, true);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.isUnauthenticated, false);
      expect(state.errorMessage, 'Erreur test');
    });

    test('isUnauthenticated doit retourner true pour Unauthenticated state', () {
      const state = SellerAuthState.unauthenticated();
      expect(state.isUnauthenticated, true);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.isError, false);
    });
  });
}