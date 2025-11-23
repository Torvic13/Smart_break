import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_break/screens/filtered_spaces_screen.dart';
import 'package:smart_break/dao/mock_dao_factory.dart';

void main() {
  group('FilteredSpacesScreen Tests', () {
    late MockDAOFactory mockDAOFactory;

    setUp(() {
      mockDAOFactory = MockDAOFactory();
    });

    testWidgets('Screen displays with AppBar and filters section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<dynamic>.value(
            value: mockDAOFactory,
            child: const FilteredSpacesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Filtrar por Categorías'), findsWidgets);
      expect(find.text('Filtrar por categorías'), findsOneWidget);
    });

    testWidgets('Filter chips can be toggled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<dynamic>.value(
            value: mockDAOFactory,
            child: const FilteredSpacesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final filterChips = find.byType(FilterChip);
      expect(filterChips, findsWidgets);

      if (filterChips.evaluate().isNotEmpty) {
        await tester.tap(filterChips.first);
        await tester.pumpAndSettle();

        final selectedChips = find.byWidgetPredicate(
          (widget) => widget is FilterChip && widget.selected,
        );
        expect(selectedChips, findsWidgets);
      }
    });

    testWidgets('Spaces list displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<dynamic>.value(
            value: mockDAOFactory,
            child: const FilteredSpacesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Expansion tile collapses and expands',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<dynamic>.value(
            value: mockDAOFactory,
            child: const FilteredSpacesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final expansionTile = find.byType(ExpansionTile);
      expect(expansionTile, findsOneWidget);

      expect(find.byType(FilterChip), findsWidgets);

      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsNothing);

      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Back button exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<dynamic>.value(
            value: mockDAOFactory,
            child: const FilteredSpacesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
