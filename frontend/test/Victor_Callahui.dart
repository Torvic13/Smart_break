import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_break/screens/mapa_screen.dart';

// Auth / modelos
import 'package:smart_break/dao/auth_service.dart';
import 'package:smart_break/models/estudiante.dart';
import 'package:smart_break/models/usuario.dart';

// DAO factory e interfaces
import 'package:smart_break/dao/dao_factory.dart';
import 'package:smart_break/dao/auth_dao.dart';
import 'package:smart_break/dao/usuario_dao.dart';
import 'package:smart_break/dao/espacio_dao.dart';
import 'package:smart_break/dao/calificacion_dao.dart';
import 'package:smart_break/dao/reporte_ocupacion_dao.dart';
import 'package:smart_break/dao/categoria_dao.dart';

// Mocks que ya tienes en tu proyecto
import 'package:smart_break/dao/mock_usuario_dao.dart';
import 'package:smart_break/dao/mock_espacio_dao.dart';
import 'package:smart_break/dao/mock_calificacion_dao.dart';
import 'package:smart_break/dao/mock_reporte_ocupacion_dao.dart';
import 'package:smart_break/dao/mock_categoria_dao.dart';

/// DAOFactory de prueba para los tests.
/// Usa los DAOs mock que ya tienes.
class MockDAOFactory implements DAOFactory {
  @override
  AuthDAO createAuthDAO() => throw UnimplementedError('No se usa en este test');

  @override
  UsuarioDAO createUsuarioDAO() => MockUsuarioDAO();

  @override
  EspacioDAO createEspacioDAO() => MockEspacioDAO();

  @override
  CalificacionDAO createCalificacionDAO() => MockCalificacionDAO();

  @override
  ReporteOcupacionDAO createReporteOcupacionDAO() =>
      MockReporteOcupacionDAO();

  @override
  CategoriaDAO createCategoriaDAO() => MockCategoriaDAO();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Usuario de prueba para simular que alguien ya inició sesión
  Future<void> _loguearEstudianteDummy() async {
    final estudiante = Estudiante(
      idUsuario: 'u1',
      email: 'test@smartbreak.com',
      passwordHash: '',
      fechaCreacion: DateTime.now(),
      estado: EstadoUsuario.activo,
      codigoAlumno: '20180319',
      nombreCompleto: 'Estudiante Prueba',
      ubicacionCompartida: true,
      carrera: 'Ingeniería de Sistemas',
    );

    AuthService().setSession(usuario: estudiante, accessToken: 'token-falso');
  }

  /// Construye la app de prueba con el Provider<DAOFactory>
  Widget _buildTestApp() {
    return MultiProvider(
      providers: [
        Provider<DAOFactory>(create: (_) => MockDAOFactory()),
      ],
      child: const MaterialApp(
        home: MapaScreen(),
      ),
    );
  }

  group('Onboarding en MapaScreen', () {
    setUp(() async {
      // Por defecto, como si nunca hubiera visto el onboarding
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'Muestra onboarding en el primer ingreso de un estudiante',
      (WidgetTester tester) async {
        await _loguearEstudianteDummy();

        await tester.pumpWidget(_buildTestApp());

        // Dejar que se construya la pantalla + se dispare el addPostFrameCallback
        await tester.pumpAndSettle();

        // Debe aparecer el texto principal del onboarding
        expect(find.text('Encuentra tu espacio ideal'), findsOneWidget);
      },
    );

    testWidgets(
      'El botón de ayuda vuelve a mostrar el onboarding',
      (WidgetTester tester) async {
        // Simulamos que ya lo vio antes
        SharedPreferences.setMockInitialValues({
          'hasSeenMapaOnboarding': true,
        });

        await _loguearEstudianteDummy();

        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        // 1) Al inicio NO debe mostrarse el onboarding
        expect(find.text('Encuentra tu espacio ideal'), findsNothing);

        // 2) Tocamos el botón flotante de ayuda
        await tester.tap(find.byIcon(Icons.help_outline));
        await tester.pumpAndSettle();

        // 3) Ahora sí debe aparecer el onboarding
        expect(find.text('Encuentra tu espacio ideal'), findsOneWidget);
      },
    );
  });
}

