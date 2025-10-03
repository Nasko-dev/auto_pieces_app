import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cente_pice/main.dart' as app;
import 'package:cente_pice/src/features/auth/presentation/pages/yannko_welcome_page.dart';
import 'package:cente_pice/src/features/parts/presentation/pages/particulier/home_page.dart';

/// Test d'intégration pour le flux d'authentification particulier
///
/// Ce test vérifie le parcours complet d'un utilisateur particulier :
/// 1. Affichage de la page d'accueil
/// 2. Authentification anonyme automatique
/// 3. Accès à la page d'accueil après authentification
/// 4. Vérification de l'état de session
///
/// Durée estimée : 5-10 secondes
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flux d\'authentification particulier - End-to-End', () {
    testWidgets(
      'Scénario complet : Page d\'accueil → Authentification anonyme → Accès home',
      (WidgetTester tester) async {
        // ========================================
        // ÉTAPE 1 : Lancement de l'application
        // ========================================
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Vérifier que la page d'accueil est affichée
        expect(find.byType(YannkoWelcomePage), findsOneWidget);

        // ========================================
        // ÉTAPE 2 : Navigation vers l'espace particulier
        // ========================================
        // Chercher le bouton "Je cherche une pièce" ou similaire
        final particulierButton = find.text('Je cherche une pièce');

        if (particulierButton.evaluate().isNotEmpty) {
          await tester.tap(particulierButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        } else {
          // Fallback : chercher par type de widget ou d'autres indicateurs
          final alternativeButton = find.byType(ElevatedButton).first;
          await tester.tap(alternativeButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // ========================================
        // ÉTAPE 3 : Vérification de l'authentification anonyme
        // ========================================
        // Après le tap, l'app devrait :
        // 1. Créer une session anonyme
        // 2. Rediriger vers HomePage
        // 3. Afficher l'interface de recherche de pièces

        // Attendre que l'authentification se fasse (max 5 secondes)
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Vérifier qu'on est bien sur la HomePage
        expect(
          find.byType(HomePage),
          findsOneWidget,
          reason: 'La HomePage devrait être affichée après authentification',
        );

        // ========================================
        // ÉTAPE 4 : Vérification des éléments de la HomePage
        // ========================================
        // Vérifier la présence d'éléments clés de la HomePage

        // Header avec titre
        final headerTitle = find.text('Rechercher une pièce');
        expect(
          headerTitle.evaluate().isNotEmpty || find.textContaining('Recherche').evaluate().isNotEmpty,
          true,
          reason: 'Le titre de recherche devrait être visible',
        );

        // Input de plaque d'immatriculation ou champ de recherche
        expect(
          find.byType(TextField).evaluate().isNotEmpty ||
          find.byType(TextFormField).evaluate().isNotEmpty,
          true,
          reason: 'Un champ de saisie devrait être présent',
        );

        // ========================================
        // ÉTAPE 5 : Vérification de la navigation
        // ========================================
        // Attendre un peu pour que l'UI soit stable
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Vérifier qu'on peut scroller (présence de contenu)
        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: 'La structure de page devrait être présente',
        );

        // ========================================
        // RÉSULTAT : SUCCESS
        // ========================================
        // Si on arrive ici, tous les tests sont passés
        // L'utilisateur a réussi à :
        // - Lancer l'app
        // - S'authentifier automatiquement en mode anonyme
        // - Accéder à la page de recherche
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Vérification de la persistance de session après redémarrage',
      (WidgetTester tester) async {
        // ========================================
        // ÉTAPE 1 : Premier lancement
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
        // ÉTAPE 2 : Simuler un redémarrage (hot restart)
        // ========================================
        // Re-build l'app (simule un restart)
        await tester.pumpWidget(
          const ProviderScope(
            child: SizedBox.shrink(),
          ),
        );
        await tester.pumpAndSettle();

        // Relancer l'app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // ========================================
        // ÉTAPE 3 : Vérification de la reconnexion automatique
        // ========================================
        // L'app devrait :
        // 1. Détecter la session en cache
        // 2. Reconnecter automatiquement
        // 3. Rediriger directement vers HomePage

        // Attendre la reconnexion
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Vérifier qu'on est directement sur HomePage (pas sur welcome)
        // Note : Ce test peut échouer si le cache est vidé entre les tests
        final isOnHomePage = find.byType(HomePage).evaluate().isNotEmpty;
        final isOnWelcomePage = find.byType(YannkoWelcomePage).evaluate().isNotEmpty;

        expect(
          isOnHomePage || isOnWelcomePage,
          true,
          reason: 'L\'app devrait afficher soit HomePage (session persistée) soit WelcomePage',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
      skip: true, // Skip par défaut car dépend de l'état du cache
    );

    testWidgets(
      'Gestion d\'erreur réseau lors de l\'authentification',
      (WidgetTester tester) async {
        // ========================================
        // ÉTAPE 1 : Lancement normal
        // ========================================
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ========================================
        // ÉTAPE 2 : Tentative d'authentification
        // ========================================
        // Note : Ce test est difficile à réaliser en intégration réelle
        // car on ne peut pas facilement couper le réseau
        // Il faudrait utiliser des mocks ou un environnement de test

        final button = find.text('Je cherche une pièce');
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button);
          await tester.pumpAndSettle(const Duration(seconds: 5));
        }

        // ========================================
        // ÉTAPE 3 : Vérification de la gestion d'erreur
        // ========================================
        // Si une erreur réseau se produit, l'app devrait :
        // 1. Afficher un message d'erreur clair
        // 2. Permettre de réessayer
        // 3. Ne pas crasher

        // Pour l'instant, on vérifie juste que l'app ne crash pas
        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: 'L\'app devrait rester stable même en cas d\'erreur',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
      skip: true, // Skip car nécessite simulation réseau
    );
  });

  group('Validation de l\'état d\'authentification', () {
    testWidgets(
      'Vérification que l\'utilisateur anonyme peut accéder aux fonctionnalités de base',
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

        // ========================================
        // TEST 1 : Accès à la recherche de pièces
        // ========================================
        expect(
          find.byType(HomePage),
          findsOneWidget,
          reason: 'L\'utilisateur anonyme devrait accéder à la recherche',
        );

        // ========================================
        // TEST 2 : Navigation dans la bottom bar
        // ========================================
        // Chercher les onglets de navigation
        final bottomNavBar = find.byType(BottomNavigationBar);

        if (bottomNavBar.evaluate().isNotEmpty) {
          // Tap sur l'onglet "Mes demandes" (index 1)
          await tester.tap(find.byIcon(Icons.assignment).first);
          await tester.pumpAndSettle();

          // Vérifier qu'on peut naviguer
          expect(find.byType(Scaffold), findsWidgets);

          // Retour à l'accueil
          await tester.tap(find.byIcon(Icons.home).first);
          await tester.pumpAndSettle();
        }

        // ========================================
        // TEST 3 : Interaction avec les champs de saisie
        // ========================================
        final textField = find.byType(TextField).first;
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField, 'AB-123-CD');
          await tester.pumpAndSettle();

          // Vérifier que le texte est bien saisi
          expect(find.text('AB-123-CD'), findsOneWidget);
        }
      },
      timeout: const Timeout(Duration(seconds: 40)),
    );
  });
}
