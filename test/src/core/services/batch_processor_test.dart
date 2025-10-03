import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/core/services/batch_processor.dart';

void main() {
  group('BatchProcessor', () {
    late List<String> processedItems;
    late BatchProcessor<String> batchProcessor;

    setUp(() {
      processedItems = [];
    });

    tearDown(() {
      batchProcessor.dispose();
    });

    test('devrait traiter un batch quand la taille max est atteinte', () async {
      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(seconds: 10),
        maxBatchSize: 3,
        processor: (items) async {
          processedItems.addAll(items);
        },
      );

      // Ajouter 3 items pour atteindre la taille max
      batchProcessor.add('item1');
      batchProcessor.add('item2');
      batchProcessor.add('item3');

      // Attendre un peu pour que le traitement se fasse
      await Future.delayed(const Duration(milliseconds: 100));

      expect(processedItems, ['item1', 'item2', 'item3']);
    });

    test('devrait traiter un batch après le délai configuré', () async {
      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(milliseconds: 200),
        maxBatchSize: 10,
        processor: (items) async {
          processedItems.addAll(items);
        },
      );

      batchProcessor.add('item1');
      batchProcessor.add('item2');

      // Les items ne devraient pas encore être traités
      expect(processedItems, isEmpty);

      // Attendre le délai + un peu plus
      await Future.delayed(const Duration(milliseconds: 300));

      expect(processedItems, ['item1', 'item2']);
    });

    test('devrait traiter plusieurs items avec addAll', () async {
      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(seconds: 10),
        maxBatchSize: 5,
        processor: (items) async {
          processedItems.addAll(items);
        },
      );

      batchProcessor.addAll(['item1', 'item2', 'item3', 'item4', 'item5']);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(processedItems.length, 5);
      expect(processedItems, contains('item1'));
      expect(processedItems, contains('item5'));
    });

    test('devrait traiter immédiatement avec addAll si taille max atteinte', () async {
      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(seconds: 10),
        maxBatchSize: 3,
        processor: (items) async {
          processedItems.addAll(items);
        },
      );

      batchProcessor.addAll(['item1', 'item2', 'item3', 'item4']);

      await Future.delayed(const Duration(milliseconds: 100));

      // Devrait traiter au moins 3 items immédiatement
      expect(processedItems.length, greaterThanOrEqualTo(3));
    });

    test('flush devrait forcer le traitement immédiat', () async {
      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(seconds: 10),
        maxBatchSize: 10,
        processor: (items) async {
          processedItems.addAll(items);
        },
      );

      batchProcessor.add('item1');
      batchProcessor.add('item2');

      // Les items ne devraient pas encore être traités
      expect(processedItems, isEmpty);

      // Forcer le traitement
      await batchProcessor.flush();

      expect(processedItems, ['item1', 'item2']);
    });

    test('flush ne devrait rien faire si le batch est vide', () async {
      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(seconds: 10),
        maxBatchSize: 10,
        processor: (items) async {
          processedItems.addAll(items);
        },
      );

      await batchProcessor.flush();

      expect(processedItems, isEmpty);
    });

    test('devrait gérer les erreurs de traitement sans crasher', () async {
      var callCount = 0;

      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(milliseconds: 100),
        maxBatchSize: 2,
        processor: (items) async {
          callCount++;
          throw Exception('Erreur de traitement');
        },
      );

      batchProcessor.add('item1');
      batchProcessor.add('item2');

      await Future.delayed(const Duration(milliseconds: 200));

      // Le processor devrait avoir été appelé malgré l'erreur
      expect(callCount, 1);
    });

    test('devrait remettre les items dans la file en cas d\'erreur', () async {
      var attemptCount = 0;

      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(milliseconds: 100),
        maxBatchSize: 2,
        processor: (items) async {
          attemptCount++;
          if (attemptCount == 1) {
            throw Exception('Erreur temporaire');
          }
          processedItems.addAll(items);
        },
      );

      batchProcessor.add('item1');
      batchProcessor.add('item2');

      // Attendre la première tentative (qui échoue)
      await Future.delayed(const Duration(milliseconds: 200));

      // Les items devraient être remis dans la file
      expect(processedItems, isEmpty);

      // Forcer un nouveau traitement
      await batchProcessor.flush();

      // Cette fois ça devrait marcher
      expect(processedItems, ['item1', 'item2']);
      expect(attemptCount, 2);
    });

    test('dispose devrait annuler le timer et vider la file', () async {
      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(seconds: 10),
        maxBatchSize: 10,
        processor: (items) async {
          processedItems.addAll(items);
        },
      );

      batchProcessor.add('item1');
      batchProcessor.add('item2');

      batchProcessor.dispose();

      // Attendre pour vérifier que rien n'est traité
      await Future.delayed(const Duration(milliseconds: 100));

      expect(processedItems, isEmpty);
    });

    test('devrait réinitialiser le timer quand on ajoute un nouvel item', () async {
      batchProcessor = BatchProcessor<String>(
        batchDelay: const Duration(milliseconds: 300),
        maxBatchSize: 10,
        processor: (items) async {
          processedItems.addAll(items);
        },
      );

      batchProcessor.add('item1');
      await Future.delayed(const Duration(milliseconds: 150));

      // Ajouter un item pour réinitialiser le timer
      batchProcessor.add('item2');
      await Future.delayed(const Duration(milliseconds: 150));

      // Pas encore traité car le timer a été réinitialisé
      expect(processedItems, isEmpty);

      await Future.delayed(const Duration(milliseconds: 200));

      // Maintenant devrait être traité
      expect(processedItems, ['item1', 'item2']);
    });

    test('devrait gérer des types complexes (int)', () async {
      List<int> processedInts = [];
      final intProcessor = BatchProcessor<int>(
        batchDelay: const Duration(milliseconds: 100),
        maxBatchSize: 3,
        processor: (items) async {
          processedInts.addAll(items);
        },
      );

      intProcessor.add(1);
      intProcessor.add(2);
      intProcessor.add(3);

      await Future.delayed(const Duration(milliseconds: 150));

      expect(processedInts, [1, 2, 3]);

      intProcessor.dispose();
    });
  });

  group('MessageReadBatcher', () {
    late List<String> markedAsRead;
    late MessageReadBatcher batcher;

    setUp(() {
      markedAsRead = [];
      batcher = MessageReadBatcher(
        markAsRead: (messageIds) async {
          markedAsRead.addAll(messageIds);
        },
      );
    });

    tearDown(() {
      batcher.dispose();
    });

    test('devrait marquer les messages comme lus en batch', () async {
      batcher.markMessageAsRead('msg1');
      batcher.markMessageAsRead('msg2');
      batcher.markMessageAsRead('msg3');

      // Attendre que le batch soit traité (après 2 secondes ou 10 messages)
      await Future.delayed(const Duration(milliseconds: 2100));

      expect(markedAsRead, ['msg1', 'msg2', 'msg3']);
    });

    test('devrait traiter immédiatement si 10 messages sont ajoutés', () async {
      for (int i = 0; i < 10; i++) {
        batcher.markMessageAsRead('msg$i');
      }

      await Future.delayed(const Duration(milliseconds: 100));

      expect(markedAsRead.length, 10);
    });

    test('flush devrait forcer le traitement immédiat', () async {
      batcher.markMessageAsRead('msg1');
      batcher.markMessageAsRead('msg2');

      await batcher.flush();

      expect(markedAsRead, ['msg1', 'msg2']);
    });

    test('dispose devrait nettoyer les ressources', () async {
      batcher.markMessageAsRead('msg1');
      batcher.dispose();

      // Attendre pour s'assurer que rien n'est traité après dispose
      await Future.delayed(const Duration(seconds: 3));

      expect(markedAsRead, isEmpty);
    });
  });
}
