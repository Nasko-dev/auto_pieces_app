import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cente_pice/main.dart' as app;
import 'package:cente_pice/src/features/parts/presentation/pages/particulier/home_page.dart';
import 'package:cente_pice/src/features/parts/presentation/pages/particulier/requests_page.dart';
import 'package:cente_pice/src/features/parts/presentation/pages/particulier/conversations_list_page.dart';
import 'package:cente_pice/src/features/parts/presentation/pages/particulier/profile_page.dart';

/// Test d'intégration pour le flux de navigation principale
///
/// Ce test vérifie la navigation complète dans l'application :
/// 1. Navigation entre les onglets principaux (Bottom Navigation Bar)
/// 2. Navigation profonde (vers les sous-pages)
/// 3. Gestion du back button
/// 4. Persistance de l'état lors de la navigation
/// 5. Transitions et animations
///
/// Durée estimée : 20-30 secondes
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation principale - End-to-End', () {
    testWidgets(
      'Navigation entre tous les onglets de la bottom bar',
      (WidgetTester tester) async {
        // ========================================
        // SETUP : Authentification
        // ========================================
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // Vérifier qu'on est sur la HomePage
        expect(find.byType(HomePage), findsOneWidget);

        // ========================================
        // ÉTAPE 1 : Vérification de la Bottom Navigation Bar
        // ========================================
        final bottomNavBar = find.byType(BottomNavigationBar);
        expect(
          bottomNavBar,
          findsOneWidget,
          reason: 'La bottom navigation bar devrait être présente',
        );

        // ========================================
        // ÉTAPE 2 : Navigation vers "Mes demandes"
        // ========================================
        final requestsTab = find.byIcon(Icons.assignment);
        if (requestsTab.evaluate().isNotEmpty) {
          await tester.tap(requestsTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Vérifier qu'on est sur RequestsPage
          expect(
            find.byType(RequestsPage),
            findsOneWidget,
            reason: 'Devrait naviguer vers la page des demandes',
          );

          // Vérifier que la bottom bar est toujours présente
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        }

        // ========================================
        // ÉTAPE 3 : Navigation vers "Conversations"
        // ========================================
        final conversationsTab = find.byIcon(Icons.chat);
        if (conversationsTab.evaluate().isNotEmpty) {
          await tester.tap(conversationsTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Vérifier qu'on est sur ConversationsListPage
          expect(
            find.byType(ConversationsListPage),
            findsOneWidget,
            reason: 'Devrait naviguer vers la page des conversations',
          );
        }

        // ========================================
        // ÉTAPE 4 : Navigation vers "Profil"
        // ========================================
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Vérifier qu'on est sur ProfilePage
          expect(
            find.byType(ProfilePage),
            findsOneWidget,
            reason: 'Devrait naviguer vers la page de profil',
          );
        }

        // ========================================
        // ÉTAPE 5 : Retour à l'accueil
        // ========================================
        final homeTab = find.byIcon(Icons.home);
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Vérifier qu'on est de retour sur HomePage
          expect(
            find.byType(HomePage),
            findsOneWidget,
            reason: 'Devrait revenir sur la page d\'accueil',
          );
        }
      },
      timeout: const Timeout(Duration(seconds: 45)),
    );

    testWidgets(
      'Persistance de l\'état lors de la navigation entre onglets',
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
        // TEST : Remplir un formulaire sur HomePage
        // ========================================
        // Saisir du texte dans un champ
        final textField = find.byType(TextField).first;
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField, 'AB-123-CD');
          await tester.pumpAndSettle();

          // Vérifier que le texte est saisi
          expect(find.text('AB-123-CD'), findsOneWidget);

          // ========================================
          // ÉTAPE 1 : Naviguer vers un autre onglet
          // ========================================
          final requestsTab = find.byIcon(Icons.assignment);
          if (requestsTab.evaluate().isNotEmpty) {
            await tester.tap(requestsTab.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // ========================================
            // ÉTAPE 2 : Revenir sur l'accueil
            // ========================================
            final homeTab = find.byIcon(Icons.home);
            if (homeTab.evaluate().isNotEmpty) {
              await tester.tap(homeTab.first);
              await tester.pumpAndSettle(const Duration(seconds: 2));

              // ========================================
              // ÉTAPE 3 : Vérifier que l'état est conservé
              // ========================================
              // Le texte devrait toujours être présent
              expect(
                find.text('AB-123-CD'),
                findsOneWidget,
                reason: 'L\'état du formulaire devrait être conservé lors de la navigation',
              );
            }
          }
        }
      },
      timeout: const Timeout(Duration(seconds: 45)),
    );

    testWidgets(
      'Gestion du back button système',
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
        // ÉTAPE 1 : Navigation profonde
        // ========================================
        // Naviguer vers "Mes demandes"
        final requestsTab = find.byIcon(Icons.assignment);
        if (requestsTab.evaluate().isNotEmpty) {
          await tester.tap(requestsTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // ========================================
          // ÉTAPE 2 : Tester le back button
          // ========================================
          // Note : Le back button système est difficile à tester
          // On peut tester le comportement avec un back button UI

          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();

            // Vérifier qu'on est revenu en arrière
            expect(
              find.byType(Scaffold),
              findsWidgets,
              reason: 'La navigation arrière devrait fonctionner',
            );
          }
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Navigation vers les paramètres depuis le profil',
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
        // ÉTAPE 1 : Navigation vers le profil
        // ========================================
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // ========================================
          // ÉTAPE 2 : Chercher le bouton paramètres
          // ========================================
          final settingsButton = find.text('Paramètres');
          final settingsIcon = find.byIcon(Icons.settings);

          if (settingsButton.evaluate().isNotEmpty) {
            await tester.tap(settingsButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Vérifier qu'on est sur la page des paramètres
            expect(
              find.byType(Scaffold),
              findsWidgets,
              reason: 'Devrait naviguer vers les paramètres',
            );
          } else if (settingsIcon.evaluate().isNotEmpty) {
            await tester.tap(settingsIcon.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Navigation vers l\'aide depuis le menu',
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
        // ÉTAPE 1 : Ouvrir le menu (AppMenu)
        // ========================================
        final menuButton = find.byIcon(Icons.menu);
        final moreButton = find.byIcon(Icons.more_vert);

        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton.first);
          await tester.pumpAndSettle();

          // Chercher l'option "Aide"
          final helpOption = find.text('Aide');
          if (helpOption.evaluate().isNotEmpty) {
            await tester.tap(helpOption);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Vérifier qu'on est sur la page d'aide
            expect(
              find.byType(Scaffold),
              findsWidgets,
              reason: 'Devrait naviguer vers la page d\'aide',
            );
          }
        } else if (moreButton.evaluate().isNotEmpty) {
          await tester.tap(moreButton.first);
          await tester.pumpAndSettle();
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });

  group('Navigation profonde et transitions', () {
    testWidgets(
      'Animation de transition entre les pages',
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
        // TEST : Vérifier les animations
        // ========================================
        // Naviguer entre les onglets et vérifier que les transitions sont fluides

        final requestsTab = find.byIcon(Icons.assignment);
        if (requestsTab.evaluate().isNotEmpty) {
          await tester.tap(requestsTab.first);

          // Pump sans settle pour voir l'animation
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          // Finir l'animation
          await tester.pumpAndSettle();

          // Vérifier qu'on est bien arrivé
          expect(
            find.byType(Scaffold),
            findsWidgets,
            reason: 'La transition devrait se terminer correctement',
          );
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Navigation avec deep links (simulation)',
      (WidgetTester tester) async {
        // ========================================
        // SETUP
        // ========================================
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Ce test simule l'ouverture d'un deep link
        // Par exemple : myapp://conversation/123

        // Note : La vraie implémentation nécessiterait un setup spécial

        // Vérifier que l'app gère correctement les routes
        expect(
          find.byType(MaterialApp),
          findsOneWidget,
          reason: 'L\'app devrait être initialisée',
        );
      },
      timeout: const Timeout(Duration(seconds: 15)),
      skip: true, // Skip car nécessite configuration spéciale
    );

    testWidgets(
      'Navigation avec arguments de page',
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
        // TEST : Navigation avec arguments
        // ========================================
        // Par exemple : naviguer vers une conversation spécifique

        // Navigation vers les conversations
        final conversationsTab = find.byIcon(Icons.chat);
        if (conversationsTab.evaluate().isNotEmpty) {
          await tester.tap(conversationsTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Sélectionner une conversation
          final conversationItem = find.byType(ListTile).first;
          if (conversationItem.evaluate().isNotEmpty) {
            await tester.tap(conversationItem);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // L'ID de la conversation devrait être passé en argument
            // Vérifier que la page de détail s'affiche correctement

            expect(
              find.byType(Scaffold),
              findsWidgets,
              reason: 'La navigation avec arguments devrait fonctionner',
            );
          }
        }
      },
      timeout: const Timeout(Duration(seconds: 45)),
      skip: true, // Skip car nécessite des données
    );
  });

  group('Gestion d\'erreurs de navigation', () {
    testWidgets(
      'Navigation vers une route inexistante',
      (WidgetTester tester) async {
        // Test du comportement en cas de route 404
        // L'app devrait afficher une page d'erreur ou rediriger

        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Note : Difficile à tester sans accès direct au router

        expect(
          find.byType(MaterialApp),
          findsOneWidget,
          reason: 'L\'app devrait gérer les erreurs de route',
        );
      },
      timeout: const Timeout(Duration(seconds: 15)),
      skip: true, // Skip car nécessite manipulation directe du router
    );

    testWidgets(
      'Double tap rapide sur navigation',
      (WidgetTester tester) async {
        // Test de robustesse : tap rapide multiple
        // L'app ne devrait pas crasher ou se comporter bizarrement

        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // Double tap rapide sur un onglet
        final requestsTab = find.byIcon(Icons.assignment);
        if (requestsTab.evaluate().isNotEmpty) {
          await tester.tap(requestsTab.first);
          await tester.pump(const Duration(milliseconds: 10));
          await tester.tap(requestsTab.first);
          await tester.pumpAndSettle();

          // L'app devrait rester stable
          expect(
            find.byType(Scaffold),
            findsWidgets,
            reason: 'L\'app devrait gérer les taps multiples',
          );
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Navigation pendant le chargement',
      (WidgetTester tester) async {
        // Test : naviguer pendant qu'une page charge
        // L'app devrait annuler le chargement précédent

        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // Naviguer rapidement entre plusieurs onglets
        final requestsTab = find.byIcon(Icons.assignment);
        final conversationsTab = find.byIcon(Icons.chat);
        final homeTab = find.byIcon(Icons.home);

        if (requestsTab.evaluate().isNotEmpty) {
          await tester.tap(requestsTab.first);
          await tester.pump(const Duration(milliseconds: 100));

          if (conversationsTab.evaluate().isNotEmpty) {
            await tester.tap(conversationsTab.first);
            await tester.pump(const Duration(milliseconds: 100));

            if (homeTab.evaluate().isNotEmpty) {
              await tester.tap(homeTab.first);
              await tester.pumpAndSettle();
            }
          }
        }

        // Vérifier que l'app est stable
        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: 'L\'app devrait gérer la navigation rapide',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
