// lib/dao/http_dao_factory.dart
import 'dao_factory.dart';

// DAOs de autenticación / usuario
import 'auth_dao.dart';
import 'http_auth_dao.dart';
import 'usuario_dao.dart';

// DAOs de dominio
import 'espacio_dao.dart';
import 'calificacion_dao.dart';
import 'reporte_ocupacion_dao.dart';
import 'categoria_dao.dart';

// HTTP DAOs
import 'http_espacio_dao.dart';
import 'http_calificacion_dao.dart';

// Mocks que aún seguimos usando
import 'mock_usuario_dao.dart';
import 'mock_reporte_ocupacion_dao.dart';
import 'mock_categoria_dao.dart';

class HttpDAOFactory implements DAOFactory {
  // Usuario lo seguimos usando mock porque aún no tienes CRUD real
  final MockUsuarioDAO _mockUsuarioDao = MockUsuarioDAO();

  static const String _baseUrl = 'http://10.0.2.2:4000/api/v1';

  @override
  AuthDAO createAuthDAO() => HttpAuthDAO(
        baseUrl: _baseUrl,
      );

  @override
  UsuarioDAO createUsuarioDAO() => _mockUsuarioDao;

  // Espacios se cargan/crean desde el backend
  @override
  EspacioDAO createEspacioDAO() => HttpEspacioDAO(baseUrl: _baseUrl);

  // 🔥 Calificaciones ahora van contra el backend
  @override
  CalificacionDAO createCalificacionDAO() =>
      HttpCalificacionDAO(baseUrl: _baseUrl);

  @override
  ReporteOcupacionDAO createReporteOcupacionDAO() =>
      MockReporteOcupacionDAO();

  @override
  CategoriaDAO createCategoriaDAO() => MockCategoriaDAO();
}
