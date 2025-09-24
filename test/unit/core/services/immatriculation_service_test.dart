import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:cente_pice/src/core/services/immatriculation_service.dart';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/vehicle_info.dart';

// Mock client simple pour les tests
class MockHttpClient extends http.BaseClient {
  final http.Response Function(http.BaseRequest request)? onRequest;

  MockHttpClient({this.onRequest});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = onRequest?.call(request) ??
        http.Response('{"vehicles": []}', 200);

    return http.StreamedResponse(
      Stream.fromIterable([response.bodyBytes]),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  group('ImmatriculationService Tests', () {
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

    group('getVehicleInfoFromPlate', () {
      test('devrait retourner les informations du véhicule pour une plaque valide', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '''
            {
              "vehicles": [{
                "vehicleInformation": {
                  "make": "Peugeot",
                  "model": "308",
                  "fullModel": "308 Berline",
                  "bodyName": "Berline",
                  "color": "Gris",
                  "vin": "VF3LCYHZXGS123456",
                  "numberOfDoors": 5,
                  "salesStartDate": "2018-01-01",
                  "powerKW": 110
                },
                "engine": [{
                  "fuel": "Essence",
                  "code": "EP6CDT",
                  "capacityLiters": "1.6",
                  "ccm": 1598,
                  "powerKW": 110,
                  "powerHP": 150,
                  "environmental": {
                    "combinedCO2": 135,
                    "euroStandard": "Euro 6"
                  }
                }],
                "gearbox": {
                  "type": "Manuel"
                }
              }],
              "lastClickCount": 42
            }
            ''',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.getVehicleInfoFromPlate('AB123CD');

        // Assert
        expect(result, isA<Right<Failure, VehicleInfo>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (vehicleInfo) {
            expect(vehicleInfo.make, equals('Peugeot'));
            expect(vehicleInfo.model, equals('308'));
            expect(vehicleInfo.fuelType, equals('Essence'));
            expect(vehicleInfo.bodyStyle, equals('Berline'));
            expect(vehicleInfo.year, equals(2018));
            expect(vehicleInfo.power, equals(110));
            expect(vehicleInfo.engineCode, equals('EP6CDT'));
            expect(vehicleInfo.registrationNumber, equals('AB123CD'));
          },
        );
      });

      test('devrait nettoyer et formater correctement la plaque', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) {
            // Vérifier que l'URL contient la plaque nettoyée
            expect(request.url.toString(), contains('AB123CD'));
            return http.Response(
              '{"vehicles": [{"vehicleInformation": {"make": "Test"}, "engine": [], "gearbox": {}}]}',
              200,
            );
          },
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act - utiliser une plaque avec espaces et tirets
        final result = await service.getVehicleInfoFromPlate(' ab-123·cd ');

        // Assert
        expect(result, isA<Right<Failure, VehicleInfo>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (vehicleInfo) {
            expect(vehicleInfo.registrationNumber, equals('AB123CD'));
          },
        );
      });

      test('devrait retourner une erreur pour un format de plaque invalide', () async {
        // Act
        final result = await service.getVehicleInfoFromPlate('123');

        // Assert
        expect(result, isA<Left<Failure, VehicleInfo>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (vehicleInfo) => fail('Ne devrait pas retourner de données véhicule'),
        );
      });

      test('devrait retourner une erreur serveur pour un code de statut non-200', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '{"error": "Vehicle not found"}',
            404,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.getVehicleInfoFromPlate('AB123CD');

        // Assert
        expect(result, isA<Left<Failure, VehicleInfo>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (vehicleInfo) => fail('Ne devrait pas retourner de données véhicule'),
        );
      });

      test('devrait retourner une erreur si aucun véhicule trouvé', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '{"vehicles": []}',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.getVehicleInfoFromPlate('AB123CD');

        // Assert
        expect(result, isA<Left<Failure, VehicleInfo>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (vehicleInfo) => fail('Ne devrait pas retourner de données véhicule'),
        );
      });

      test('devrait retourner une erreur de parsing pour JSON invalide', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            'invalid json response',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.getVehicleInfoFromPlate('AB123CD');

        // Assert
        expect(result, isA<Left<Failure, VehicleInfo>>());
        result.fold(
          (failure) => expect(failure, isA<ParsingFailure>()),
          (vehicleInfo) => fail('Ne devrait pas retourner de données véhicule'),
        );
      });

      test('devrait gérer les données partielles de véhicule', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '''
            {
              "vehicles": [{
                "vehicleInformation": {
                  "make": "Renault"
                },
                "engine": [],
                "gearbox": {}
              }]
            }
            ''',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.getVehicleInfoFromPlate('AB123CD');

        // Assert
        expect(result, isA<Right<Failure, VehicleInfo>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (vehicleInfo) {
            expect(vehicleInfo.make, equals('Renault'));
            expect(vehicleInfo.model, isNull);
            expect(vehicleInfo.fuelType, isNull);
            expect(vehicleInfo.power, isNull);
          },
        );
      });

      test('devrait extraire l\'année depuis la date de début de vente', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '''
            {
              "vehicles": [{
                "vehicleInformation": {
                  "make": "Peugeot",
                  "salesStartDate": "2020-03-15T10:30:00Z"
                },
                "engine": [],
                "gearbox": {}
              }]
            }
            ''',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.getVehicleInfoFromPlate('AB123CD');

        // Assert
        expect(result, isA<Right<Failure, VehicleInfo>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (vehicleInfo) {
            expect(vehicleInfo.year, equals(2020));
          },
        );
      });
    });

    group('checkRemainingCredits', () {
      test('devrait retourner 0 par défaut en cas d\'échec', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '{"vehicles": []}',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.checkRemainingCredits();

        // Assert
        expect(result, isA<Right<Failure, int>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (credits) => expect(credits, equals(0)),
        );
      });
    });

    group('Validation des formats de plaque', () {
      test('devrait accepter les formats de plaque français valides', () async {
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '{"vehicles": [{"vehicleInformation": {"make": "Test"}, "engine": [], "gearbox": {}}]}',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        final validPlates = [
          'AB123CD',
          'AB-123-CD',
          'AB 123 CD',
          'ab123cd',
        ];

        for (final plate in validPlates) {
          final result = await service.getVehicleInfoFromPlate(plate);
          expect(result, isA<Right<Failure, VehicleInfo>>(),
                 reason: 'Plaque $plate devrait être valide');
        }
      });

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
          expect(result, isA<Left<Failure, VehicleInfo>>(),
                 reason: 'Plaque $plate devrait être invalide');
        }
      });
    });

    group('Gestion d\'erreur et robustesse', () {
      test('devrait construire une description complète du véhicule', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '''
            {
              "vehicles": [{
                "vehicleInformation": {
                  "make": "Peugeot",
                  "fullModel": "308 SW Allure"
                },
                "engine": [{
                  "fuel": "Diesel",
                  "capacityLiters": "2.0",
                  "powerHP": 150
                }],
                "gearbox": {}
              }]
            }
            ''',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.getVehicleInfoFromPlate('AB123CD');

        // Assert
        expect(result, isA<Right<Failure, VehicleInfo>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (vehicleInfo) {
            expect(vehicleInfo.description, contains('Peugeot'));
            expect(vehicleInfo.description, contains('308 SW Allure'));
            expect(vehicleInfo.description, contains('2.0L'));
            expect(vehicleInfo.description, contains('Diesel'));
            expect(vehicleInfo.description, contains('150HP'));
          },
        );
      });

      test('devrait gérer les moteurs multiples', () async {
        // Arrange
        mockHttpClient = MockHttpClient(
          onRequest: (request) => http.Response(
            '''
            {
              "vehicles": [{
                "vehicleInformation": {
                  "make": "BMW"
                },
                "engine": [
                  {
                    "fuel": "Essence",
                    "code": "N20B20",
                    "powerKW": 135
                  },
                  {
                    "fuel": "Diesel",
                    "code": "B47D20",
                    "powerKW": 140
                  }
                ],
                "gearbox": {}
              }]
            }
            ''',
            200,
          ),
        );

        service = ImmatriculationService(
          apiUsername: 'test-username',
          httpClient: mockHttpClient,
        );

        // Act
        final result = await service.getVehicleInfoFromPlate('AB123CD');

        // Assert - devrait prendre le premier moteur
        expect(result, isA<Right<Failure, VehicleInfo>>());
        result.fold(
          (failure) => fail('Ne devrait pas retourner d\'erreur'),
          (vehicleInfo) {
            expect(vehicleInfo.fuelType, equals('Essence'));
            expect(vehicleInfo.engineCode, equals('N20B20'));
            expect(vehicleInfo.power, equals(135));
          },
        );
      });
    });
  });
}