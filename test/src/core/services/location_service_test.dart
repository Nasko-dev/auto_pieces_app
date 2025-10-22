import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/core/services/location_service.dart';

void main() {
  group('LocationResult', () {
    test('LocationResult.success devrait créer un résultat réussi', () {
      final result = LocationResult.success(
        latitude: 48.8566,
        longitude: 2.3522,
        address: '10 Rue de Rivoli',
        city: 'Paris',
        postalCode: '75001',
        country: 'France',
      );

      expect(result.isSuccess, isTrue);
      expect(result.error, isNull);
      expect(result.latitude, 48.8566);
      expect(result.longitude, 2.3522);
      expect(result.address, '10 Rue de Rivoli');
      expect(result.city, 'Paris');
      expect(result.postalCode, '75001');
      expect(result.country, 'France');
    });

    test('LocationResult.error devrait créer un résultat en erreur', () {
      final result = LocationResult.error('Permission refusée');

      expect(result.isSuccess, isFalse);
      expect(result.error, 'Permission refusée');
      expect(result.latitude, isNull);
      expect(result.longitude, isNull);
      expect(result.address, isNull);
      expect(result.city, isNull);
      expect(result.postalCode, isNull);
      expect(result.country, isNull);
    });

    test('LocationResult.success devrait accepter des données complètes', () {
      final result = LocationResult.success(
        latitude: 45.7640,
        longitude: 4.8357,
        address: '25 Rue de la République',
        city: 'Lyon',
        postalCode: '69002',
        country: 'France',
      );

      expect(result.isSuccess, isTrue);
      expect(result.latitude, 45.7640);
      expect(result.city, 'Lyon');
    });

    test('LocationResult.error devrait stocker le message d\'erreur', () {
      final errorMessage = 'Le service de localisation est désactivé';
      final result = LocationResult.error(errorMessage);

      expect(result.error, errorMessage);
      expect(result.isSuccess, isFalse);
    });
  });

  group('LocationService.calculateDistance', () {
    test('devrait calculer la distance entre Paris et Lyon correctement', () {
      // Paris: 48.8566, 2.3522
      // Lyon: 45.7640, 4.8357
      final distance = LocationService.calculateDistance(
        48.8566,
        2.3522,
        45.7640,
        4.8357,
      );

      // Distance réelle environ 392 km
      expect(distance, greaterThan(390));
      expect(distance, lessThan(395));
    });

    test('devrait retourner 0 pour la même position', () {
      final distance = LocationService.calculateDistance(
        48.8566,
        2.3522,
        48.8566,
        2.3522,
      );

      expect(distance, 0);
    });

    test('devrait calculer des distances courtes correctement', () {
      // 2 points très proches (environ 1 km)
      final distance = LocationService.calculateDistance(
        48.8566,
        2.3522,
        48.8650,
        2.3600,
      );

      expect(distance, greaterThan(0));
      expect(distance, lessThan(2)); // Moins de 2 km
    });

    test('devrait calculer des distances longues correctement', () {
      // Paris à Marseille
      final distance = LocationService.calculateDistance(
        48.8566,
        2.3522,
        43.2965,
        5.3698,
      );

      // Distance réelle environ 660 km
      expect(distance, greaterThan(650));
      expect(distance, lessThan(680));
    });

    test('devrait gérer les coordonnées négatives', () {
      // Exemple avec longitude négative
      final distance = LocationService.calculateDistance(
        48.8566,
        -2.3522,
        45.7640,
        -4.8357,
      );

      expect(distance, greaterThan(0));
    });

    test('devrait gérer les coordonnées aux antipodes', () {
      // Paris vs point aux antipodes
      final distance = LocationService.calculateDistance(
        48.8566,
        2.3522,
        -48.8566,
        -177.6478,
      );

      // Distance maximale possible sur Terre (environ 20000 km)
      expect(distance, greaterThan(15000));
    });

    test('devrait être commutative (A->B = B->A)', () {
      final distance1 = LocationService.calculateDistance(
        48.8566,
        2.3522,
        45.7640,
        4.8357,
      );

      final distance2 = LocationService.calculateDistance(
        45.7640,
        4.8357,
        48.8566,
        2.3522,
      );

      expect(distance1, equals(distance2));
    });

    test('devrait calculer correctement sur l\'équateur', () {
      final distance = LocationService.calculateDistance(
        0.0,
        0.0,
        0.0,
        1.0,
      );

      // 1 degré de longitude à l'équateur ≈ 111 km
      expect(distance, greaterThan(110));
      expect(distance, lessThan(112));
    });

    test('devrait gérer les latitudes extrêmes (pôles)', () {
      final distance = LocationService.calculateDistance(
        90.0, // Pôle Nord
        0.0,
        -90.0, // Pôle Sud
        0.0,
      );

      // Distance entre les pôles ≈ 20000 km
      expect(distance, greaterThan(19000));
      expect(distance, lessThan(21000));
    });
  });

  group('LocationService error handling', () {
    test(
        'devrait retourner un message d\'erreur descriptif pour service désactivé',
        () {
      final result = LocationResult.error(
        'Le service de localisation est désactivé. Veuillez l\'activer dans les paramètres.',
      );

      expect(result.error, contains('service de localisation'));
      expect(result.error, contains('désactivé'));
    });

    test('devrait retourner un message d\'erreur pour permission refusée', () {
      final result =
          LocationResult.error('Permission de localisation refusée.');

      expect(result.error, contains('Permission'));
      expect(result.error, contains('refusée'));
    });

    test(
        'devrait retourner un message d\'erreur pour permission refusée définitivement',
        () {
      final result = LocationResult.error(
        'Permission de localisation refusée définitivement. Veuillez l\'autoriser dans les paramètres de l\'app.',
      );

      expect(result.error, contains('définitivement'));
      expect(result.error, contains('paramètres'));
    });
  });

  group('LocationResult edge cases', () {
    test('devrait accepter des coordonnées avec haute précision', () {
      final result = LocationResult.success(
        latitude: 48.856614,
        longitude: 2.3522219,
        address: 'Précis',
        city: 'Paris',
        postalCode: '75001',
        country: 'France',
      );

      expect(result.latitude, 48.856614);
      expect(result.longitude, 2.3522219);
    });

    test('devrait accepter une adresse vide', () {
      final result = LocationResult.success(
        latitude: 48.8566,
        longitude: 2.3522,
        address: '',
        city: '',
        postalCode: '',
        country: 'France',
      );

      expect(result.isSuccess, isTrue);
      expect(result.address, '');
    });

    test('devrait accepter "Adresse non trouvée" comme adresse', () {
      final result = LocationResult.success(
        latitude: 48.8566,
        longitude: 2.3522,
        address: 'Adresse non trouvée',
        city: '',
        postalCode: '',
        country: 'France',
      );

      expect(result.address, 'Adresse non trouvée');
    });

    test('devrait toujours avoir "France" comme pays par défaut', () {
      final result1 = LocationResult.success(
        latitude: 48.8566,
        longitude: 2.3522,
        address: 'Test',
        city: 'Paris',
        postalCode: '75001',
        country: 'France',
      );

      expect(result1.country, 'France');
    });
  });

  group('LocationService distance edge cases', () {
    test('devrait gérer des coordonnées avec décimales', () {
      final distance = LocationService.calculateDistance(
        48.123456789,
        2.987654321,
        48.123456788,
        2.987654320,
      );

      expect(distance, greaterThanOrEqualTo(0));
      expect(distance, lessThan(0.001)); // Très petite distance
    });

    test('devrait retourner une valeur positive pour toutes les distances', () {
      final distance1 =
          LocationService.calculateDistance(48.8566, 2.3522, 45.7640, 4.8357);
      final distance2 = LocationService.calculateDistance(
          -45.7640, -4.8357, -48.8566, -2.3522);
      final distance3 = LocationService.calculateDistance(0, 0, 10, 10);

      expect(distance1, greaterThan(0));
      expect(distance2, greaterThan(0));
      expect(distance3, greaterThan(0));
    });

    test('devrait gérer les coordonnées sur le méridien de Greenwich', () {
      final distance = LocationService.calculateDistance(
        51.4778, // Londres
        0.0,
        48.8566, // Paris
        2.3522,
      );

      // Distance Londres-Paris environ 340 km
      expect(distance, greaterThan(330));
      expect(distance, lessThan(350));
    });
  });

  group('LocationResult data integrity', () {
    test('un résultat success ne devrait jamais avoir d\'erreur', () {
      final result = LocationResult.success(
        latitude: 48.8566,
        longitude: 2.3522,
        address: 'Test',
        city: 'Paris',
        postalCode: '75001',
        country: 'France',
      );

      expect(result.error, isNull);
      expect(result.isSuccess, isTrue);
    });

    test('un résultat error ne devrait jamais avoir de données de localisation',
        () {
      final result = LocationResult.error('Erreur test');

      expect(result.latitude, isNull);
      expect(result.longitude, isNull);
      expect(result.address, isNull);
      expect(result.city, isNull);
      expect(result.postalCode, isNull);
      expect(result.isSuccess, isFalse);
    });

    test('devrait maintenir l\'intégrité des données après création', () {
      final result = LocationResult.success(
        latitude: 48.8566,
        longitude: 2.3522,
        address: '10 Rue Test',
        city: 'Paris',
        postalCode: '75001',
        country: 'France',
      );

      // Vérifier que toutes les données sont présentes et cohérentes
      expect(result.isSuccess, isTrue);
      expect(result.latitude, isNotNull);
      expect(result.longitude, isNotNull);
      expect(result.address, isNotNull);
      expect(result.city, isNotNull);
      expect(result.postalCode, isNotNull);
      expect(result.country, isNotNull);
    });
  });
}
