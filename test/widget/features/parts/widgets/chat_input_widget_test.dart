import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/parts/presentation/widgets/chat_input_widget.dart';

void main() {
  group('ChatInputWidget', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('doit afficher le widget avec les paramètres par défaut',
        (tester) async {
      // arrange
      // ignore: unused_local_variable
      String? sentMessage;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) => sentMessage = message,
            ),
          ),
        ),
      );

      // assert
      expect(find.byType(ChatInputWidget), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Message...'), findsOneWidget); // hint text
    });

    testWidgets('doit afficher les boutons par défaut sans texte',
        (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
              onCamera: () {},
              onGallery: () {},
              onOffer: () {},
            ),
          ),
        ),
      );

      // assert
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.send),
          findsNothing); // Pas de bouton send sans texte
    });

    testWidgets('doit afficher le bouton send quand il y a du texte',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
            ),
          ),
        ),
      );

      // act
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();

      // assert
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsNothing);
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    });

    testWidgets('doit masquer les boutons galerie/offre quand il y a du texte',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
              onGallery: () {},
              onOffer: () {},
            ),
          ),
        ),
      );

      // act
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      // assert
      expect(find.byIcon(Icons.photo_library_outlined), findsNothing);
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('doit appeler onSend quand on appuie sur le bouton send',
        (tester) async {
      // arrange
      // ignore: unused_local_variable
      String? sentMessage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) => sentMessage = message,
            ),
          ),
        ),
      );

      // act
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));

      // assert
      expect(sentMessage, 'Test message');
    });

    testWidgets('doit appeler onSend quand on soumet le TextField',
        (tester) async {
      // arrange
      // ignore: unused_local_variable
      String? sentMessage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) => sentMessage = message,
            ),
          ),
        ),
      );

      // act
      await tester.enterText(find.byType(TextField), 'Test submission');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // assert
      expect(sentMessage, 'Test submission');
    });

    testWidgets('ne doit pas envoyer de message vide', (tester) async {
      // arrange
      // ignore: unused_local_variable
      String? sentMessage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) => sentMessage = message,
            ),
          ),
        ),
      );

      // act
      await tester.enterText(
          find.byType(TextField), '   '); // Espaces seulement
      await tester.pump();

      // assert
      expect(find.byIcon(Icons.send),
          findsNothing); // Pas de bouton send pour texte vide

      // act - essayer de soumettre
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // assert
      expect(sentMessage, null); // Aucun message envoyé
    });

    testWidgets('doit appeler onCamera quand on clique sur le bouton caméra',
        (tester) async {
      // arrange
      bool cameraCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
              onCamera: () => cameraCalled = true,
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.camera_alt_outlined));

      // assert
      expect(cameraCalled, true);
    });

    testWidgets('doit appeler onGallery quand on clique sur le bouton galerie',
        (tester) async {
      // arrange
      bool galleryCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
              onGallery: () => galleryCalled = true,
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.photo_library_outlined));

      // assert
      expect(galleryCalled, true);
    });

    testWidgets('doit appeler onOffer quand on clique sur le bouton offre',
        (tester) async {
      // arrange
      bool offerCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
              onOffer: () => offerCalled = true,
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.add_circle_outline));

      // assert
      expect(offerCalled, true);
    });

    testWidgets('ne doit pas afficher le bouton offre si onOffer est null',
        (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
              // onOffer non fourni
            ),
          ),
        ),
      );

      // assert
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    });

    testWidgets('doit désactiver les inputs quand isLoading=true',
        (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
              isLoading: true,
            ),
          ),
        ),
      );

      // assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('doit afficher le loading indicator quand isLoading=true',
        (tester) async {
      // arrange
      controller.text = 'Test message'; // Pour que le bouton send soit visible

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
              isLoading: true,
            ),
          ),
        ),
      );

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('ne doit pas envoyer de message pendant le loading',
        (tester) async {
      // arrange
      // ignore: unused_local_variable
      String? sentMessage;
      controller.text = 'Test message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) => sentMessage = message,
              isLoading: true,
            ),
          ),
        ),
      );

      // act
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // assert
      expect(sentMessage, null);
    });

    group('Tooltips', () {
      testWidgets('doit avoir des tooltips sur les boutons', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatInputWidget(
                controller: controller,
                onSend: (message) {},
                onCamera: () {},
                onGallery: () {},
                onOffer: () {},
              ),
            ),
          ),
        );

        // assert
        expect(find.byTooltip('Prendre une photo'), findsOneWidget);
        expect(find.byTooltip('Choisir dans la galerie'), findsOneWidget);
        expect(find.byTooltip('Faire une offre'), findsOneWidget);
      });
    });

    group('Styling et couleurs', () {
      testWidgets('doit utiliser les bonnes couleurs pour le bouton offre',
          (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatInputWidget(
                controller: controller,
                onSend: (message) {},
                onOffer: () {},
              ),
            ),
          ),
        );

        // assert
        final offerButton = tester.widget<Container>(
          find.byWidgetPredicate((widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  const Color(0xFF34C759)),
        );
        expect(offerButton, isNotNull);
      });

      testWidgets('doit utiliser les bonnes couleurs pour le bouton send',
          (tester) async {
        // arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatInputWidget(
                controller: controller,
                onSend: (message) {},
              ),
            ),
          ),
        );

        // act
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pump();

        // assert
        final sendButton = tester.widget<AnimatedContainer>(
          find.byWidgetPredicate((widget) =>
              widget is AnimatedContainer &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  const Color(0xFF3B82F6)),
        );
        expect(sendButton, isNotNull);
      });
    });

    group('Animation et états', () {
      testWidgets('doit animer l\'apparition du bouton send', (tester) async {
        // arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatInputWidget(
                controller: controller,
                onSend: (message) {},
              ),
            ),
          ),
        );

        // act
        await tester.enterText(find.byType(TextField), 'T');
        await tester.pump();

        // assert
        expect(find.byType(AnimatedContainer), findsOneWidget);
      });

      testWidgets('doit gérer les changements d\'état du texte',
          (tester) async {
        // arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatInputWidget(
                controller: controller,
                onSend: (message) {},
                onGallery: () {},
                onOffer: () {},
              ),
            ),
          ),
        );

        // État initial - sans texte
        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);

        // act - ajouter du texte
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pump();

        // assert - avec texte
        expect(find.byIcon(Icons.send), findsOneWidget);
        expect(find.byIcon(Icons.photo_library_outlined), findsNothing);

        // act - supprimer le texte
        await tester.enterText(find.byType(TextField), '');
        await tester.pump();

        // assert - sans texte à nouveau
        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
        expect(find.byIcon(Icons.send), findsNothing);
      });
    });

    group('Layout et responsivité', () {
      testWidgets('doit s\'adapter à la largeur de l\'écran', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: ChatInputWidget(
                  controller: controller,
                  onSend: (message) {},
                ),
              ),
            ),
          ),
        );

        // assert - vérifier qu'un container avec contraintes existe
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('doit avoir une zone de saisie expandable', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatInputWidget(
                controller: controller,
                onSend: (message) {},
              ),
            ),
          ),
        );

        // assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.maxLines, null); // Permet l'expansion
        expect(textField.textCapitalization, TextCapitalization.sentences);
      });
    });

    group('Gestion des callbacks null', () {
      testWidgets('doit gérer les callbacks optionnels null', (tester) async {
        // arrange & act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatInputWidget(
                controller: controller,
                onSend: (message) {},
                // Tous les callbacks optionnels omis
              ),
            ),
          ),
        );

        // assert - ne doit pas lever d'exception
        expect(find.byType(ChatInputWidget), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
        // Les autres boutons peuvent être présents mais désactivés
      });
    });

    testWidgets('doit nettoyer les listeners lors du dispose', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputWidget(
              controller: controller,
              onSend: (message) {},
            ),
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
