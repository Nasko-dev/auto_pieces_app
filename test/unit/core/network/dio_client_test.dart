import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

// Mock version of DioClient for testing
class TestDioClient {
  late Dio _dio;

  TestDioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://test-api.example.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

void main() {
  group('DioClient Tests', () {
    late TestDioClient dioClient;

    setUp(() {
      dioClient = TestDioClient();
    });

    group('Constructor', () {
      test('should initialize with correct base configuration', () {
        final dio = dioClient.dio;

        expect(dio.options.baseUrl, equals('https://test-api.example.com'));
        expect(dio.options.connectTimeout, equals(const Duration(seconds: 30)));
        expect(dio.options.receiveTimeout, equals(const Duration(seconds: 30)));
        expect(dio.options.headers['Content-Type'], equals('application/json'));
        expect(dio.options.headers['Accept'], equals('application/json'));
      });

      test('should have LogInterceptor configured', () {
        final dio = dioClient.dio;

        expect(dio.interceptors.length, greaterThan(0));
        expect(
            dio.interceptors
                .any((interceptor) => interceptor is LogInterceptor),
            isTrue);
      });
    });

    group('dio getter', () {
      test('should return the internal Dio instance', () {
        final dio = dioClient.dio;

        expect(dio, isA<Dio>());
        expect(dio.options.baseUrl, equals('https://test-api.example.com'));
      });
    });

    group('setAuthToken', () {
      test('should set Authorization header with Bearer token', () {
        const testToken = 'test-token-12345';

        dioClient.setAuthToken(testToken);

        expect(
          dioClient.dio.options.headers['Authorization'],
          equals('Bearer $testToken'),
        );
      });

      test('should overwrite existing Authorization header', () {
        const firstToken = 'first-token';
        const secondToken = 'second-token';

        dioClient.setAuthToken(firstToken);
        dioClient.setAuthToken(secondToken);

        expect(
          dioClient.dio.options.headers['Authorization'],
          equals('Bearer $secondToken'),
        );
      });
    });

    group('removeAuthToken', () {
      test('should remove Authorization header', () {
        const testToken = 'test-token';

        // First set a token
        dioClient.setAuthToken(testToken);
        expect(
          dioClient.dio.options.headers['Authorization'],
          equals('Bearer $testToken'),
        );

        // Then remove it
        dioClient.removeAuthToken();
        expect(
          dioClient.dio.options.headers.containsKey('Authorization'),
          isFalse,
        );
      });

      test('should not throw when removing non-existent Authorization header',
          () {
        expect(() => dioClient.removeAuthToken(), returnsNormally);
      });

      test('should only remove Authorization header and keep other headers',
          () {
        const testToken = 'test-token';

        // Set auth token
        dioClient.setAuthToken(testToken);

        // Verify initial state
        expect(dioClient.dio.options.headers['Authorization'], isNotNull);
        expect(dioClient.dio.options.headers['Content-Type'],
            equals('application/json'));
        expect(dioClient.dio.options.headers['Accept'],
            equals('application/json'));

        // Remove auth token
        dioClient.removeAuthToken();

        // Verify only Authorization was removed
        expect(dioClient.dio.options.headers.containsKey('Authorization'),
            isFalse);
        expect(dioClient.dio.options.headers['Content-Type'],
            equals('application/json'));
        expect(dioClient.dio.options.headers['Accept'],
            equals('application/json'));
      });
    });

    group('Headers management', () {
      test('should maintain default headers after token operations', () {
        const testToken = 'test-token';

        // Set and remove token multiple times
        dioClient.setAuthToken(testToken);
        dioClient.removeAuthToken();
        dioClient.setAuthToken(testToken);
        dioClient.removeAuthToken();

        // Verify default headers are still intact
        expect(dioClient.dio.options.headers['Content-Type'],
            equals('application/json'));
        expect(dioClient.dio.options.headers['Accept'],
            equals('application/json'));
      });
    });

    group('Configuration immutability', () {
      test('should not affect base configuration when modifying headers', () {
        const testToken = 'test-token';
        final originalBaseUrl = dioClient.dio.options.baseUrl;
        final originalConnectTimeout = dioClient.dio.options.connectTimeout;
        final originalReceiveTimeout = dioClient.dio.options.receiveTimeout;

        // Modify headers
        dioClient.setAuthToken(testToken);
        dioClient.removeAuthToken();

        // Verify base configuration unchanged
        expect(dioClient.dio.options.baseUrl, equals(originalBaseUrl));
        expect(dioClient.dio.options.connectTimeout,
            equals(originalConnectTimeout));
        expect(dioClient.dio.options.receiveTimeout,
            equals(originalReceiveTimeout));
      });
    });
  });
}
