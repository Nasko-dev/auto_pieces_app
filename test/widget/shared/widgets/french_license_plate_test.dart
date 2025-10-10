import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/shared/presentation/widgets/french_license_plate.dart';

void main() {
  group('FrenchLicensePlate Widget', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('doit afficher le widget avec les paramètres par défaut', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // assert
      expect(find.byType(FrenchLicensePlate), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('AA-123-BB'), findsOneWidget); // hint text
    });

    testWidgets('doit initialiser avec plateNumber si fourni', (tester) async {
      // arrange
      const plateNumber = 'AB123CD';

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(
              controller: controller,
              plateNumber: plateNumber,
            ),
          ),
        ),
      );

      // assert
      expect(controller.text, plateNumber);
    });

    testWidgets('doit convertir le texte saisi en majuscules sans formatage automatique', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // act - saisir du texte non formaté
      await tester.enterText(find.byType(TextField), 'ab123cd');

      // assert
      expect(controller.text, 'AB123CD');
    });

    testWidgets('doit gérer les différentes étapes de saisie sans formatage automatique', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // act & assert - étape par étape
      await tester.enterText(find.byType(TextField), 'A');
      expect(controller.text, 'A');

      await tester.enterText(find.byType(TextField), 'AB');
      expect(controller.text, 'AB');

      await tester.enterText(find.byType(TextField), 'AB1');
      expect(controller.text, 'AB1');

      await tester.enterText(find.byType(TextField), 'AB123');
      expect(controller.text, 'AB123');

      await tester.enterText(find.byType(TextField), 'AB123C');
      expect(controller.text, 'AB123C');

      await tester.enterText(find.byType(TextField), 'AB123CD');
      expect(controller.text, 'AB123CD');
    });

    testWidgets('doit limiter la longueur à 15 caractères', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // act - essayer de saisir plus de caractères
      await tester.enterText(find.byType(TextField), 'AB123CDEFGHIJKLMNO');

      // assert
      expect(controller.text.length, lessThanOrEqualTo(15));
    });

    testWidgets('doit supprimer les caractères non alphanumériques sauf tirets', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // act
      await tester.enterText(find.byType(TextField), 'AB@123#CD\$');

      // assert
      expect(controller.text, 'AB123CD');
    });

    testWidgets('doit convertir en majuscules', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // act
      await tester.enterText(find.byType(TextField), 'ab123cd');

      // assert
      expect(controller.text, 'AB123CD');
    });

    testWidgets('doit appeler onChanged quand le texte change', (tester) async {
      // arrange
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(
              controller: controller,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      // act
      await tester.enterText(find.byType(TextField), 'AB123');

      // assert
      expect(changedValue, 'AB123');
    });

    testWidgets('doit appeler onSubmitted quand soumis', (tester) async {
      // arrange
      String? submittedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(
              controller: controller,
              onSubmitted: (value) => submittedValue = value,
            ),
          ),
        ),
      );

      // act
      await tester.enterText(find.byType(TextField), 'AB123CD');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // assert
      expect(submittedValue, 'AB123CD');
    });

    testWidgets('doit désactiver le champ quand enabled=false', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(
              controller: controller,
              enabled: false,
            ),
          ),
        ),
      );

      // assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('doit désactiver le champ quand isLoading=true', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(
              controller: controller,
              isLoading: true,
            ),
          ),
        ),
      );

      // assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('doit afficher l\'indicateur de chargement quand isLoading=true', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(
              controller: controller,
              isLoading: true,
            ),
          ),
        ),
      );

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('doit afficher le message d\'erreur', (tester) async {
      // arrange
      const errorMessage = 'Format de plaque invalide';

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(
              controller: controller,
              errorText: errorMessage,
            ),
          ),
        ),
      );

      // assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text &&
                      widget.data == errorMessage &&
                      widget.style?.color == Colors.red,
        ),
        findsOneWidget,
      );
    });

    testWidgets('ne doit pas afficher le message d\'erreur si errorText est null', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // assert
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && (widget.style?.color == Colors.red),
        ),
        findsNothing,
      );
    });

    testWidgets('doit afficher l\'image de fond de la plaque', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // assert
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image &&
                      widget.image is AssetImage &&
                      (widget.image as AssetImage).assetName == 'assets/images/french_plate.png',
        ),
        findsOneWidget,
      );
    });

    testWidgets('doit avoir le bon style de texte', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontFamily, 'Arial');
      expect(textField.style?.fontSize, 36);
      expect(textField.style?.fontWeight, FontWeight.w900);
      expect(textField.style?.letterSpacing, 8);
      expect(textField.style?.color, Colors.black);
    });

    testWidgets('doit centrer le texte', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textAlign, TextAlign.center);
      expect(textField.textCapitalization, TextCapitalization.characters);
    });

    testWidgets('doit gérer le focus correctement', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // act
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // assert
      expect(find.byType(TextField), findsOneWidget);
      // Le FocusNode est géré automatiquement
    });

    group('Formatage Edge Cases', () {
      testWidgets('doit gérer les plaques courtes', (tester) async {
        // arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FrenchLicensePlate(controller: controller),
            ),
          ),
        );

        // act & assert
        await tester.enterText(find.byType(TextField), 'A');
        expect(controller.text, 'A');

        await tester.enterText(find.byType(TextField), 'AB');
        expect(controller.text, 'AB');
      });

      testWidgets('doit gérer les plaques partielles', (tester) async {
        // arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FrenchLicensePlate(controller: controller),
            ),
          ),
        );

        // act & assert
        await tester.enterText(find.byType(TextField), 'AB1');
        expect(controller.text, 'AB1');

        await tester.enterText(find.byType(TextField), 'AB12');
        expect(controller.text, 'AB12');
      });

      testWidgets('doit gérer les textes trop longs', (tester) async {
        // arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FrenchLicensePlate(controller: controller),
            ),
          ),
        );

        // act
        await tester.enterText(find.byType(TextField), 'ABCDEFGHIJKLMNOP');

        // assert - doit être tronqué à 15 caractères max
        expect(controller.text.length, lessThanOrEqualTo(15));
        expect(controller.text, 'ABCDEFGHIJKLMNO'); // Les 15 premiers caractères
      });
    });

    group('États Combinés', () {
      testWidgets('doit gérer enabled=false ET isLoading=true', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FrenchLicensePlate(
                controller: controller,
                enabled: false,
                isLoading: true,
              ),
            ),
          ),
        );

        // assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, false);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('doit gérer errorText ET isLoading ensemble', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FrenchLicensePlate(
                controller: controller,
                isLoading: true,
                errorText: 'Erreur de test',
              ),
            ),
          ),
        );

        // assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Erreur de test'), findsOneWidget);
      });
    });

    testWidgets('doit disposer le FocusNode correctement', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrenchLicensePlate(controller: controller),
          ),
        ),
      );

      // act - reconstruire sans le widget
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