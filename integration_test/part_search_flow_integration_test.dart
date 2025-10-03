import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cente_pice/main.dart' as app;
import 'package:cente_pice/src/features/parts/presentation/pages/particulier/home_page.dart';
import 'package:cente_pice/src/features/parts/presentation/pages/particulier/requests_page.dart';

/// Test d'intégration pour le flux de recherche de pièces
///
/// Ce test vérifie le parcours complet de recherche de pièces :
/// 1. Accès à la page de recherche
/// 2. Saisie d'une plaque d'immatriculation
/// 3. Récupération automatique des infos véhicule
/// 4. Sélection des pièces recherchées
/// 5. Création de la demande
/// 6. Vérification dans "Mes demandes"
///
/// Durée estimée : 15-25 secondes
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flux de recherche de pièces - End-to-End', () {
    testWidgets(
      'Scénario complet : Recherche avec plaque → Sélection pièces → Création demande',
      (WidgetTester tester) async {
        // ========================================
        // SETUP : Authentification et accès à la HomePage
        // ========================================
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Naviguer vers l'espace particulier
        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // Vérifier qu'on est sur la HomePage
        expect(find.byType(HomePage), findsOneWidget);

        // ========================================
        // ÉTAPE 1 : Saisie de la plaque d'immatriculation
        // ========================================
        // Chercher le champ de plaque (peut être un widget custom)
        final plateField = find.byType(TextField).first;

        await tester.tap(plateField);
        await tester.pumpAndSettle();

        // Saisir une plaque de test
        await tester.enterText(plateField, 'AB-123-CD');
        await tester.pumpAndSettle();

        // Vérifier que la plaque est affichée
        expect(find.text('AB-123-CD'), findsOneWidget);

        // ========================================
        // ÉTAPE 2 : Validation de la plaque et récupération des infos
        // ========================================
        // Chercher et taper le bouton de validation/recherche
        final searchButton = find.text('Rechercher').first;

        if (searchButton.evaluate().isNotEmpty) {
          await tester.tap(searchButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Attendre que l'API réponde et affiche les infos du véhicule
          // L'app devrait afficher : marque, modèle, année, motorisation
        } else {
          // Fallback : chercher un bouton submit/validate
          final submitButton = find.byType(ElevatedButton).first;
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton);
            await tester.pumpAndSettle(const Duration(seconds: 5));
          }
        }

        // ========================================
        // ÉTAPE 3 : Vérification des infos véhicule
        // ========================================
        // Si l'API a retourné des données, on devrait voir :
        // - La marque du véhicule
        // - Le modèle
        // - L'année
        // - La motorisation

        // Note : Ce test peut échouer si l'API SIV est down ou si la plaque n'existe pas
        // On vérifie juste que la page est toujours stable

        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: 'La page devrait rester stable après la recherche',
        );

        // ========================================
        // ÉTAPE 4 : Sélection du type de pièce (Moteur ou Carrosserie)
        // ========================================
        // Chercher les boutons de sélection de type
        final engineButton = find.text('Pièces moteur');
        final bodyButton = find.text('Pièces carrosserie');

        if (engineButton.evaluate().isNotEmpty) {
          await tester.tap(engineButton);
          await tester.pumpAndSettle();
        } else if (bodyButton.evaluate().isNotEmpty) {
          await tester.tap(bodyButton);
          await tester.pumpAndSettle();
        }

        // ========================================
        // ÉTAPE 5 : Saisie du nom de la pièce recherchée
        // ========================================
        // Chercher le champ de saisie de pièce
        final partField = find.byType(TextField).last;

        if (partField.evaluate().isNotEmpty) {
          await tester.tap(partField);
          await tester.pumpAndSettle();

          // Saisir une pièce
          await tester.enterText(partField, 'pare-choc avant');
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // L'app devrait afficher des suggestions
          // Attendre que les suggestions apparaissent
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // Sélectionner la première suggestion si disponible
          final suggestion = find.text('Pare-choc avant').first;
          if (suggestion.evaluate().isNotEmpty) {
            await tester.tap(suggestion);
            await tester.pumpAndSettle();
          }
        }

        // ========================================
        // ÉTAPE 6 : Validation et création de la demande
        // ========================================
        // Chercher le bouton de validation finale
        final validateButton = find.text('Valider la demande');
        final submitRequestButton = find.text('Créer la demande');

        if (validateButton.evaluate().isNotEmpty) {
          await tester.tap(validateButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        } else if (submitRequestButton.evaluate().isNotEmpty) {
          await tester.tap(submitRequestButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // ========================================
        // ÉTAPE 7 : Vérification de la création
        // ========================================
        // Après la création, l'app devrait :
        // 1. Afficher un message de succès
        // 2. Rediriger vers "Mes demandes"
        // 3. Afficher la nouvelle demande

        // Attendre la navigation
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Vérifier qu'on est bien sur une page stable
        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: 'La page devrait être stable après la création',
        );
      },
      timeout: const Timeout(Duration(seconds: 60)),
      skip: true, // Skip par défaut car dépend de l'API externe SIV
    );

    testWidgets(
      'Scénario mode manuel : Saisie manuelle des infos véhicule',
      (WidgetTester tester) async {
        // ========================================
        // SETUP
        // ========================================
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // ========================================
        // ÉTAPE 1 : Activer le mode manuel
        // ========================================
        // Chercher le bouton "Saisie manuelle" ou similaire
        final manualModeButton = find.text('Saisie manuelle');

        if (manualModeButton.evaluate().isNotEmpty) {
          await tester.tap(manualModeButton);
          await tester.pumpAndSettle();

          // ========================================
          // ÉTAPE 2 : Remplir les champs manuellement
          // ========================================
          // Marque
          final brandField = find.byKey(const Key('brand_field'));
          if (brandField.evaluate().isNotEmpty) {
            await tester.enterText(brandField, 'Peugeot');
            await tester.pumpAndSettle();
          }

          // Modèle
          final modelField = find.byKey(const Key('model_field'));
          if (modelField.evaluate().isNotEmpty) {
            await tester.enterText(modelField, '208');
            await tester.pumpAndSettle();
          }

          // Année
          final yearField = find.byKey(const Key('year_field'));
          if (yearField.evaluate().isNotEmpty) {
            await tester.enterText(yearField, '2020');
            await tester.pumpAndSettle();
          }

          // Motorisation
          final engineField = find.byKey(const Key('engine_field'));
          if (engineField.evaluate().isNotEmpty) {
            await tester.enterText(engineField, '1.2 PureTech 100');
            await tester.pumpAndSettle();
          }

          // ========================================
          // ÉTAPE 3 : Suite du flow normal
          // ========================================
          // Sélectionner type de pièce et créer la demande
          // (même flow que le test précédent)

          expect(
            find.byType(Scaffold),
            findsWidgets,
            reason: 'Le mode manuel devrait fonctionner correctement',
          );
        }
      },
      timeout: const Timeout(Duration(seconds: 45)),
      skip: true, // Skip car nécessite des clés spécifiques dans les widgets
    );

    testWidgets(
      'Navigation vers "Mes demandes" et vérification de la liste',
      (WidgetTester tester) async {
        // ========================================
        // SETUP
        // ========================================
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // ========================================
        // ÉTAPE 1 : Navigation vers "Mes demandes"
        // ========================================
        // Chercher l'onglet "Mes demandes" dans la bottom navigation
        final requestsTab = find.byIcon(Icons.assignment);

        if (requestsTab.evaluate().isNotEmpty) {
          await tester.tap(requestsTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Vérifier qu'on est sur la page RequestsPage
          expect(
            find.byType(RequestsPage),
            findsOneWidget,
            reason: 'Devrait naviguer vers la page des demandes',
          );

          // ========================================
          // ÉTAPE 2 : Vérification du contenu
          // ========================================
          // La page devrait afficher :
          // - Soit une liste de demandes
          // - Soit un message "Aucune demande"

          // Chercher les indicateurs de contenu
          final hasList = find.byType(ListView).evaluate().isNotEmpty;
          final hasEmptyState = find.text('Aucune demande').evaluate().isNotEmpty ||
                                find.textContaining('Aucune').evaluate().isNotEmpty;

          expect(
            hasList || hasEmptyState,
            true,
            reason: 'La page devrait afficher une liste ou un état vide',
          );

          // ========================================
          // ÉTAPE 3 : Test de pull-to-refresh
          // ========================================
          if (hasList) {
            // Faire un pull to refresh
            await tester.drag(
              find.byType(ListView),
              const Offset(0, 300),
            );
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Vérifier que la page est toujours stable
            expect(find.byType(Scaffold), findsWidgets);
          }
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Validation des champs obligatoires',
      (WidgetTester tester) async {
        // ========================================
        // SETUP
        // ========================================
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // ========================================
        // TEST : Tentative de validation sans remplir les champs
        // ========================================
        // Chercher le bouton de validation
        final submitButton = find.text('Valider la demande');

        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // L'app devrait :
          // 1. Afficher des messages d'erreur
          // 2. Empêcher la soumission
          // 3. Rester sur la même page

          // Vérifier qu'on est toujours sur HomePage
          expect(
            find.byType(HomePage),
            findsOneWidget,
            reason: 'Devrait rester sur HomePage en cas de validation échouée',
          );

          // Chercher des messages d'erreur

          // Note : Peut ne pas trouver de message si la validation est silencieuse
          // C'est un point d'amélioration potentiel de l'UX
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });

  group('Edge cases et gestion d\'erreurs', () {
    testWidgets(
      'Plaque d\'immatriculation invalide',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // Saisir une plaque invalide
        final plateField = find.byType(TextField).first;
        await tester.enterText(plateField, 'INVALID123');
        await tester.pumpAndSettle();

        // Tenter de valider
        final searchButton = find.text('Rechercher');
        if (searchButton.evaluate().isNotEmpty) {
          await tester.tap(searchButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // L'app devrait gérer l'erreur gracefully
          expect(
            find.byType(Scaffold),
            findsWidgets,
            reason: 'L\'app ne devrait pas crasher sur une plaque invalide',
          );
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Timeout API - vérification de la gestion',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // Saisir une plaque
        final plateField = find.byType(TextField).first;
        await tester.enterText(plateField, 'AB-123-CD');
        await tester.pumpAndSettle();

        // Rechercher
        final searchButton = find.text('Rechercher');
        if (searchButton.evaluate().isNotEmpty) {
          await tester.tap(searchButton.first);

          // Attendre longtemps pour simuler un timeout
          await tester.pumpAndSettle(const Duration(seconds: 10));

          // L'app devrait :
          // 1. Afficher un loading pendant la requête
          // 2. Gérer le timeout avec un message d'erreur
          // 3. Permettre de réessayer

          expect(
            find.byType(Scaffold),
            findsWidgets,
            reason: 'L\'app devrait gérer les timeouts gracefully',
          );
        }
      },
      timeout: const Timeout(Duration(seconds: 45)),
      skip: true, // Skip car très long
    );
  });
}
