import 'package:cente_pice/src/features/parts/presentation/controllers/base_conversation_controller.dart';
import 'package:flutter_test/flutter_test.dart';

// Controller concret pour tester la classe abstraite
class TestConversationController extends BaseConversationController<String> {
  TestConversationController() : super('initial');

  int pollCallCount = 0;
  bool shouldThrowError = false;

  Future<void> testPoll() async {
    pollCallCount++;
    if (shouldThrowError) {
      throw Exception('Test error');
    }
  }

  void updateState(String newState) {
    state = newState;
  }
}

void main() {
  late TestConversationController controller;

  setUp(() {
    controller = TestConversationController();
  });

  tearDown(() {
    if (controller.mounted) {
      controller.dispose();
    }
  });

  group('BaseConversationController', () {
    test('doit avoir l\'état initial correct', () {
      expect(controller.state, 'initial');
      expect(controller.isPollingActive, false);
    });

    test('doit permettre de mettre à jour l\'état', () {
      // act
      controller.updateState('updated');

      // assert
      expect(controller.state, 'updated');
    });

    group('startIntelligentPolling', () {
      test('doit démarrer le polling avec succès', () async {
        // act
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 10),
          onPoll: controller.testPoll,
          logPrefix: 'TestController',
        );

        // assert - polling actif immédiatement
        expect(controller.isPollingActive, true);

        // Attendre que le polling se déclenche
        await Future.delayed(const Duration(milliseconds: 25));

        // assert - la méthode de polling a été appelée
        expect(controller.pollCallCount, greaterThan(0));

        // Nettoyer
        controller.stopPolling();
      });

      test('doit appeler onPoll à intervalle régulier', () async {
        // act
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 10),
          onPoll: controller.testPoll,
        );

        // Attendre plusieurs cycles
        await Future.delayed(const Duration(milliseconds: 35));

        // assert - plusieurs appels
        expect(controller.pollCallCount, greaterThanOrEqualTo(2));

        // Nettoyer
        controller.stopPolling();
      });

      test('doit empêcher le démarrage multiple du polling', () {
        // act - premier démarrage
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 100),
          onPoll: controller.testPoll,
        );

        expect(controller.isPollingActive, true);

        // act - tentative de second démarrage
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 50),
          onPoll: controller.testPoll,
        );

        // assert - toujours actif avec les paramètres originaux
        expect(controller.isPollingActive, true);

        // Nettoyer
        controller.stopPolling();
      });

      test('doit gérer les erreurs dans onPoll', () async {
        // arrange
        controller.shouldThrowError = true;

        // act
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 10),
          onPoll: controller.testPoll,
          logPrefix: 'ErrorTest',
        );

        // Attendre que l'erreur se produise
        await Future.delayed(const Duration(milliseconds: 25));

        // assert - le polling continue malgré l'erreur
        expect(controller.isPollingActive, true);
        expect(controller.pollCallCount, greaterThan(0));

        // Nettoyer
        controller.stopPolling();
      });

      test('doit fonctionner sans logPrefix', () async {
        // act
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 10),
          onPoll: controller.testPoll,
        );

        // assert
        expect(controller.isPollingActive, true);

        // Attendre un cycle
        await Future.delayed(const Duration(milliseconds: 15));

        expect(controller.pollCallCount, greaterThan(0));

        // Nettoyer
        controller.stopPolling();
      });
    });

    group('stopPolling', () {
      test('doit arrêter le polling correctement', () async {
        // arrange - démarrer le polling
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 10),
          onPoll: controller.testPoll,
        );

        expect(controller.isPollingActive, true);

        // Attendre un cycle
        await Future.delayed(const Duration(milliseconds: 15));
        final initialCallCount = controller.pollCallCount;

        // act
        controller.stopPolling();

        // assert - polling arrêté
        expect(controller.isPollingActive, false);

        // Attendre et vérifier qu'aucun nouvel appel n'est fait
        await Future.delayed(const Duration(milliseconds: 20));
        expect(controller.pollCallCount, initialCallCount);
      });

      test('doit être safe d\'appeler stop sans polling actif', () {
        // act & assert - ne doit pas lever d'exception
        expect(() => controller.stopPolling(), returnsNormally);
        expect(controller.isPollingActive, false);
      });

      test('doit permettre de redémarrer après un stop', () async {
        // arrange - démarrer et arrêter
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 10),
          onPoll: controller.testPoll,
        );
        controller.stopPolling();

        expect(controller.isPollingActive, false);

        // act - redémarrer
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 10),
          onPoll: controller.testPoll,
        );

        // assert
        expect(controller.isPollingActive, true);

        // Attendre un cycle
        await Future.delayed(const Duration(milliseconds: 15));
        expect(controller.pollCallCount, greaterThan(0));

        // Nettoyer
        controller.stopPolling();
      });
    });

    group('isPollingActive', () {
      test('doit retourner l\'état correct du polling', () {
        // État initial
        expect(controller.isPollingActive, false);

        // Après démarrage
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 100),
          onPoll: controller.testPoll,
        );
        expect(controller.isPollingActive, true);

        // Après arrêt
        controller.stopPolling();
        expect(controller.isPollingActive, false);
      });
    });

    group('dispose', () {
      test('doit arrêter le polling lors du dispose', () async {
        // arrange - démarrer le polling
        controller.startIntelligentPolling(
          interval: const Duration(milliseconds: 10),
          onPoll: controller.testPoll,
        );

        expect(controller.isPollingActive, true);

        // Attendre un cycle
        await Future.delayed(const Duration(milliseconds: 15));
        final initialCallCount = controller.pollCallCount;

        // act
        controller.dispose();

        // assert - polling arrêté
        expect(controller.isPollingActive, false);

        // Attendre et vérifier qu'aucun nouvel appel n'est fait
        await Future.delayed(const Duration(milliseconds: 20));
        expect(controller.pollCallCount, initialCallCount);
      });

      test('doit être safe d\'appeler dispose sans polling actif', () {
        // act & assert - ne doit pas lever d'exception
        expect(() => controller.dispose(), returnsNormally);
        expect(controller.isPollingActive, false);
      });
    });

    test('doit gérer correctement le cycle de vie complet', () async {
      // Test d'un cycle complet avec plusieurs opérations
      expect(controller.isPollingActive, false);

      // Démarrer
      controller.startIntelligentPolling(
        interval: const Duration(milliseconds: 10),
        onPoll: controller.testPoll,
      );
      expect(controller.isPollingActive, true);

      // Attendre quelques cycles
      await Future.delayed(const Duration(milliseconds: 25));
      expect(controller.pollCallCount, greaterThan(1));

      // Arrêter
      controller.stopPolling();
      expect(controller.isPollingActive, false);

      final stopCallCount = controller.pollCallCount;

      // Redémarrer
      controller.startIntelligentPolling(
        interval: const Duration(milliseconds: 10),
        onPoll: controller.testPoll,
      );
      expect(controller.isPollingActive, true);

      // Attendre et vérifier que le polling reprend
      await Future.delayed(const Duration(milliseconds: 15));
      expect(controller.pollCallCount, greaterThan(stopCallCount));

      // Dispose final
      controller.dispose();
      expect(controller.isPollingActive, false);
    });

    test('doit maintenir l\'état du controller pendant le polling', () async {
      // arrange
      controller.updateState('polling_state');

      // act
      controller.startIntelligentPolling(
        interval: const Duration(milliseconds: 10),
        onPoll: controller.testPoll,
      );

      // Attendre quelques cycles
      await Future.delayed(const Duration(milliseconds: 25));

      // assert - l'état n'est pas affecté par le polling
      expect(controller.state, 'polling_state');
      expect(controller.pollCallCount, greaterThan(0));

      // Nettoyer
      controller.stopPolling();
    });

    test('doit permettre des intervalles différents', () async {
      // Test avec un intervalle très court
      controller.startIntelligentPolling(
        interval: const Duration(milliseconds: 5),
        onPoll: controller.testPoll,
      );

      await Future.delayed(const Duration(milliseconds: 20));
      final shortIntervalCalls = controller.pollCallCount;

      controller.stopPolling();
      controller.pollCallCount = 0;

      // Test avec un intervalle plus long
      controller.startIntelligentPolling(
        interval: const Duration(milliseconds: 15),
        onPoll: controller.testPoll,
      );

      await Future.delayed(const Duration(milliseconds: 20));
      final longIntervalCalls = controller.pollCallCount;

      // assert - intervalle court = plus d'appels
      expect(shortIntervalCalls, greaterThan(longIntervalCalls));

      // Nettoyer
      controller.stopPolling();
    });
  });
}