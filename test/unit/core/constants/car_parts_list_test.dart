import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/core/constants/car_parts_list.dart';

void main() {
  group('CarPartsList Tests', () {
    group('getAllParts', () {
      test('should return non-empty list of car parts', () {
        final parts = CarPartsList.getAllParts();

        expect(parts, isNotEmpty);
        expect(parts, isA<List<String>>());
      });

      test('should contain expected car parts categories', () {
        final parts = CarPartsList.getAllParts();

        // Vérifier quelques pièces moteur attendues
        expect(parts, contains('Pistons'));
        expect(parts, contains('Culasse'));
        expect(parts, contains('Radiateur'));

        // Vérifier quelques pièces transmission
        expect(parts, contains('Embrayage'));
        expect(parts, contains('Boîte de vitesses'));

        // Vérifier quelques pièces freinage
        expect(parts, contains('Plaquettes de frein'));
        expect(parts, contains('Disques de frein'));

        // Vérifier quelques pièces carrosserie
        expect(parts, contains('Pare-chocs avant'));
        expect(parts, contains('Capot'));
      });

      test('should not contain empty or null strings', () {
        final parts = CarPartsList.getAllParts();

        for (final part in parts) {
          expect(part, isNotNull);
          expect(part.trim(), isNotEmpty);
        }
      });

      test('should have reasonable number of parts', () {
        final parts = CarPartsList.getAllParts();

        expect(parts.length, greaterThan(50));
        expect(parts.length, lessThan(500));
      });
    });

    group('getPartsByCategory', () {
      test('should return engine parts for moteur category', () {
        final engineParts = CarPartsList.getPartsByCategory('moteur');

        expect(engineParts, isNotEmpty);
        expect(engineParts, contains('Pistons'));
        expect(engineParts, contains('Culasse'));
        expect(engineParts, contains('Alternateur'));
      });

      test('should return body parts for carrosserie category', () {
        final bodyParts = CarPartsList.getPartsByCategory('carrosserie');

        expect(bodyParts, isNotEmpty);
        expect(bodyParts, contains('Pare-chocs avant'));
        expect(bodyParts, contains('Capot'));
        expect(bodyParts, contains('Aile avant droite'));
      });

      test('should return empty list for unknown category', () {
        final unknownParts = CarPartsList.getPartsByCategory('unknown');

        expect(unknownParts, isEmpty);
      });

      test('should be case insensitive', () {
        final parts1 = CarPartsList.getPartsByCategory('MOTEUR');
        final parts2 = CarPartsList.getPartsByCategory('moteur');
        final parts3 = CarPartsList.getPartsByCategory('Moteur');

        expect(parts1, equals(parts2));
        expect(parts2, equals(parts3));
      });

      test('should handle empty string category', () {
        final parts = CarPartsList.getPartsByCategory('');

        expect(parts, isEmpty);
      });
    });

    group('searchParts', () {
      test('should find parts by partial name match', () {
        final results = CarPartsList.searchParts('frein');

        expect(results, isNotEmpty);
        expect(results, contains('Plaquettes de frein'));
        expect(results, contains('Disques de frein'));
      });

      test('should be case insensitive search', () {
        final results1 = CarPartsList.searchParts('FREIN');
        final results2 = CarPartsList.searchParts('frein');

        expect(results1, equals(results2));
      });

      test('should return empty list for non-existent part', () {
        final results = CarPartsList.searchParts('nonexistentpart123');

        expect(results, isEmpty);
      });

      test('should handle empty search query', () {
        final results = CarPartsList.searchParts('');

        expect(results, isEmpty);
      });

      test('should find single character matches', () {
        final results = CarPartsList.searchParts('a');

        expect(results, isNotEmpty);
        // Should contain parts with 'a' in their name
      });
    });

    group('Known categories', () {
      test('should return moteur parts correctly', () {
        final moteurParts = CarPartsList.getPartsByCategory('moteur');

        expect(moteurParts, isNotEmpty);
        expect(moteurParts, contains('Pistons'));
        expect(moteurParts, contains('Culasse'));
      });

      test('should return carrosserie parts correctly', () {
        final carrosserieParts = CarPartsList.getPartsByCategory('carrosserie');

        expect(carrosserieParts, isNotEmpty);
        expect(carrosserieParts, contains('Pare-chocs avant'));
        expect(carrosserieParts, contains('Capot'));
      });
    });

    group('Data consistency', () {
      test('should not have duplicate parts in same category', () {
        final categories = ['moteur', 'transmission', 'carrosserie', 'freinage'];

        for (final category in categories) {
          final parts = CarPartsList.getPartsByCategory(category);
          final uniqueParts = parts.toSet();

          expect(parts.length, equals(uniqueParts.length));
        }
      });

      test('should have consistent data across calls', () {
        final parts1 = CarPartsList.getAllParts();
        final parts2 = CarPartsList.getAllParts();

        expect(parts1, equals(parts2));
      });
    });
  });
}