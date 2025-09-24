import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/core/constants/app_constants.dart';

void main() {
  group('AppConstants Tests', () {
    group('Static Constants', () {
      test('devrait avoir le bon nom d\'application', () {
        expect(AppConstants.appName, equals('Pièces d\'Occasion'));
        expect(AppConstants.appName, isNotEmpty);
      });

      test('devrait avoir les bonnes clés de stockage', () {
        expect(AppConstants.userTokenKey, equals('user_token'));
        expect(AppConstants.userTypeKey, equals('user_type'));

        expect(AppConstants.userTokenKey, isNotEmpty);
        expect(AppConstants.userTypeKey, isNotEmpty);
      });

      test('devrait définir les types d\'utilisateurs corrects', () {
        expect(AppConstants.userTypeParticulier, equals('particulier'));
        expect(AppConstants.userTypeVendeur, equals('vendeur'));
        expect(AppConstants.userTypeSeller, equals('seller'));

        // Vérifier qu'ils sont tous différents
        final userTypes = {
          AppConstants.userTypeParticulier,
          AppConstants.userTypeVendeur,
          AppConstants.userTypeSeller,
        };
        expect(userTypes, hasLength(3));
      });

      test('devrait avoir le bon schème d\'application', () {
        expect(AppConstants.appScheme, equals('pieces-occasion'));
        expect(AppConstants.appScheme, isNotEmpty);
        expect(AppConstants.appScheme, contains('-'));
      });

      test('devrait définir les types de pièces', () {
        expect(AppConstants.partTypeMoteur, equals('moteur'));
        expect(AppConstants.partTypeCarrosserie, equals('carrosserie'));

        expect(AppConstants.partTypeMoteur, isNotEmpty);
        expect(AppConstants.partTypeCarrosserie, isNotEmpty);
      });
    });

    group('Configuration Immatriculation Legacy', () {
      test('devrait avoir la configuration RegCheck legacy', () {
        expect(AppConstants.immatriculationApiUsername, equals('Moïse134'));
        expect(AppConstants.immatriculationApiEnabled, isFalse);
      });

      test('devrait désactiver l\'API legacy', () {
        expect(AppConstants.immatriculationApiEnabled, isFalse);
      });
    });

    group('Configuration TecAlliance', () {
      test('devrait avoir TecAlliance activé', () {
        expect(AppConstants.tecAllianceApiEnabled, isTrue);
      });

      test('devrait avoir des getters pour la configuration TecAlliance', () {
        expect(() => AppConstants.tecAllianceProviderId, returnsNormally);
        expect(() => AppConstants.tecAllianceApiKey, returnsNormally);
        expect(() => AppConstants.tecAllianceBaseUrl, returnsNormally);
      });

      test('devrait retourner des chaînes pour les paramètres TecAlliance', () {
        expect(AppConstants.tecAllianceProviderId, isA<String>());
        expect(AppConstants.tecAllianceApiKey, isA<String>());
        expect(AppConstants.tecAllianceBaseUrl, isA<String>());
      });
    });

    group('Configuration Dynamique', () {
      test('devrait avoir des getters pour la configuration Supabase', () {
        expect(() => AppConstants.supabaseUrl, returnsNormally);
        expect(() => AppConstants.supabaseAnonKey, returnsNormally);
      });

      test('devrait retourner des chaînes pour Supabase', () {
        expect(AppConstants.supabaseUrl, isA<String>());
        expect(AppConstants.supabaseAnonKey, isA<String>());
      });

      test('devrait avoir des getters pour la configuration de base', () {
        expect(() => AppConstants.appVersion, returnsNormally);
        expect(() => AppConstants.baseUrl, returnsNormally);
      });

      test('devrait retourner des chaînes pour les paramètres de base', () {
        expect(AppConstants.appVersion, isA<String>());
        expect(AppConstants.baseUrl, isA<String>());
      });
    });

    group('Validation des Constantes', () {
      test('devrait avoir des noms d\'utilisateur et clés non vides', () {
        expect(AppConstants.immatriculationApiUsername, isNotEmpty);
        expect(AppConstants.userTokenKey, isNotEmpty);
        expect(AppConstants.userTypeKey, isNotEmpty);
        expect(AppConstants.appScheme, isNotEmpty);
      });

      test('devrait avoir des types d\'utilisateurs valides', () {
        final userTypes = [
          AppConstants.userTypeParticulier,
          AppConstants.userTypeVendeur,
          AppConstants.userTypeSeller,
        ];

        for (final type in userTypes) {
          expect(type, isNotEmpty);
          expect(type, isA<String>());
          expect(type, matches(RegExp(r'^[a-z]+$'))); // Lettres minuscules uniquement
        }
      });

      test('devrait avoir des types de pièces valides', () {
        final partTypes = [
          AppConstants.partTypeMoteur,
          AppConstants.partTypeCarrosserie,
        ];

        for (final type in partTypes) {
          expect(type, isNotEmpty);
          expect(type, isA<String>());
          expect(type, matches(RegExp(r'^[a-z]+$'))); // Lettres minuscules uniquement
        }
      });

      test('devrait avoir un schème d\'application valide', () {
        expect(AppConstants.appScheme, matches(RegExp(r'^[a-z-]+$')));
        expect(AppConstants.appScheme.split('-'), hasLength(2));
      });
    });

    group('Configuration des APIs', () {
      test('devrait désactiver l\'ancienne API et activer la nouvelle', () {
        expect(AppConstants.immatriculationApiEnabled, isFalse);
        expect(AppConstants.tecAllianceApiEnabled, isTrue);
      });

      test('devrait avoir des configurations cohérentes', () {
        // TecAlliance doit être activé quand RegCheck est désactivé
        expect(AppConstants.immatriculationApiEnabled, isFalse);
        expect(AppConstants.tecAllianceApiEnabled, isTrue);
      });
    });

    group('Accès aux Propriétés Dynamiques', () {
      test('devrait pouvoir accéder à toutes les propriétés dynamiques', () {
        final dynamicProperties = [
          () => AppConstants.appVersion,
          () => AppConstants.supabaseUrl,
          () => AppConstants.supabaseAnonKey,
          () => AppConstants.baseUrl,
          () => AppConstants.tecAllianceProviderId,
          () => AppConstants.tecAllianceApiKey,
          () => AppConstants.tecAllianceBaseUrl,
        ];

        for (final getter in dynamicProperties) {
          expect(getter, returnsNormally);
          expect(getter(), isA<String>());
        }
      });

      test('devrait maintenir la cohérence entre les appels', () {
        final url1 = AppConstants.supabaseUrl;
        final url2 = AppConstants.supabaseUrl;
        expect(url1, equals(url2));

        final version1 = AppConstants.appVersion;
        final version2 = AppConstants.appVersion;
        expect(version1, equals(version2));
      });
    });

    group('Edge Cases et Validation', () {
      test('devrait gérer l\'encodage UTF-8 dans le nom d\'application', () {
        expect(AppConstants.appName, contains('\''));
        expect(AppConstants.appName.contains('Pièces'), isTrue);
      });

      test('devrait avoir des identifiants uniques', () {
        final allConstants = {
          AppConstants.userTokenKey,
          AppConstants.userTypeKey,
          AppConstants.userTypeParticulier,
          AppConstants.userTypeVendeur,
          AppConstants.userTypeSeller,
          AppConstants.partTypeMoteur,
          AppConstants.partTypeCarrosserie,
        };

        expect(allConstants, hasLength(7)); // Toutes les valeurs doivent être uniques
      });
    });
  });
}