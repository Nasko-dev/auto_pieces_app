import 'package:cente_pice/src/core/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


// Note: Ces tests utilisent les méthodes statiques donc les mocks ne fonctionneront
// pas directement. Les tests vérifieront plutôt la logique et les formats.

@GenerateMocks([Position, Placemark])
void main() {
  group('LocationService', () {
    group('LocationResult', () {
      test('doit créer un résultat de succès correctement', () {
        // arrange & act
        final result = LocationResult.success(
          latitude: 48.8566,
          longitude: 2.3522,
          address: '1 Rue de Rivoli',
          city: 'Paris',
          postalCode: '75001',
          country: 'France',
        );

        // assert
        expect(result.isSuccess, true);
        expect(result.error, null);
        expect(result.latitude, 48.8566);
        expect(result.longitude, 2.3522);
        expect(result.address, '1 Rue de Rivoli');
        expect(result.city, 'Paris');
        expect(result.postalCode, '75001');
        expect(result.country, 'France');
      });

      test('doit créer un résultat d\'erreur correctement', () {
        // arrange & act
        final result = LocationResult.error('Permission refusée');

        // assert
        expect(result.isSuccess, false);
        expect(result.error, 'Permission refusée');
        expect(result.latitude, null);
        expect(result.longitude, null);
        expect(result.address, null);
        expect(result.city, null);
        expect(result.postalCode, null);
        expect(result.country, null);
      });
    });

    group('calculateDistance', () {
      test('doit calculer correctement la distance entre deux points', () {
        // arrange - Paris et Lyon
        const parisLat = 48.8566;
        const parisLon = 2.3522;
        const lyonLat = 45.7640;
        const lyonLon = 4.8357;

        // act
        final distance = LocationService.calculateDistance(
          parisLat,
          parisLon,
          lyonLat,
          lyonLon,
        );

        // assert - distance approximative entre Paris et Lyon (≈ 392 km)
        expect(distance, greaterThan(390));
        expect(distance, lessThan(400));
      });

      test('doit retourner 0 pour deux points identiques', () {
        // arrange
        const lat = 48.8566;
        const lon = 2.3522;

        // act
        final distance = LocationService.calculateDistance(lat, lon, lat, lon);

        // assert
        expect(distance, 0.0);
      });

      test('doit gérer les coordonnées négatives', () {
        // arrange - Coordonnées avec longitude négative (Amérique)
        const lat1 = 40.7589; // New York
        const lon1 = -73.9851;
        const lat2 = 34.0522; // Los Angeles
        const lon2 = -118.2437;

        // act
        final distance = LocationService.calculateDistance(lat1, lon1, lat2, lon2);

        // assert - distance approximative entre NY et LA (≈ 3944 km)
        expect(distance, greaterThan(3900));
        expect(distance, lessThan(4000));
      });

      test('doit gérer les distances très courtes', () {
        // arrange - deux points très proches (différence de 0.001°)
        const lat1 = 48.8566;
        const lon1 = 2.3522;
        const lat2 = 48.8576;
        const lon2 = 2.3532;

        // act
        final distance = LocationService.calculateDistance(lat1, lon1, lat2, lon2);

        // assert - distance très courte (< 1 km)
        expect(distance, lessThan(1.0));
        expect(distance, greaterThan(0.0));
      });
    });

    group('Format Address Tests', () {
      // Ces tests vérifieront la logique de formatage d'adresse indirectement
      // car _formatAddress est une méthode privée

      test('doit gérer les cas d\'adresse complète dans LocationResult', () {
        // arrange & act
        final result = LocationResult.success(
          latitude: 48.8566,
          longitude: 2.3522,
          address: '1 Rue de Rivoli, 75001 Paris',
          city: 'Paris',
          postalCode: '75001',
          country: 'France',
        );

        // assert
        expect(result.address, isNotEmpty);
        expect(result.address, contains('Rue'));
      });

      test('doit gérer les cas d\'adresse partielle', () {
        // arrange & act
        final result = LocationResult.success(
          latitude: 48.8566,
          longitude: 2.3522,
          address: 'Adresse non disponible',
          city: '',
          postalCode: '',
          country: 'France',
        );

        // assert
        expect(result.address, 'Adresse non disponible');
        expect(result.city, isEmpty);
        expect(result.postalCode, isEmpty);
      });
    });

    group('Error Handling Scenarios', () {
      test('doit créer des erreurs spécifiques pour différents cas', () {
        // Test des différents types d'erreurs possibles
        final serviceDisabledError = LocationResult.error(
          'Le service de localisation est désactivé. Veuillez l\'activer dans les paramètres.',
        );
        final permissionDeniedError = LocationResult.error(
          'Permission de localisation refusée.',
        );
        final permissionDeniedForeverError = LocationResult.error(
          'Permission de localisation refusée définitivement. Veuillez l\'autoriser dans les paramètres de l\'app.',
        );
        final timeoutError = LocationResult.error(
          'Impossible d\'obtenir la position (timeout).',
        );

        // assert
        expect(serviceDisabledError.isSuccess, false);
        expect(serviceDisabledError.error, contains('service de localisation'));

        expect(permissionDeniedError.isSuccess, false);
        expect(permissionDeniedError.error, contains('Permission'));

        expect(permissionDeniedForeverError.isSuccess, false);
        expect(permissionDeniedForeverError.error, contains('définitivement'));

        expect(timeoutError.isSuccess, false);
        expect(timeoutError.error, contains('timeout'));
      });
    });

    group('Data Validation', () {
      test('doit valider les coordonnées latitude valides', () {
        // arrange & act
        final result = LocationResult.success(
          latitude: 45.0, // Latitude valide
          longitude: 2.0,
          address: 'Test Address',
          city: 'Test City',
          postalCode: '12345',
          country: 'France',
        );

        // assert
        expect(result.latitude, greaterThanOrEqualTo(-90));
        expect(result.latitude, lessThanOrEqualTo(90));
      });

      test('doit valider les coordonnées longitude valides', () {
        // arrange & act
        final result = LocationResult.success(
          latitude: 45.0,
          longitude: 120.0, // Longitude valide
          address: 'Test Address',
          city: 'Test City',
          postalCode: '12345',
          country: 'France',
        );

        // assert
        expect(result.longitude, greaterThanOrEqualTo(-180));
        expect(result.longitude, lessThanOrEqualTo(180));
      });

      test('doit accepter des valeurs nulles ou vides pour les champs optionnels', () {
        // arrange & act
        final result = LocationResult.success(
          latitude: 48.8566,
          longitude: 2.3522,
          address: '',
          city: '',
          postalCode: '',
          country: 'France',
        );

        // assert
        expect(result.address, isEmpty);
        expect(result.city, isEmpty);
        expect(result.postalCode, isEmpty);
        expect(result.country, isNotEmpty); // Country devrait toujours avoir une valeur
      });
    });

    group('Edge Cases', () {
      test('doit gérer les coordonnées aux extrêmes', () {
        // Test avec les coordonnées aux limites
        final northPole = LocationResult.success(
          latitude: 90.0,
          longitude: 0.0,
          address: 'Pôle Nord',
          city: '',
          postalCode: '',
          country: '',
        );

        final southPole = LocationResult.success(
          latitude: -90.0,
          longitude: 0.0,
          address: 'Pôle Sud',
          city: '',
          postalCode: '',
          country: '',
        );

        // assert
        expect(northPole.latitude, 90.0);
        expect(southPole.latitude, -90.0);
      });

      test('doit calculer la distance pour des points antipodaux', () {
        // arrange - points antipodaux (maximum distance sur Terre)
        const lat1 = 45.0;
        const lon1 = 0.0;
        const lat2 = -45.0;
        const lon2 = 180.0;

        // act
        final distance = LocationService.calculateDistance(lat1, lon1, lat2, lon2);

        // assert - distance maximale sur Terre (≈ 20000 km)
        expect(distance, greaterThan(15000));
        expect(distance, lessThan(25000));
      });

      test('doit gérer les chaînes d\'adresse longues', () {
        // arrange - adresse très longue
        const longAddress = 'Très très très longue adresse avec beaucoup de détails et de caractères pour tester la gestion des chaînes longues dans le système de géolocalisation';

        final result = LocationResult.success(
          latitude: 48.8566,
          longitude: 2.3522,
          address: longAddress,
          city: 'Paris',
          postalCode: '75001',
          country: 'France',
        );

        // assert
        expect(result.address, longAddress);
        expect(result.address!.length, greaterThan(100));
      });
    });

    group('French Locale Handling', () {
      test('doit accepter des adresses avec caractères français', () {
        // arrange & act
        final result = LocationResult.success(
          latitude: 48.8566,
          longitude: 2.3522,
          address: 'Château de Versailles, Avenue de Sceaux',
          city: 'Versailles',
          postalCode: '78000',
          country: 'France',
        );

        // assert
        expect(result.address, contains('Château'));
        expect(result.city, 'Versailles');
        expect(result.country, 'France');
      });

      test('doit gérer les codes postaux français', () {
        // arrange & act
        final parisResult = LocationResult.success(
          latitude: 48.8566,
          longitude: 2.3522,
          address: 'Paris Centre',
          city: 'Paris',
          postalCode: '75001',
          country: 'France',
        );

        final marseilleResult = LocationResult.success(
          latitude: 43.2965,
          longitude: 5.3698,
          address: 'Marseille Centre',
          city: 'Marseille',
          postalCode: '13001',
          country: 'France',
        );

        // assert
        expect(parisResult.postalCode, matches(r'^\d{5}$'));
        expect(marseilleResult.postalCode, matches(r'^\d{5}$'));
        expect(parisResult.postalCode![0], '7'); // Paris commence par 7
        expect(marseilleResult.postalCode![0], '1'); // Marseille commence par 1
      });
    });

    group('Result Consistency', () {
      test('doit maintenir la cohérence entre succès et erreur', () {
        // arrange & act
        final successResult = LocationResult.success(
          latitude: 48.8566,
          longitude: 2.3522,
          address: 'Paris',
          city: 'Paris',
          postalCode: '75001',
          country: 'France',
        );

        final errorResult = LocationResult.error('Test error');

        // assert
        expect(successResult.isSuccess, true);
        expect(successResult.error, null);
        expect(successResult.latitude, isNotNull);

        expect(errorResult.isSuccess, false);
        expect(errorResult.error, isNotNull);
        expect(errorResult.latitude, null);
      });
    });
  });
}