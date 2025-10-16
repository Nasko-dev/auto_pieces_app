import 'package:cente_pice/src/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NotificationService notificationService;

  setUp(() {
    notificationService = NotificationService();
  });

  group('NotificationService', () {
    group('Singleton Pattern', () {
      test('doit retourner la même instance', () {
        // act
        final instance1 = NotificationService();
        final instance2 = NotificationService();

        // assert
        expect(identical(instance1, instance2), true);
      });

      test('doit utiliser l\'instance globale', () {
        // act
        final globalInstance = notificationService;
        final newInstance = NotificationService();

        // assert
        expect(identical(globalInstance, newInstance), true);
      });
    });

    group('Messages Prédéfinis', () {
      test('doit avoir tous les messages part_request', () {
        // arrange & act & assert - vérifier que les méthodes existent
        expect(notificationService.showPartRequestCreated, isA<Function>());
        expect(notificationService.showPartRequestDeleted, isA<Function>());
      });

      test('doit avoir tous les messages conversation', () {
        // arrange & act & assert - vérifier que les méthodes existent
        expect(notificationService.showConversationClosed, isA<Function>());
        expect(notificationService.showConversationDeleted, isA<Function>());
        expect(notificationService.showSellerBlocked, isA<Function>());
      });

      test('doit avoir tous les messages message', () {
        // arrange & act & assert - vérifier que les méthodes existent
        expect(notificationService.showImageSent, isA<Function>());
        expect(notificationService.showImageUploading, isA<Function>());
      });

      test('doit avoir les messages génériques', () {
        // arrange & act & assert - vérifier que les méthodes existent
        expect(notificationService.showNetworkError, isA<Function>());
      });
    });

    group('Méthodes de Base', () {
      test('doit avoir la méthode show', () {
        // arrange & act & assert - vérifier que la méthode existe
        expect(notificationService.show, isA<Function>());
      });

      test('doit avoir la méthode success', () {
        // arrange & act & assert - vérifier que la méthode existe
        expect(notificationService.success, isA<Function>());
      });

      test('doit avoir la méthode error', () {
        // arrange & act & assert - vérifier que la méthode existe
        expect(notificationService.error, isA<Function>());
      });

      test('doit avoir la méthode warning', () {
        // arrange & act & assert - vérifier que la méthode existe
        expect(notificationService.warning, isA<Function>());
      });

      test('doit avoir la méthode info', () {
        // arrange & act & assert - vérifier que la méthode existe
        expect(notificationService.info, isA<Function>());
      });

      test('doit avoir la méthode showLoading', () {
        // arrange & act & assert - vérifier que la méthode existe
        expect(notificationService.showLoading, isA<Function>());
      });

      test('doit exécuter hideLoading sans erreur', () {
        // act & assert - méthode obsolète mais ne doit pas lever d'exception
        expect(() => notificationService.hideLoading(), returnsNormally);
      });
    });

    group('Actions et Callbacks', () {
      test('doit avoir la méthode showWithAction', () {
        // arrange & act & assert - vérifier que la méthode existe
        expect(notificationService.showWithAction, isA<Function>());
      });

      test('doit avoir la méthode showDeletingWithUndo', () {
        // arrange & act & assert - vérifier que la méthode existe
        expect(notificationService.showDeletingWithUndo, isA<Function>());
      });
    });

    group('Structure et API', () {
      test('doit être une classe singleton', () {
        // arrange
        final service1 = NotificationService();
        final service2 = NotificationService();

        // act & assert
        expect(identical(service1, service2), true);
        expect(service1.runtimeType, NotificationService);
      });

      test('doit avoir une API cohérente', () {
        // arrange & act & assert - vérifier l\'existence des méthodes principales
        expect(notificationService, isA<NotificationService>());
        expect(notificationService.show, isA<Function>());
        expect(notificationService.success, isA<Function>());
        expect(notificationService.error, isA<Function>());
        expect(notificationService.warning, isA<Function>());
        expect(notificationService.info, isA<Function>());
        expect(notificationService.showLoading, isA<Function>());
        expect(notificationService.hideLoading, isA<Function>());
      });
    });

    group('Service Global', () {
      test('doit exposer une instance globale', () {
        // arrange & act
        final globalService = notificationService;

        // assert
        expect(globalService, isA<NotificationService>());
        expect(globalService, isNotNull);
      });
    });
  });
}
