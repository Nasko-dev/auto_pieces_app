import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/shared/presentation/widgets/loading_widget.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('doit afficher CircularProgressIndicator avec les paramètres par défaut', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LoadingWidget), findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      ).first);
      expect(sizedBox.width, 40.0);
      expect(sizedBox.height, 40.0);
    });

    testWidgets('doit afficher CircularProgressIndicator avec taille personnalisée', (tester) async {
      // arrange
      const customSize = 60.0;

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(size: customSize),
          ),
        ),
      );

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      ).first);
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('doit afficher CircularProgressIndicator avec couleur personnalisée', (tester) async {
      // arrange
      const customColor = Colors.red;

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(color: customColor),
          ),
        ),
      );

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, customColor);
    });

    testWidgets('doit utiliser la couleur primaire du thème si aucune couleur n\'est fournie', (tester) async {
      // arrange
      const primaryColor = Colors.blue;

      // act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColor: primaryColor),
          home: const Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      // assert
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, primaryColor);
    });

    testWidgets('doit avoir strokeWidth de 3', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      // assert
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.strokeWidth, 3);
    });

    testWidgets('doit combiner taille et couleur personnalisées', (tester) async {
      // arrange
      const customSize = 50.0;
      const customColor = Colors.green;

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              size: customSize,
              color: customColor,
            ),
          ),
        ),
      );

      // assert
      final sizedBox = tester.widget<SizedBox>(find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      ).first);
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, customColor);
    });

    testWidgets('doit être un StatelessWidget', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      // assert
      final widget = tester.widget(find.byType(LoadingWidget));
      expect(widget, isA<StatelessWidget>());
    });

    testWidgets('doit fonctionner avec différentes tailles', (tester) async {
      // arrange & act - tester plusieurs tailles
      final sizes = [10.0, 20.0, 40.0, 60.0, 100.0];

      for (final size in sizes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoadingWidget(size: size),
            ),
          ),
        );

        // assert
        final sizedBox = tester.widget<SizedBox>(find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first);
        expect(sizedBox.width, size);
        expect(sizedBox.height, size);
      }
    });

    testWidgets('doit s\'afficher correctement dans différents conteneurs', (tester) async {
      // arrange & act - dans un Center
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingWidget(),
            ),
          ),
        ),
      );

      // assert
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // arrange & act - dans un Container
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 200,
              height: 200,
              color: Colors.grey,
              child: const LoadingWidget(),
            ),
          ),
        ),
      );

      // assert
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
