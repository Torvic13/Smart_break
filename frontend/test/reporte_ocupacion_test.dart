// frontend/test/reporte_ocupacion_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/dao/dao_factory.dart';
import '../lib/dao/http_dao_factory.dart';
import '../lib/screens/detalle_espacio_screen.dart';
import '../lib/models/espacio.dart';
import '../lib/models/ubicacion.dart';


void main() {
  group('HU22 - Control de abuso en reportes (CAJA NEGRA)', () {
    testWidgets('Muestra popup rojo al intentar reportar dos veces rápido', (tester) async {
      final espacio = Espacio(
        idEspacio: 'test-123',
        nombre: 'Biblioteca Central',
        tipo: 'biblioteca',
        nivelOcupacion: NivelOcupacion.medio,
        promedioCalificacion: 4.5,
        ubicacion: Ubicacion(latitud: -12.058, longitud: -77.034, piso: 2),
        caracteristicas: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<DAOFactory>(create: (_) => HttpDAOFactory()),
              // Si tu DetalleEspacioScreen usa AuthService, esto evita errores
              ChangeNotifierProvider(create: (_) => FakeAuthService()),
            ],
            child: DetalleEspacioScreen(espacio: espacio),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Primer reporte
      await tester.tap(find.text('Reportar ahora'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alta ocupación'));
      await tester.pumpAndSettle();

      expect(find.textContaining('enviado correctamente'), findsOneWidget);

      // Segundo intento rápido
      await tester.tap(find.text('Reportar ahora'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alta ocupación'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Popup de error
      expect(find.textContaining('Espera'), findsOneWidget);
      expect(find.textContaining('minutos'), findsOneWidget);
    });
  });
}

// Mock del AuthService (para que no pida login)
class FakeAuthService extends ChangeNotifier {
  bool get estaLogueado => true;
  String? get usuarioId => 'test-user-123';
}