import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/core/constants/app_constants.dart';

void main() {
  group('AppConstants Basic Tests', () {
    group('Static Constants', () {
      test('should have correct app name', () {
        expect(AppConstants.appName, equals('Pièces d\'Occasion'));
        expect(AppConstants.appName, isNotEmpty);
      });

      test('should have valid app scheme', () {
        expect(AppConstants.appScheme, equals('pieces-occasion'));
        expect(AppConstants.appScheme, isNotEmpty);
      });

      test('should have correct user type constants', () {
        expect(AppConstants.userTypeParticulier, equals('particulier'));
        expect(AppConstants.userTypeVendeur, equals('vendeur'));
        expect(AppConstants.userTypeSeller, equals('seller'));
      });

      test('should have valid storage keys', () {
        expect(AppConstants.userTokenKey, equals('user_token'));
        expect(AppConstants.userTypeKey, equals('user_type'));
      });

      test('should have correct part type constants', () {
        expect(AppConstants.partTypeMoteur, equals('moteur'));
        expect(AppConstants.partTypeCarrosserie, equals('carrosserie'));
      });

      test('should have valid immatriculation constants', () {
        expect(AppConstants.immatriculationApiUsername, equals('Moïse134'));
        expect(AppConstants.immatriculationApiEnabled, isFalse);
        expect(AppConstants.tecAllianceApiEnabled, isTrue);
      });
    });

    group('Value Validation', () {
      test('should have non-empty string constants', () {
        expect(AppConstants.appName, isNotEmpty);
        expect(AppConstants.appScheme, isNotEmpty);
        expect(AppConstants.userTokenKey, isNotEmpty);
        expect(AppConstants.userTypeKey, isNotEmpty);
        expect(AppConstants.userTypeParticulier, isNotEmpty);
        expect(AppConstants.userTypeVendeur, isNotEmpty);
        expect(AppConstants.userTypeSeller, isNotEmpty);
      });

      test('should have different user types', () {
        expect(AppConstants.userTypeParticulier,
            isNot(equals(AppConstants.userTypeVendeur)));
        expect(AppConstants.userTypeVendeur,
            isNot(equals(AppConstants.userTypeSeller)));
      });

      test('should have different part types', () {
        expect(AppConstants.partTypeMoteur,
            isNot(equals(AppConstants.partTypeCarrosserie)));
      });
    });

    group('Naming Conventions', () {
      test('should have consistent naming for storage keys', () {
        expect(AppConstants.userTokenKey, matches(r'^[a-z_]+$'));
        expect(AppConstants.userTypeKey, matches(r'^[a-z_]+$'));
      });

      test('should have lowercase user types', () {
        expect(AppConstants.userTypeParticulier,
            equals(AppConstants.userTypeParticulier.toLowerCase()));
        expect(AppConstants.userTypeVendeur,
            equals(AppConstants.userTypeVendeur.toLowerCase()));
        expect(AppConstants.userTypeSeller,
            equals(AppConstants.userTypeSeller.toLowerCase()));
      });

      test('should have valid app scheme format', () {
        final scheme = AppConstants.appScheme;
        expect(scheme, matches(r'^[a-z-]+$'));
        expect(scheme, isNot(contains(' ')));
      });
    });

    group('Boolean Flags', () {
      test('should have correct API flags', () {
        expect(AppConstants.tecAllianceApiEnabled, isTrue);
        expect(AppConstants.immatriculationApiEnabled, isFalse);
      });

      test('should have consistent boolean values', () {
        expect(AppConstants.tecAllianceApiEnabled, isA<bool>());
        expect(AppConstants.immatriculationApiEnabled, isA<bool>());
      });
    });
  });
}
