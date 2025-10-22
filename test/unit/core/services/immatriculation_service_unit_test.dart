import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:cente_pice/src/core/services/immatriculation_service.dart';

// Mock client simple pour les tests unitaires
class MockHttpClient extends http.BaseClient {
  final http.Response Function(http.BaseRequest request)? onRequest;

  MockHttpClient({this.onRequest});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response =
        onRequest?.call(request) ?? http.Response('{"vehicles": []}', 200);

    return http.StreamedResponse(
      Stream.fromIterable([response.bodyBytes]),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  group('ImmatriculationService Unit Tests', () {
    late ImmatriculationService service;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      service = ImmatriculationService(
        apiUsername: 'test-username',
        httpClient: mockHttpClient,
      );
    });

    tearDown(() {
      service.dispose();
    });

    group('Configuration et initialisation', () {
      test('devrait initialiser avec les bons paramètres', () {
        expect(service.apiUsername, equals('test-username'));
        expect(service.httpClient, equals(mockHttpClient));
      });

      test('devrait utiliser un client par défaut si non fourni', () {
        final defaultService = ImmatriculationService(
          apiUsername: 'test-username',
        );

        expect(defaultService.httpClient, isA<http.Client>());
        expect(defaultService.apiUsername, equals('test-username'));

        defaultService.dispose();
      });

      test('dispose devrait fonctionner sans erreur', () {
        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('Validation des formats de plaque (sans appels réseau)', () {
      test('devrait rejeter les formats de plaque invalides', () async {
        final invalidPlates = [
          '',
          '123',
          'ABCD',
          'AB123',
          'AB@123CD',
        ];

        for (final plate in invalidPlates) {
          final result = await service.getVehicleInfoFromPlate(plate);
          expect(result.isLeft(), isTrue,
              reason: 'Plaque $plate devrait être invalide');
        }
      });
    });

    group('Configuration des propriétés', () {
      test('devrait avoir les bonnes propriétés d\'instance', () {
        expect(service.apiUsername, isA<String>());
        expect(service.httpClient, isA<http.BaseClient>());
      });

      test('devrait maintenir les paramètres configurés', () {
        const testUsername = 'test-config';
        final configuredService = ImmatriculationService(
          apiUsername: testUsername,
          httpClient: mockHttpClient,
        );

        expect(configuredService.apiUsername, equals(testUsername));
        expect(configuredService.httpClient, same(mockHttpClient));

        configuredService.dispose();
      });
    });

    group('Gestion des instances multiples', () {
      test('devrait permettre la création de multiples instances', () {
        final service1 = ImmatriculationService(
          apiUsername: 'user1',
          httpClient: MockHttpClient(),
        );

        final service2 = ImmatriculationService(
          apiUsername: 'user2',
          httpClient: MockHttpClient(),
        );

        expect(service1.apiUsername, equals('user1'));
        expect(service2.apiUsername, equals('user2'));
        expect(service1.httpClient, isNot(same(service2.httpClient)));

        service1.dispose();
        service2.dispose();
      });

      test('devrait gérer dispose sur multiples instances', () {
        final services = List.generate(
            3,
            (index) => ImmatriculationService(
                  apiUsername: 'user$index',
                  httpClient: MockHttpClient(),
                ));

        for (final service in services) {
          expect(() => service.dispose(), returnsNormally);
        }
      });
    });

    group('Interface et contrats', () {
      test('devrait implémenter les méthodes requises', () {
        expect(service.getVehicleInfoFromPlate, isA<Function>());
        expect(service.checkRemainingCredits, isA<Function>());
        expect(service.dispose, isA<Function>());
      });

      test('devrait accepter différents types de clients HTTP', () {
        final regularClient = http.Client();
        final serviceWithRegularClient = ImmatriculationService(
          apiUsername: 'test',
          httpClient: regularClient,
        );

        expect(serviceWithRegularClient.httpClient, same(regularClient));

        serviceWithRegularClient.dispose();
        regularClient.close();
      });
    });

    group('État et cycle de vie', () {
      test('devrait maintenir l\'état après création', () {
        const username = 'persistent-user';
        final persistentService = ImmatriculationService(
          apiUsername: username,
          httpClient: mockHttpClient,
        );

        expect(persistentService.apiUsername, equals(username));

        // L'état devrait persister
        expect(persistentService.apiUsername, equals(username));
        expect(persistentService.httpClient, same(mockHttpClient));

        persistentService.dispose();
      });

      test('devrait être sûr d\'appeler dispose plusieurs fois', () {
        expect(() {
          service.dispose();
          service.dispose();
          service.dispose();
        }, returnsNormally);
      });
    });

    group('Validation des paramètres', () {
      test('devrait accepter des noms d\'utilisateur variés', () {
        final validUsernames = [
          'user',
          'user123',
          'user_test',
          'user-test',
          'User123',
          'test@domain.com',
        ];

        for (final username in validUsernames) {
          final testService = ImmatriculationService(
            apiUsername: username,
            httpClient: MockHttpClient(),
          );

          expect(testService.apiUsername, equals(username));
          testService.dispose();
        }
      });
    });
  });
}
