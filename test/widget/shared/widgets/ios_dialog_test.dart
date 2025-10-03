import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/shared/presentation/widgets/ios_dialog.dart';

void main() {
  group('IOSDialog', () {
    testWidgets('doit afficher le dialogue avec titre et message', (tester) async {
      // arrange
      const title = 'Test Title';
      const message = 'Test Message';

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: title,
              message: message,
              confirmText: 'OK',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('doit afficher les boutons confirmer et annuler', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              confirmText: 'Confirmer',
              cancelText: 'Annuler',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Confirmer'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('doit afficher uniquement le bouton confirmer si cancelText est null', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              confirmText: 'OK',
              cancelText: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Annuler'), findsNothing);
    });

    testWidgets('doit appeler onConfirm lors du tap sur le bouton confirmer', (tester) async {
      // arrange
      bool confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              confirmText: 'Confirmer',
              onConfirm: () {
                confirmCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // act
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      // assert
      expect(confirmCalled, true);
    });

    testWidgets('doit appeler onCancel lors du tap sur le bouton annuler', (tester) async {
      // arrange
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              confirmText: 'Confirmer',
              cancelText: 'Annuler',
              onCancel: () {
                cancelCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // act
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // assert
      expect(cancelCalled, true);
    });

    testWidgets('doit afficher l\'icône appropriée pour le type confirmation', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              type: DialogType.confirmation,
              confirmText: 'OK',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    });

    testWidgets('doit afficher l\'icône appropriée pour le type warning', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              type: DialogType.warning,
              confirmText: 'OK',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('doit afficher l\'icône appropriée pour le type error', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              type: DialogType.error,
              confirmText: 'OK',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('doit afficher l\'icône appropriée pour le type info', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              type: DialogType.info,
              confirmText: 'OK',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('doit animer l\'apparition du dialogue', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              confirmText: 'OK',
            ),
          ),
        ),
      );

      // Au début, avant l'animation
      await tester.pump();

      // assert - vérifier que les animations existent (il peut y en avoir plusieurs)
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);
    });

    group('Extension IOSDialogExtension', () {
      testWidgets('showIOSDialog doit retourner true lors de la confirmation', (tester) async {
        // arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await context.showIOSDialog(
                          title: 'Test',
                          message: 'Message',
                          confirmText: 'OK',
                          cancelText: 'Annuler',
                        );
                        // Stocker le résultat pour vérification
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.toString())),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('true'), findsOneWidget);
      });

      testWidgets('showIOSDialog doit retourner false lors de l\'annulation', (tester) async {
        // arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await context.showIOSDialog(
                          title: 'Test',
                          message: 'Message',
                          confirmText: 'OK',
                          cancelText: 'Annuler',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.toString())),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('showConfirmationDialog doit afficher un dialogue de confirmation', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.showConfirmationDialog(
                          title: 'Confirmation',
                          message: 'Êtes-vous sûr?',
                        );
                      },
                      child: const Text('Show'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('Confirmation'), findsOneWidget);
        expect(find.text('Êtes-vous sûr?'), findsOneWidget);
        expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      });

      testWidgets('showWarningDialog doit afficher un dialogue d\'avertissement', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.showWarningDialog(
                          title: 'Attention',
                          message: 'Ceci est un avertissement',
                        );
                      },
                      child: const Text('Show'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('Attention'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });

      testWidgets('showErrorDialog doit afficher un dialogue d\'erreur', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.showErrorDialog(
                          title: 'Erreur',
                          message: 'Une erreur s\'est produite',
                        );
                      },
                      child: const Text('Show'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('Erreur'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
        expect(find.text('Annuler'), findsNothing); // Pas de bouton annuler
      });

      testWidgets('showInfoDialog doit afficher un dialogue d\'information', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.showInfoDialog(
                          title: 'Information',
                          message: 'Voici une information',
                        );
                      },
                      child: const Text('Show'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('Information'), findsOneWidget);
        expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
        expect(find.text('Annuler'), findsNothing); // Pas de bouton annuler
      });
    });

    testWidgets('doit disposer correctement l\'AnimationController', (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IOSDialog(
              title: 'Test',
              message: 'Message',
              confirmText: 'OK',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // act - supprimer le widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // assert - ne doit pas lever d'exception
      expect(tester.takeException(), isNull);
    });
  });
}
