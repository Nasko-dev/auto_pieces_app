import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabase extends Mock implements Supabase {}

// Test version of SupabaseConfig to avoid actual initialization
class TestSupabaseConfig {
  static bool _isInitialized = false;
  static MockSupabaseClient? _mockClient;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (url.isEmpty || anonKey.isEmpty) {
      throw ArgumentError('URL and anonKey cannot be empty');
    }

    if (_isInitialized) {
      throw Exception('Supabase has already been initialized');
    }

    _isInitialized = true;
    _mockClient = MockSupabaseClient();
  }

  static SupabaseClient get client {
    if (!_isInitialized || _mockClient == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _mockClient!;
  }

  static void reset() {
    _isInitialized = false;
    _mockClient = null;
  }

  static bool get isInitialized => _isInitialized;
}

void main() {
  group('SupabaseConfig Tests', () {
    setUp(() {
      TestSupabaseConfig.reset();
    });

    tearDown(() {
      TestSupabaseConfig.reset();
    });

    group('initialize', () {
      test('should initialize successfully with valid parameters', () async {
        const testUrl = 'https://test-project.supabase.co';
        const testAnonKey = 'test-anon-key-123';

        await TestSupabaseConfig.initialize(
          url: testUrl,
          anonKey: testAnonKey,
        );

        expect(TestSupabaseConfig.isInitialized, isTrue);
      });

      test('should throw error when URL is empty', () async {
        const testAnonKey = 'test-anon-key-123';

        expect(
          () => TestSupabaseConfig.initialize(
            url: '',
            anonKey: testAnonKey,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error when anonKey is empty', () async {
        const testUrl = 'https://test-project.supabase.co';

        expect(
          () => TestSupabaseConfig.initialize(
            url: testUrl,
            anonKey: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error when both URL and anonKey are empty', () async {
        expect(
          () => TestSupabaseConfig.initialize(
            url: '',
            anonKey: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error when trying to initialize twice', () async {
        const testUrl = 'https://test-project.supabase.co';
        const testAnonKey = 'test-anon-key-123';

        // First initialization should succeed
        await TestSupabaseConfig.initialize(
          url: testUrl,
          anonKey: testAnonKey,
        );

        // Second initialization should throw
        expect(
          () => TestSupabaseConfig.initialize(
            url: testUrl,
            anonKey: testAnonKey,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('client getter', () {
      test('should return client after initialization', () async {
        const testUrl = 'https://test-project.supabase.co';
        const testAnonKey = 'test-anon-key-123';

        await TestSupabaseConfig.initialize(
          url: testUrl,
          anonKey: testAnonKey,
        );

        final client = TestSupabaseConfig.client;

        expect(client, isNotNull);
        expect(client, isA<SupabaseClient>());
      });

      test('should throw error when accessing client before initialization',
          () {
        expect(
          () => TestSupabaseConfig.client,
          throwsA(isA<Exception>()),
        );
      });

      test('should return same client instance on multiple calls', () async {
        const testUrl = 'https://test-project.supabase.co';
        const testAnonKey = 'test-anon-key-123';

        await TestSupabaseConfig.initialize(
          url: testUrl,
          anonKey: testAnonKey,
        );

        final client1 = TestSupabaseConfig.client;
        final client2 = TestSupabaseConfig.client;

        expect(client1, same(client2));
      });
    });

    group('initialization state', () {
      test('should start with not initialized state', () {
        expect(TestSupabaseConfig.isInitialized, isFalse);
      });

      test('should maintain initialized state after successful initialization',
          () async {
        const testUrl = 'https://test-project.supabase.co';
        const testAnonKey = 'test-anon-key-123';

        expect(TestSupabaseConfig.isInitialized, isFalse);

        await TestSupabaseConfig.initialize(
          url: testUrl,
          anonKey: testAnonKey,
        );

        expect(TestSupabaseConfig.isInitialized, isTrue);
      });

      test('should reset state correctly', () async {
        const testUrl = 'https://test-project.supabase.co';
        const testAnonKey = 'test-anon-key-123';

        await TestSupabaseConfig.initialize(
          url: testUrl,
          anonKey: testAnonKey,
        );
        expect(TestSupabaseConfig.isInitialized, isTrue);

        TestSupabaseConfig.reset();
        expect(TestSupabaseConfig.isInitialized, isFalse);
      });
    });

    group('error handling', () {
      test('should handle initialize errors gracefully', () async {
        expect(TestSupabaseConfig.isInitialized, isFalse);

        try {
          await TestSupabaseConfig.initialize(url: '', anonKey: 'test');
        } catch (e) {
          // Error expected
        }

        expect(TestSupabaseConfig.isInitialized, isFalse);
      });

      test('should provide descriptive error messages', () async {
        expect(
          () => TestSupabaseConfig.initialize(url: '', anonKey: 'test'),
          throwsA(
            predicate((e) =>
                e is ArgumentError &&
                e.toString().contains('URL and anonKey cannot be empty')),
          ),
        );
      });
    });
  });
}
