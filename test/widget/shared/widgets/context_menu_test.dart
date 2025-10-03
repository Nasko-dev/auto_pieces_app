import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/shared/presentation/widgets/context_menu.dart';

void main() {
  group('ContextMenu', () {
    testWidgets('doit afficher le bouton de menu', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenu(
              items: const [
                ContextMenuItem(
                  value: 'test',
                  label: 'Test',
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      );

      // assert
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('doit afficher les éléments du menu lors du tap',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenu(
              items: const [
                ContextMenuItem(
                  value: 'item1',
                  label: 'Item 1',
                  icon: Icons.edit,
                ),
                ContextMenuItem(
                  value: 'item2',
                  label: 'Item 2',
                  icon: Icons.delete,
                ),
              ],
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('doit appeler onSelected lors de la sélection d\'un élément',
        (tester) async {
      // arrange
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenu(
              items: const [
                ContextMenuItem(
                  value: 'test',
                  label: 'Test',
                  icon: Icons.check,
                ),
              ],
              onSelected: (value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // assert
      expect(selectedValue, 'test');
    });

    testWidgets('doit afficher les éléments destructifs en rouge',
        (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenu(
              items: const [
                ContextMenuItem(
                  value: 'delete',
                  label: 'Supprimer',
                  icon: Icons.delete,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      final textWidget = tester.widget<Text>(find.text('Supprimer'));
      expect(textWidget.style?.color, isNot(null));
      // La couleur devrait être AppTheme.error (rouge)
    });

    testWidgets('doit afficher un séparateur quand showDividerBefore est true',
        (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenu(
              items: const [
                ContextMenuItem(
                  value: 'item1',
                  label: 'Item 1',
                  icon: Icons.edit,
                ),
                ContextMenuItem(
                  value: 'item2',
                  label: 'Item 2',
                  icon: Icons.delete,
                  showDividerBefore: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(PopupMenuDivider), findsOneWidget);
    });

    testWidgets('ne doit pas afficher de séparateur au début', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenu(
              items: const [
                ContextMenuItem(
                  value: 'item1',
                  label: 'Item 1',
                  icon: Icons.edit,
                  showDividerBefore:
                      true, // Ne devrait pas afficher car c'est le premier
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(PopupMenuDivider), findsNothing);
    });
  });

  group('DeleteContextMenu', () {
    testWidgets('doit afficher uniquement l\'option de suppression',
        (tester) async {
      // arrange

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeleteContextMenu(
              onDelete: () {},
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Supprimer'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('doit appeler onDelete lors du tap', (tester) async {
      // arrange
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeleteContextMenu(
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      // assert
      expect(deleteCalled, true);
    });
  });

  group('EditDeleteContextMenu', () {
    testWidgets('doit afficher les options de modification et suppression',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditDeleteContextMenu(
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Modifier'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('doit appeler onEdit lors du tap sur Modifier', (tester) async {
      // arrange
      bool editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditDeleteContextMenu(
              onEdit: () {
                editCalled = true;
              },
              onDelete: () {},
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();

      // assert
      expect(editCalled, true);
    });

    testWidgets('doit appeler onDelete lors du tap sur Supprimer',
        (tester) async {
      // arrange
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditDeleteContextMenu(
              onEdit: () {},
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      // assert
      expect(deleteCalled, true);
    });

    testWidgets('doit afficher un séparateur entre Modifier et Supprimer',
        (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditDeleteContextMenu(
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(PopupMenuDivider), findsOneWidget);
    });
  });

  group('ContextMenuItem', () {
    test('doit créer un ContextMenuItem avec les valeurs par défaut', () {
      // arrange & act
      const item = ContextMenuItem(
        value: 'test',
        label: 'Test',
        icon: Icons.check,
      );

      // assert
      expect(item.value, 'test');
      expect(item.label, 'Test');
      expect(item.icon, Icons.check);
      expect(item.isDestructive, false);
      expect(item.showDividerBefore, false);
    });

    test('doit créer un ContextMenuItem destructif', () {
      // arrange & act
      const item = ContextMenuItem(
        value: 'delete',
        label: 'Supprimer',
        icon: Icons.delete,
        isDestructive: true,
      );

      // assert
      expect(item.isDestructive, true);
    });

    test('doit créer un ContextMenuItem avec séparateur', () {
      // arrange & act
      const item = ContextMenuItem(
        value: 'test',
        label: 'Test',
        icon: Icons.check,
        showDividerBefore: true,
      );

      // assert
      expect(item.showDividerBefore, true);
    });
  });

  group('ContextMenu Design', () {
    testWidgets('doit avoir les bonnes bordures arrondies', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenu(
              items: const [
                ContextMenuItem(
                  value: 'test',
                  label: 'Test',
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      );

      // assert
      final popupButton = tester.widget<PopupMenuButton<String>>(
        find.byType(PopupMenuButton<String>),
      );
      expect(popupButton.shape, isNotNull);
    });

    testWidgets('doit gérer plusieurs éléments', (tester) async {
      // arrange
      final items = List.generate(
        5,
        (index) => ContextMenuItem(
          value: 'item$index',
          label: 'Item $index',
          icon: Icons.check,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContextMenu(items: items),
          ),
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // assert
      for (int i = 0; i < 5; i++) {
        expect(find.text('Item $i'), findsOneWidget);
      }
    });
  });
}
