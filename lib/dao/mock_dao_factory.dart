
import 'dao_factory.dart';
import 'usuario_dao.dart';
import 'espacio_dao.dart';
import 'calificacion_dao.dart';
import 'reporte_ocupacion_dao.dart';
import 'auth_dao.dart';
import 'categoria_dao.dart';

import 'mock_usuario_dao.dart';
import 'mock_espacio_dao.dart';
import 'mock_calificacion_dao.dart';
import 'mock_reporte_ocupacion_dao.dart';
import 'mock_auth_dao.dart';
import 'mock_categoria_dao.dart';

/// Implementación concreta del patrón Factory Abstract.
/// Crea instancias de DAOs simulados (Mock) para desarrollo o pruebas.
class MockDAOFactory implements DAOFactory {
  // Singleton (una sola instancia en toda la app)
  static final MockDAOFactory _instance = MockDAOFactory._internal();

  // DAO compartido entre Auth y Usuario
  final MockUsuarioDAO _usuarioDAO = MockUsuarioDAO();

  factory MockDAOFactory() => _instance;

  MockDAOFactory._internal();

  @override
  UsuarioDAO createUsuarioDAO() {
    return _usuarioDAO;
  }

  @override
  AuthDAO createAuthDAO() {
    return MockAuthDAO(_usuarioDAO);
  }

  @override
  EspacioDAO createEspacioDAO() {
    return MockEspacioDAO();
  }

  @override
  CalificacionDAO createCalificacionDAO() {
    return MockCalificacionDAO();
  }

  @override
  ReporteOcupacionDAO createReporteOcupacionDAO() {
    return MockReporteOcupacionDAO();
  }

  @override
  CategoriaDAO createCategoriaDAO() {
    return MockCategoriaDAO();
  }
}
