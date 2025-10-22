import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/core/usecases/usecase.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_request.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/get_seller_notifications.dart'
    hide SellerNotification;
import 'package:cente_pice/src/features/parts/presentation/controllers/seller_dashboard_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'seller_dashboard_controller_test.mocks.dart';

@GenerateMocks([GetSellerNotifications])
void main() {
  late SellerDashboardController controller;
  late MockGetSellerNotifications mockGetSellerNotifications;

  setUp(() {
    mockGetSellerNotifications = MockGetSellerNotifications();
    controller = SellerDashboardController(
      getSellerNotifications: mockGetSellerNotifications,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  final tPartRequest1 = PartRequest(
    id: '1',
    userId: 'user1',
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2018,
    partType: 'engine',
    partNames: ['moteur'],
    status: 'active',
    createdAt:
        DateTime.now().subtract(const Duration(hours: 12)), // Récent (nouveau)
    updatedAt: DateTime.now(),
  );

  final tPartRequest2 = PartRequest(
    id: '2',
    userId: 'user2',
    vehicleBrand: 'Renault',
    vehicleModel: 'Clio',
    vehicleYear: 2020,
    partType: 'body',
    partNames: ['pare-chocs'],
    status: 'active',
    createdAt: DateTime.now()
        .subtract(const Duration(days: 2)), // Ancien (pas nouveau)
    updatedAt: DateTime.now(),
  );

  final tPartRequestsList = [tPartRequest1, tPartRequest2];

  group('SellerDashboardController', () {
    test('doit avoir l\'état initial correct', () {
      expect(controller.state, const SellerDashboardState.initial());
      expect(controller.state.isInitial, true);
      expect(controller.state.isLoading, false);
      expect(controller.state.isLoaded, false);
      expect(controller.state.isError, false);
    });

    test('doit charger les notifications avec succès', () async {
      // arrange
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isLoaded, true);
      expect(controller.state.notifications?.length, 2);
      expect(controller.state.unreadCount,
          1); // Seul tPartRequest1 est récent (< 24h)

      final notifications = controller.state.notifications!;
      expect(notifications[0].partRequest.id, tPartRequest1.id);
      expect(notifications[0].isNew, true); // Créé il y a 12h
      expect(notifications[1].partRequest.id, tPartRequest2.id);
      expect(notifications[1].isNew, false); // Créé il y a 2 jours
    });

    test('doit passer par l\'état loading pendant le chargement', () async {
      // arrange
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      final loadingFuture = controller.loadNotifications();

      // assert - état loading pendant l'opération
      expect(controller.state.isLoading, true);

      await loadingFuture;

      // assert - état loaded après l'opération
      expect(controller.state.isLoaded, true);
      expect(controller.state.isLoading, false);
    });

    test('doit gérer les erreurs avec un état error', () async {
      // arrange
      const failure = ServerFailure('Erreur serveur');
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => const Left(failure));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isError, true);
      expect(controller.state.errorMessage, failure.toString());
      expect(controller.state.isLoaded, false);
      expect(controller.state.isLoading, false);
    });

    test('doit gérer une liste vide de notifications', () async {
      // arrange
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => const Right([]));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isLoaded, true);
      expect(controller.state.notifications, isEmpty);
      expect(controller.state.unreadCount, 0);
    });

    test('doit calculer correctement le nombre de notifications non lues',
        () async {
      // arrange - Toutes les demandes récentes (< 24h)
      final recentPartRequest1 = PartRequest(
        id: '3',
        userId: 'user3',
        partType: 'engine',
        partNames: ['alternateur'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now(),
      );

      final recentPartRequest2 = PartRequest(
        id: '4',
        userId: 'user4',
        partType: 'body',
        partNames: ['rétroviseur'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        updatedAt: DateTime.now(),
      );

      final recentRequests = [recentPartRequest1, recentPartRequest2];

      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right(recentRequests));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isLoaded, true);
      expect(controller.state.notifications?.length, 2);
      expect(controller.state.unreadCount, 2); // Toutes récentes
    });

    test('doit gérer le refresh en appelant loadNotifications', () async {
      // arrange
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      await controller.refresh();

      // assert
      expect(controller.state.isLoaded, true);
      expect(controller.state.notifications?.length, 2);
      verify(mockGetSellerNotifications(NoParams())).called(1);
    });

    test('doit gérer les erreurs d\'authentification', () async {
      // arrange
      const authFailure = AuthFailure('Non authentifié');
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => const Left(authFailure));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isError, true);
      expect(controller.state.errorMessage, authFailure.toString());
    });

    test('doit gérer les erreurs réseau', () async {
      // arrange
      const networkFailure = NetworkFailure('Pas de connexion internet');
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => const Left(networkFailure));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isError, true);
      expect(controller.state.errorMessage, networkFailure.toString());
    });

    test('doit traiter correctement les demandes anciennes (> 24h)', () async {
      // arrange - Demandes anciennes uniquement
      final oldPartRequest = PartRequest(
        id: '5',
        userId: 'user5',
        partType: 'engine',
        partNames: ['bougie'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      );

      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right([oldPartRequest]));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isLoaded, true);
      expect(controller.state.notifications?.length, 1);
      expect(controller.state.unreadCount, 0); // Aucune récente
      expect(controller.state.notifications?[0].isNew, false);
    });

    test('doit appeler le usecase une seule fois par loadNotifications',
        () async {
      // arrange
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      await controller.loadNotifications();

      // assert
      verify(mockGetSellerNotifications(NoParams())).called(1);
      verifyNoMoreInteractions(mockGetSellerNotifications);
    });

    test('doit permettre des appels multiples de loadNotifications', () async {
      // arrange
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right(tPartRequestsList));

      // act
      await controller.loadNotifications();
      await controller.loadNotifications();

      // assert
      verify(mockGetSellerNotifications(NoParams())).called(2);
      expect(controller.state.isLoaded, true);
    });

    test('doit préserver l\'état error après échec', () async {
      // arrange
      const failure = ServerFailure('Erreur test');
      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => const Left(failure));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isError, true);
      expect(controller.state.errorMessage, failure.toString());
      expect(controller.state.notifications, null);
      expect(controller.state.unreadCount, null);
    });

    test('doit gérer les exceptions du usecase', () async {
      // arrange
      when(mockGetSellerNotifications(NoParams()))
          .thenThrow(Exception('Exception inattendue'));

      // act & assert
      expect(
        () => controller.loadNotifications(),
        throwsA(isA<Exception>()),
      );
    });

    test('doit calculer correctement isNew basé sur 24h', () async {
      // arrange
      final now = DateTime.now();
      final exactLimit = PartRequest(
        id: '8',
        userId: 'user8',
        partType: 'engine',
        partNames: ['courroie'],
        status: 'active',
        createdAt: now.subtract(
            const Duration(hours: 24, minutes: 1)), // Juste au-dessus de 24h
        updatedAt: now,
      );

      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right([exactLimit]));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isLoaded, true);
      expect(controller.state.notifications?[0].isNew, false);
      expect(controller.state.unreadCount, 0);
    });

    test('doit gérer des demandes avec différents statuts', () async {
      // arrange
      final activeRequest = PartRequest(
        id: '9',
        userId: 'user9',
        partType: 'engine',
        partNames: ['radiateur'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        updatedAt: DateTime.now(),
      );

      final closedRequest = PartRequest(
        id: '10',
        userId: 'user10',
        partType: 'body',
        partNames: ['capot'],
        status: 'closed',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now(),
      );

      when(mockGetSellerNotifications(NoParams()))
          .thenAnswer((_) async => Right([activeRequest, closedRequest]));

      // act
      await controller.loadNotifications();

      // assert
      expect(controller.state.isLoaded, true);
      expect(controller.state.notifications?.length, 2);
      expect(controller.state.unreadCount, 2); // Les deux sont récentes
    });
  });

  group('SellerNotification', () {
    test('doit créer une notification récente correctement', () {
      // arrange
      final recentRequest = PartRequest(
        id: '1',
        userId: 'user1',
        partType: 'engine',
        partNames: ['moteur'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now(),
      );

      // act
      final notification = SellerNotification.fromPartRequest(recentRequest);

      // assert
      expect(notification.partRequest, recentRequest);
      expect(notification.isNew, true);
      expect(notification.createdAt, recentRequest.createdAt);
    });

    test('doit créer une notification ancienne correctement', () {
      // arrange
      final oldRequest = PartRequest(
        id: '2',
        userId: 'user2',
        partType: 'body',
        partNames: ['pare-chocs'],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      );

      // act
      final notification = SellerNotification.fromPartRequest(oldRequest);

      // assert
      expect(notification.partRequest, oldRequest);
      expect(notification.isNew, false);
      expect(notification.createdAt, oldRequest.createdAt);
    });
  });

  group('SellerDashboardStateX Extensions', () {
    test('doit détecter correctement les états', () {
      // Test état initial
      const initialState = SellerDashboardState.initial();
      expect(initialState.isInitial, true);
      expect(initialState.isLoading, false);
      expect(initialState.isLoaded, false);
      expect(initialState.isError, false);

      // Test état loading
      const loadingState = SellerDashboardState.loading();
      expect(loadingState.isLoading, true);
      expect(loadingState.isInitial, false);

      // Test état loaded
      final loadedState = SellerDashboardState.loaded(
        notifications: [],
        unreadCount: 0,
      );
      expect(loadedState.isLoaded, true);
      expect(loadedState.isLoading, false);

      // Test état error
      const errorState = SellerDashboardState.error('Erreur test');
      expect(errorState.isError, true);
      expect(errorState.isLoaded, false);
    });

    test('doit extraire correctement les données des états', () {
      // Test données état loaded
      final notifications = [
        SellerNotification(
          partRequest: tPartRequest1,
          isNew: true,
          createdAt: tPartRequest1.createdAt,
        ),
      ];

      final loadedState = SellerDashboardState.loaded(
        notifications: notifications,
        unreadCount: 1,
      );

      expect(loadedState.notifications, notifications);
      expect(loadedState.unreadCount, 1);
      expect(loadedState.errorMessage, null);

      // Test données état error
      const errorState = SellerDashboardState.error('Message d\'erreur');
      expect(errorState.errorMessage, 'Message d\'erreur');
      expect(errorState.notifications, null);
      expect(errorState.unreadCount, null);

      // Test données état initial
      const initialState = SellerDashboardState.initial();
      expect(initialState.notifications, null);
      expect(initialState.unreadCount, null);
      expect(initialState.errorMessage, null);
    });
  });
}
