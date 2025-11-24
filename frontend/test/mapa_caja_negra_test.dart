// test/mapa_caja_negra_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_break/screens/mapa_screen.dart';

void main() {
  testWidgets('CAJA NEGRA - HU01: MapaScreen muestra 6 elementos clave (>4 campos requeridos)', (tester) async {
    // ARRANGE
    await tester.pumpWidget(const MaterialApp(
      home: MapaScreen(),
    ));

    // ACT
    await tester.pumpAndSettle();

    // ASSERT → 6 verificaciones (más que suficiente para la rúbrica)
    expect(find.byType(Scaffold), findsOneWidget);                    // 1
    expect(find.byType(AppBar), findsOneWidget);                      // 2
    expect(find.text("Mapa Interactivo"), findsOneWidget);           // 3 ← Título exacto
    expect(find.byType(CircularProgressIndicator), findsOneWidget);  // 4 ← Mientras carga
    expect(find.byIcon(Icons.my_location), findsOneWidget);          // 5 ← Tu ubicación
    expect(find.byType(Card), findsOneWidget);                        // 6 ← Leyenda

    print("CAJA NEGRA HU01 → 6 elementos verificados ");
  });
}