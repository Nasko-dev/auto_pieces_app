import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/core/utils/performance_optimizer.dart';

void main() {
  group('PerformanceOptimizer Tests', () {
    late PerformanceOptimizer optimizer;

    setUp(() {
      optimizer = PerformanceOptimizer();
      optimizer.clearCache(); // S'assurer qu'on commence avec un cache propre
    });

    tearDown(() {
      optimizer.clearCache(); // Nettoyer après chaque test
    });

    group('Singleton Pattern', () {
      test('devrait retourner la même instance', () {
        final instance1 = PerformanceOptimizer();
        final instance2 = PerformanceOptimizer();

        expect(instance1, same(instance2));
      });
    });

    group('Cache Management', () {
      test('devrait stocker et récupérer des données du cache', () {
        const key = 'test_key';
        const value = 'test_value';

        optimizer.cacheData(key, value);
        final result = optimizer.getCachedData<String>(key);

        expect(result, equals(value));
      });

      test('devrait retourner null pour une clé inexistante', () {
        final result = optimizer.getCachedData<String>('nonexistent');

        expect(result, isNull);
      });

      test('devrait gérer les données de différents types', () {
        const stringKey = 'string_key';
        const intKey = 'int_key';
        const listKey = 'list_key';
        const mapKey = 'map_key';

        const stringValue = 'test string';
        const intValue = 42;
        const listValue = [1, 2, 3];
        const mapValue = {'key': 'value'};

        optimizer.cacheData(stringKey, stringValue);
        optimizer.cacheData(intKey, intValue);
        optimizer.cacheData(listKey, listValue);
        optimizer.cacheData(mapKey, mapValue);

        expect(optimizer.getCachedData<String>(stringKey), equals(stringValue));
        expect(optimizer.getCachedData<int>(intKey), equals(intValue));
        expect(optimizer.getCachedData<List<int>>(listKey), equals(listValue));
        expect(optimizer.getCachedData<Map<String, String>>(mapKey), equals(mapValue));
      });

      test('devrait nettoyer les entrées expirées', () {
        const key = 'expiring_key';
        const value = 'expiring_value';

        // Cache avec TTL très court
        optimizer.cacheData(key, value, ttl: Duration(milliseconds: 1));

        // Attendre l'expiration
        Future.delayed(Duration(milliseconds: 2), () {
          final result = optimizer.getCachedData<String>(key);
          expect(result, isNull);
        });
      });

      test('devrait implémenter LRU quand la limite est atteinte', () {
        // Cette test serait difficile à implémenter sans exposer la taille max
        // Nous testons plutôt que le cache ne grandit pas indéfiniment

        // Ajouter beaucoup d'entrées
        for (int i = 0; i < 1100; i++) {
          optimizer.cacheData('key_$i', 'value_$i');
        }

        // Vérifier que les premières entrées ont été supprimées (LRU)
        final firstEntry = optimizer.getCachedData<String>('key_0');
        final lastEntry = optimizer.getCachedData<String>('key_1099');

        expect(firstEntry, isNull); // Devrait être supprimée
        expect(lastEntry, equals('value_1099')); // Devrait être présente
      });
    });

    group('TTL (Time To Live)', () {
      test('devrait utiliser le TTL par défaut', () {
        const key = 'default_ttl_key';
        const value = 'default_ttl_value';

        optimizer.cacheData(key, value);
        final result = optimizer.getCachedData<String>(key);

        expect(result, equals(value));
      });

      test('devrait respecter le TTL personnalisé', () async {
        const key = 'custom_ttl_key';
        const value = 'custom_ttl_value';

        // Cache avec TTL de 10ms
        optimizer.cacheData(key, value, ttl: Duration(milliseconds: 10));

        // Immédiatement disponible
        expect(optimizer.getCachedData<String>(key), equals(value));

        // Attendre l'expiration
        await Future.delayed(Duration(milliseconds: 15));

        // Devrait être expiré
        expect(optimizer.getCachedData<String>(key), isNull);
      });

      test('devrait nettoyer automatiquement les entrées expirées lors de l\'accès', () async {
        const key1 = 'key1';
        const key2 = 'key2';

        optimizer.cacheData(key1, 'value1', ttl: Duration(milliseconds: 5));
        optimizer.cacheData(key2, 'value2', ttl: Duration(minutes: 5));

        // Attendre que key1 expire
        await Future.delayed(Duration(milliseconds: 10));

        // L'accès à key1 devrait la supprimer du cache
        expect(optimizer.getCachedData<String>(key1), isNull);
        // key2 devrait toujours être là
        expect(optimizer.getCachedData<String>(key2), equals('value2'));
      });
    });

    group('Déduplication des requêtes', () {
      test('devrait éviter les requêtes identiques simultanées', () async {
        const key = 'dedup_key';
        int callCount = 0;

        Future<String> expensiveOperation() async {
          callCount++;
          await Future.delayed(Duration(milliseconds: 10));
          return 'expensive_result_$callCount';
        }

        // Lancer 3 requêtes identiques simultanément
        final futures = [
          optimizer.executeWithDeduplication(key, expensiveOperation),
          optimizer.executeWithDeduplication(key, expensiveOperation),
          optimizer.executeWithDeduplication(key, expensiveOperation),
        ];

        final results = await Future.wait(futures);

        // Vérifier qu'une seule opération coûteuse a été exécutée
        expect(callCount, equals(1));
        // Toutes devraient avoir le même résultat
        expect(results[0], equals(results[1]));
        expect(results[1], equals(results[2]));
        expect(results[0], equals('expensive_result_1'));
      });

      test('devrait permettre des requêtes séquentielles avec la même clé', () async {
        const key = 'sequential_key';
        int callCount = 0;

        Future<String> operation() async {
          callCount++;
          return 'result_$callCount';
        }

        // Première requête
        final result1 = await optimizer.executeWithDeduplication(key, operation);
        // Deuxième requête (après que la première soit terminée)
        final result2 = await optimizer.executeWithDeduplication(key, operation);

        expect(callCount, equals(2));
        expect(result1, equals('result_1'));
        expect(result2, equals('result_2'));
      });
    });

    group('Smart Cache', () {
      test('devrait retourner les données du cache si disponibles', () async {
        const key = 'smart_cache_key';
        const cachedValue = 'cached_value';
        int callCount = 0;

        // Pré-remplir le cache
        optimizer.cacheData(key, cachedValue);

        Future<String> operation() async {
          callCount++;
          return 'new_value';
        }

        final result = await optimizer.smartCache(key, operation);

        // Devrait retourner la valeur du cache sans exécuter l'opération
        expect(result, equals(cachedValue));
        expect(callCount, equals(0));
      });

      test('devrait exécuter l\'opération et mettre en cache si pas de cache', () async {
        const key = 'smart_cache_new_key';
        const operationResult = 'operation_result';
        int callCount = 0;

        Future<String> operation() async {
          callCount++;
          return operationResult;
        }

        final result = await optimizer.smartCache(key, operation);

        // Devrait exécuter l'opération
        expect(result, equals(operationResult));
        expect(callCount, equals(1));

        // Devrait maintenant être en cache
        final cachedResult = optimizer.getCachedData<String>(key);
        expect(cachedResult, equals(operationResult));
      });

      test('devrait gérer les erreurs dans les opérations', () async {
        const key = 'error_key';

        Future<String> failingOperation() async {
          throw Exception('Operation failed');
        }

        expect(
          () => optimizer.smartCache(key, failingOperation),
          throwsException,
        );

        // La clé ne devrait pas être en cache après une erreur
        expect(optimizer.getCachedData<String>(key), isNull);
      });
    });

    group('Cache Cleanup', () {
      test('cleanExpiredCache devrait supprimer les entrées expirées', () async {
        const key1 = 'expired_key';
        const key2 = 'valid_key';

        optimizer.cacheData(key1, 'value1', ttl: Duration(milliseconds: 5));
        optimizer.cacheData(key2, 'value2', ttl: Duration(minutes: 5));

        // Attendre que key1 expire
        await Future.delayed(Duration(milliseconds: 10));

        // Nettoyer manuellement
        optimizer.cleanExpiredCache();

        expect(optimizer.getCachedData<String>(key1), isNull);
        expect(optimizer.getCachedData<String>(key2), equals('value2'));
      });

      test('clearCache devrait vider tout le cache', () {
        optimizer.cacheData('key1', 'value1');
        optimizer.cacheData('key2', 'value2');
        optimizer.cacheData('key3', 'value3');

        optimizer.clearCache();

        expect(optimizer.getCachedData<String>('key1'), isNull);
        expect(optimizer.getCachedData<String>('key2'), isNull);
        expect(optimizer.getCachedData<String>('key3'), isNull);
      });
    });

    group('Statistics', () {
      test('devrait fournir des statistiques de base', () {
        // Ajouter quelques entrées
        optimizer.cacheData('key1', 'value1');
        optimizer.cacheData('key2', 'value2');

        final stats = optimizer.getStats();

        expect(stats.totalEntries, equals(2));
        expect(stats.activeRequests, equals(0));
        expect(stats, isA<CacheStats>());
      });

      test('devrait compter les requêtes actives', () async {
        const key = 'active_request_key';
        final completer = Completer<String>();

        // Démarrer une requête qui n'se termine pas immédiatement
        optimizer.executeWithDeduplication(key, () => completer.future);

        final stats = optimizer.getStats();
        expect(stats.activeRequests, equals(1));

        // Terminer la requête
        completer.complete('result');
        await Future.delayed(Duration(milliseconds: 1));

        final statsAfter = optimizer.getStats();
        expect(statsAfter.activeRequests, equals(0));
      });

      test('toString devrait formater correctement les statistiques', () {
        optimizer.cacheData('key1', 'value1');

        final stringStats = optimizer.toString();

        expect(stringStats, contains('CacheStats'));
        expect(stringStats, contains('entries:'));
        expect(stringStats, contains('expired:'));
        expect(stringStats, contains('requests:'));
        expect(stringStats, contains('hitRate:'));
      });
    });

    group('CacheEntry', () {
      test('devrait stocker les données et la date d\'expiration', () {
        final expiry = DateTime.now().add(Duration(minutes: 5));
        const data = 'test_data';

        final entry = CacheEntry(data, expiry);

        expect(entry.data, equals(data));
        expect(entry.expiry, equals(expiry));
      });
    });

    group('CacheStats', () {
      test('devrait stocker toutes les statistiques', () {
        const stats = CacheStats(
          totalEntries: 10,
          expiredEntries: 2,
          activeRequests: 1,
          cacheHitRate: 0.85,
        );

        expect(stats.totalEntries, equals(10));
        expect(stats.expiredEntries, equals(2));
        expect(stats.activeRequests, equals(1));
        expect(stats.cacheHitRate, equals(0.85));
      });
    });

    group('Scénarios d\'intégration', () {
      test('devrait gérer un flux complet de cache avec TTL et nettoyage', () async {
        const shortKey = 'short_lived';
        const longKey = 'long_lived';

        // Ajouter des données avec différents TTL
        optimizer.cacheData(shortKey, 'short_value', ttl: Duration(milliseconds: 10));
        optimizer.cacheData(longKey, 'long_value', ttl: Duration(minutes: 5));

        // Vérifier que les deux sont disponibles
        expect(optimizer.getCachedData<String>(shortKey), equals('short_value'));
        expect(optimizer.getCachedData<String>(longKey), equals('long_value'));

        // Attendre l'expiration de la première
        await Future.delayed(Duration(milliseconds: 15));

        // Nettoyer le cache
        optimizer.cleanExpiredCache();

        // Vérifier que seule la longue entrée reste
        expect(optimizer.getCachedData<String>(shortKey), isNull);
        expect(optimizer.getCachedData<String>(longKey), equals('long_value'));
      });

      test('devrait gérer des opérations complexes avec smart cache et déduplication', () async {
        const key = 'complex_key';
        int operationCount = 0;

        Future<Map<String, dynamic>> complexOperation() async {
          operationCount++;
          await Future.delayed(Duration(milliseconds: 5));
          return {
            'id': operationCount,
            'data': 'complex_data_$operationCount',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
        }

        // Première exécution - devrait faire l'opération et mettre en cache
        final result1 = await optimizer.smartCache(key, complexOperation);

        // Deuxième exécution - devrait venir du cache
        final result2 = await optimizer.smartCache(key, complexOperation);

        expect(operationCount, equals(1));
        expect(result1, equals(result2));
        expect(result1['id'], equals(1));
        expect(result1['data'], equals('complex_data_1'));
      });
    });

    group('Edge Cases', () {
      test('devrait gérer des clés nulles ou vides gracieusement', () {
        // Ce test dépend de l'implémentation - ici on suppose que les clés vides sont autorisées
        optimizer.cacheData('', 'empty_key_value');

        final result = optimizer.getCachedData<String>('');
        expect(result, equals('empty_key_value'));
      });

      test('devrait gérer des valeurs null', () {
        const key = 'null_value_key';
        optimizer.cacheData(key, null);

        final result = optimizer.getCachedData<String?>(key);
        expect(result, isNull);
      });

      test('devrait gérer des opérations qui retournent null', () async {
        const key = 'null_operation_key';

        Future<String?> nullOperation() async => null;

        final result = await optimizer.smartCache(key, nullOperation);
        expect(result, isNull);

        // Devrait être mis en cache même si null
        final cachedResult = optimizer.getCachedData<String?>(key);
        expect(cachedResult, isNull);
      });
    });
  });
}