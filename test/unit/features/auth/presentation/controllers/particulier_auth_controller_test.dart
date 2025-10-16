import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/auth/domain/entities/particulier.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/get_current_particulier.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/particulier_anonymous_auth.dart';
import 'package:cente_pice/src/features/auth/domain/usecases/particulier_logout.dart';
import 'package:cente_pice/src/features/auth/presentation/controllers/particulier_auth_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'particulier_auth_controller_test.mocks.dart';

@GenerateMocks([
  ParticulierAnonymousAuth,
  ParticulierLogout,
  GetCurrentParticulier,
])
void main() {
  late ParticulierAuthController controller;
  late MockParticulierAnonymousAuth mockParticulierAnonymousAuth;
  late MockParticulierLogout mockParticulierLogout;
  late MockGetCurrentParticulier mockGetCurrentParticulier;

  setUp(() {
    mockParticulierAnonymousAuth = MockParticulierAnonymousAuth();
    mockParticulierLogout = MockParticulierLogout();
    mockGetCurrentParticulier = MockGetCurrentParticulier();

    controller = ParticulierAuthController(
      particulierAnonymousAuth: mockParticulierAnonymousAuth,
      particulierLogout: mockParticulierLogout,
      getCurrentParticulier: mockGetCurrentParticulier,
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

  group('ParticulierAuthController', () {
    test('l\'état initial doit être ParticulierAuthState.initial', () {
      expect(controller.state, const ParticulierAuthState.initial());
    });

    group('signInAnonymously', () {
      test(
          'doit émettre [loading, anonymousAuthenticated] quand la connexion réussit',
          () async {
        // arrange
        when(mockParticulierAnonymousAuth(any))
            .thenAnswer((_) async => Right(tParticulier));

        // act
        final future = controller.signInAnonymously();

        // assert
        expect(controller.state, const ParticulierAuthState.loading());

        await future;
        expect(controller.state,
            ParticulierAuthState.anonymousAuthenticated(tParticulier));
        verify(mockParticulierAnonymousAuth(NoParams()));
      });

      test('doit émettre [loading, error] quand la connexion échoue', () async {
        // arrange
        when(mockParticulierAnonymousAuth(any)).thenAnswer(
            (_) async => const Left(ServerFailure('Erreur serveur')));

        // act
        final future = controller.signInAnonymously();

        // assert
        expect(controller.state, const ParticulierAuthState.loading());

        await future;
        expect(controller.state,
            const ParticulierAuthState.error('Erreur serveur'));
        verify(mockParticulierAnonymousAuth(NoParams()));
      });

      test('doit mapper correctement les NetworkFailure', () async {
        // arrange
        when(mockParticulierAnonymousAuth(any)).thenAnswer(
            (_) async => const Left(NetworkFailure('Pas de connexion')));

        // act
        await controller.signInAnonymously();

        // assert
        expect(controller.state,
            const ParticulierAuthState.error('Pas de connexion'));
      });

      test('doit mapper correctement les AuthFailure', () async {
        // arrange
        when(mockParticulierAnonymousAuth(any)).thenAnswer(
            (_) async => const Left(AuthFailure('Authentification refusée')));

        // act
        await controller.signInAnonymously();

        // assert
        expect(controller.state,
            const ParticulierAuthState.error('Authentification refusée'));
      });
    });

    group('logout', () {
      test('doit émettre [loading, initial] quand la déconnexion réussit',
          () async {
        // arrange
        when(mockParticulierLogout(any))
            .thenAnswer((_) async => const Right(null));

        // act
        final future = controller.logout();

        // assert
        expect(controller.state, const ParticulierAuthState.loading());

        await future;
        expect(controller.state, const ParticulierAuthState.initial());
        verify(mockParticulierLogout(NoParams()));
      });

      test('doit émettre [loading, error] quand la déconnexion échoue',
          () async {
        // arrange
        when(mockParticulierLogout(any)).thenAnswer(
            (_) async => const Left(ServerFailure('Erreur déconnexion')));

        // act
        final future = controller.logout();

        // assert
        expect(controller.state, const ParticulierAuthState.loading());

        await future;
        expect(controller.state,
            const ParticulierAuthState.error('Erreur déconnexion'));
        verify(mockParticulierLogout(NoParams()));
      });
    });

    group('getCurrentParticulier', () {
      test(
          'doit émettre [loading, anonymousAuthenticated] quand la récupération réussit',
          () async {
        // arrange
        when(mockGetCurrentParticulier(any))
            .thenAnswer((_) async => Right(tParticulier));

        // act
        final future = controller.getCurrentParticulier();

        // assert
        expect(controller.state, const ParticulierAuthState.loading());

        await future;
        expect(controller.state,
            ParticulierAuthState.anonymousAuthenticated(tParticulier));
        verify(mockGetCurrentParticulier(NoParams()));
      });

      test('doit émettre [loading, initial] quand la récupération échoue',
          () async {
        // arrange
        when(mockGetCurrentParticulier(any))
            .thenAnswer((_) async => const Left(AuthFailure('Non connecté')));

        // act
        final future = controller.getCurrentParticulier();

        // assert
        expect(controller.state, const ParticulierAuthState.loading());

        await future;
        expect(controller.state, const ParticulierAuthState.initial());
        verify(mockGetCurrentParticulier(NoParams()));
      });
    });

    group('checkAuthStatus', () {
      test(
          'doit mettre l\'état à anonymousAuthenticated si un particulier existe',
          () async {
        // arrange
        when(mockGetCurrentParticulier(any))
            .thenAnswer((_) async => Right(tParticulier));

        // act
        await controller.checkAuthStatus();

        // assert
        expect(controller.state,
            ParticulierAuthState.anonymousAuthenticated(tParticulier));
        verify(mockGetCurrentParticulier(NoParams()));
      });

      test('doit mettre l\'état à initial si aucun particulier n\'existe',
          () async {
        // arrange
        when(mockGetCurrentParticulier(any))
            .thenAnswer((_) async => const Left(AuthFailure('Non connecté')));

        // act
        await controller.checkAuthStatus();

        // assert
        expect(controller.state, const ParticulierAuthState.initial());
        verify(mockGetCurrentParticulier(NoParams()));
      });

      test('doit gérer les exceptions et mettre l\'état à initial', () async {
        // arrange
        when(mockGetCurrentParticulier(any))
            .thenThrow(Exception('Erreur inattendue'));

        // act
        await controller.checkAuthStatus();

        // assert
        expect(controller.state, const ParticulierAuthState.initial());
      });
    });

    group('resetState', () {
      test('doit remettre l\'état à initial', () {
        // arrange - mettre le controller dans un état différent
        controller.state =
            ParticulierAuthState.anonymousAuthenticated(tParticulier);

        // act
        controller.resetState();

        // assert
        expect(controller.state, const ParticulierAuthState.initial());
      });
    });

    group('_mapFailureToMessage', () {
      test('doit mapper correctement toutes les types de Failure', () async {
        final failures = [
          const ServerFailure('Erreur serveur'),
          const NetworkFailure('Erreur réseau'),
          const AuthFailure('Erreur auth'),
          const ValidationFailure('Erreur validation'),
          const CacheFailure('Erreur cache'),
        ];

        for (final failure in failures) {
          when(mockParticulierAnonymousAuth(any))
              .thenAnswer((_) async => Left(failure));

          await controller.signInAnonymously();

          expect(controller.state, ParticulierAuthState.error(failure.message));
        }
      });
    });

    group('ParticulierAuthStateX extension', () {
      test('isLoading doit retourner true pour l\'état loading', () {
        controller.state = const ParticulierAuthState.loading();
        expect(controller.state.isLoading, true);
        expect(controller.state.isAuthenticated, false);
        expect(controller.state.isError, false);
        expect(controller.state.isInitial, false);
      });

      test(
          'isAuthenticated doit retourner true pour l\'état anonymousAuthenticated',
          () {
        controller.state =
            ParticulierAuthState.anonymousAuthenticated(tParticulier);
        expect(controller.state.isAuthenticated, true);
        expect(controller.state.isLoading, false);
        expect(controller.state.isError, false);
        expect(controller.state.isInitial, false);
      });

      test('isError doit retourner true pour l\'état error', () {
        controller.state = const ParticulierAuthState.error('Erreur test');
        expect(controller.state.isError, true);
        expect(controller.state.isLoading, false);
        expect(controller.state.isAuthenticated, false);
        expect(controller.state.isInitial, false);
      });

      test('isInitial doit retourner true pour l\'état initial', () {
        controller.state = const ParticulierAuthState.initial();
        expect(controller.state.isInitial, true);
        expect(controller.state.isLoading, false);
        expect(controller.state.isAuthenticated, false);
        expect(controller.state.isError, false);
      });

      test(
          'particulier doit retourner le particulier pour l\'état anonymousAuthenticated',
          () {
        controller.state =
            ParticulierAuthState.anonymousAuthenticated(tParticulier);
        expect(controller.state.particulier, tParticulier);
      });

      test('particulier doit retourner null pour les autres états', () {
        controller.state = const ParticulierAuthState.initial();
        expect(controller.state.particulier, null);

        controller.state = const ParticulierAuthState.loading();
        expect(controller.state.particulier, null);

        controller.state = const ParticulierAuthState.error('Erreur');
        expect(controller.state.particulier, null);
      });

      test('errorMessage doit retourner le message pour l\'état error', () {
        const errorMsg = 'Message d\'erreur test';
        controller.state = const ParticulierAuthState.error(errorMsg);
        expect(controller.state.errorMessage, errorMsg);
      });

      test('errorMessage doit retourner null pour les autres états', () {
        controller.state = const ParticulierAuthState.initial();
        expect(controller.state.errorMessage, null);

        controller.state = const ParticulierAuthState.loading();
        expect(controller.state.errorMessage, null);

        controller.state =
            ParticulierAuthState.anonymousAuthenticated(tParticulier);
        expect(controller.state.errorMessage, null);
      });
    });

    group('Gestion des états complexes', () {
      test('doit gérer une séquence complète connexion -> déconnexion',
          () async {
        // arrange
        when(mockParticulierAnonymousAuth(any))
            .thenAnswer((_) async => Right(tParticulier));
        when(mockParticulierLogout(any))
            .thenAnswer((_) async => const Right(null));

        // act & assert - connexion
        await controller.signInAnonymously();
        expect(controller.state,
            ParticulierAuthState.anonymousAuthenticated(tParticulier));

        // act & assert - déconnexion
        await controller.logout();
        expect(controller.state, const ParticulierAuthState.initial());
      });

      test('doit gérer plusieurs tentatives de connexion consécutives',
          () async {
        // arrange
        when(mockParticulierAnonymousAuth(any))
            .thenAnswer((_) async => Right(tParticulier));

        // act & assert
        await controller.signInAnonymously();
        expect(controller.state,
            ParticulierAuthState.anonymousAuthenticated(tParticulier));

        await controller.signInAnonymously();
        expect(controller.state,
            ParticulierAuthState.anonymousAuthenticated(tParticulier));

        verify(mockParticulierAnonymousAuth(NoParams())).called(2);
      });

      test('doit permettre une nouvelle connexion après une erreur', () async {
        // arrange - première tentative (échec)
        when(mockParticulierAnonymousAuth(any)).thenAnswer(
            (_) async => const Left(ServerFailure('Erreur serveur')));

        // act & assert - première tentative (échec)
        await controller.signInAnonymously();
        expect(controller.state,
            const ParticulierAuthState.error('Erreur serveur'));

        // arrange - deuxième tentative (succès)
        when(mockParticulierAnonymousAuth(any))
            .thenAnswer((_) async => Right(tParticulier));

        // act & assert - deuxième tentative (succès)
        await controller.signInAnonymously();
        expect(controller.state,
            ParticulierAuthState.anonymousAuthenticated(tParticulier));
      });
    });
  });
}
