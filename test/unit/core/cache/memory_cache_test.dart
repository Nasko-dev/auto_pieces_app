import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/core/cache/memory_cache.dart';

void main() {
  group('MemoryCache Tests', () {
    late MemoryCache<String> cache;

    setUp(() {
      cache = MemoryCache<String>();
    });

    tearDown(() {
      cache.dispose();
    });

    group('Constructor', () {
      test('should create cache with default TTL', () {
        final testCache = MemoryCache<String>();
        expect(testCache, isNotNull);
        testCache.dispose();
      });

      test('should create cache with custom TTL', () {
        final testCache = MemoryCache<String>(
          ttl: const Duration(seconds: 30),
        );
        expect(testCache, isNotNull);
        testCache.dispose();
      });
    });

    group('put/get', () {
      test('should store and retrieve value', () {
        const key = 'test-key';
        const value = 'test-value';

        cache.put(key, value);
        final result = cache.get(key);

        expect(result, equals(value));
      });

      test('should return null for non-existent key', () {
        final result = cache.get('non-existent');
        expect(result, isNull);
      });

      test('should overwrite existing value', () {
        const key = 'test-key';
        const value1 = 'value1';
        const value2 = 'value2';

        cache.put(key, value1);
        cache.put(key, value2);
        final result = cache.get(key);

        expect(result, equals(value2));
      });
    });

    group('getOrLoad', () {
      test('should load value when cache is empty', () async {
        const key = 'test-key';
        const expectedValue = 'loaded-value';

        Future<String> loader() async => expectedValue;

        final result = await cache.getOrLoad(key, loader);

        expect(result, equals(expectedValue));
        expect(cache.get(key), equals(expectedValue));
      });

      test('should return cached value without calling loader', () async {
        const key = 'test-key';
        const cachedValue = 'cached-value';
        const loaderValue = 'loader-value';

        cache.put(key, cachedValue);

        bool loaderCalled = false;
        Future<String> loader() async {
          loaderCalled = true;
          return loaderValue;
        }

        final result = await cache.getOrLoad(key, loader);

        expect(result, equals(cachedValue));
        expect(loaderCalled, isFalse);
      });

      test('should call loader when cached value is expired', () async {
        final shortTtlCache = MemoryCache<String>(
          ttl: const Duration(milliseconds: 50),
        );
        const key = 'test-key';
        const cachedValue = 'cached-value';
        const loaderValue = 'loader-value';

        shortTtlCache.put(key, cachedValue);

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 100));

        Future<String> loader() async => loaderValue;

        final result = await shortTtlCache.getOrLoad(key, loader);

        expect(result, equals(loaderValue));
        shortTtlCache.dispose();
      });
    });

    group('invalidate', () {
      test('should remove specific key from cache', () {
        const key1 = 'key1';
        const key2 = 'key2';
        const value1 = 'value1';
        const value2 = 'value2';

        cache.put(key1, value1);
        cache.put(key2, value2);

        cache.invalidate(key1);

        expect(cache.get(key1), isNull);
        expect(cache.get(key2), equals(value2));
      });

      test('should not throw when invalidating non-existent key', () {
        expect(() => cache.invalidate('non-existent'), returnsNormally);
      });
    });

    group('invalidateAll', () {
      test('should clear all cache entries', () {
        const key1 = 'key1';
        const key2 = 'key2';
        const value1 = 'value1';
        const value2 = 'value2';

        cache.put(key1, value1);
        cache.put(key2, value2);

        cache.invalidateAll();

        expect(cache.get(key1), isNull);
        expect(cache.get(key2), isNull);
      });

      test('should work on empty cache', () {
        expect(() => cache.invalidateAll(), returnsNormally);
      });
    });

    group('TTL and expiration', () {
      test('should return null for expired entries', () async {
        final shortTtlCache = MemoryCache<String>(
          ttl: const Duration(milliseconds: 50),
        );
        const key = 'test-key';
        const value = 'test-value';

        shortTtlCache.put(key, value);

        // Verify value is initially available
        expect(shortTtlCache.get(key), equals(value));

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 100));

        expect(shortTtlCache.get(key), isNull);
        shortTtlCache.dispose();
      });
    });

    group('cleanup', () {
      test('should periodically remove expired entries', () async {
        final shortTtlCache = MemoryCache<String>(
          ttl: const Duration(milliseconds: 50),
        );
        const key = 'test-key';
        const value = 'test-value';

        shortTtlCache.put(key, value);

        // Wait for expiration and cleanup
        await Future.delayed(const Duration(milliseconds: 150));

        // Verify entry was cleaned up
        expect(shortTtlCache.get(key), isNull);
        shortTtlCache.dispose();
      });
    });

    group('dispose', () {
      test('should cancel cleanup timer and clear cache', () {
        const key = 'test-key';
        const value = 'test-value';

        cache.put(key, value);
        cache.dispose();

        // After dispose, get should return null (cache cleared)
        expect(cache.get(key), isNull);
      });

      test('should be safe to call multiple times', () {
        cache.dispose();
        expect(() => cache.dispose(), returnsNormally);
      });
    });

    group('Different types', () {
      test('should work with int type', () {
        final intCache = MemoryCache<int>();
        const key = 'number';
        const value = 42;

        intCache.put(key, value);
        final result = intCache.get(key);

        expect(result, equals(value));
        intCache.dispose();
      });

      test('should work with complex objects', () {
        final listCache = MemoryCache<List<String>>();
        const key = 'list';
        const value = ['a', 'b', 'c'];

        listCache.put(key, value);
        final result = listCache.get(key);

        expect(result, equals(value));
        listCache.dispose();
      });
    });
  });
}
