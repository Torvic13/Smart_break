import 'dao_factory.dart';

// DAOs de autenticación / usuario
import 'auth_dao.dart';
import 'http_auth_dao.dart';
import 'usuario_dao.dart';

// DAOs de tu dominio (los mismos que ya usas en MockDAOFactory)
import 'espacio_dao.dart';
import 'calificacion_dao.dart';
import 'reporte_ocupacion_dao.dart';
import 'categoria_dao.dart';

// Implementaciones mock para lo que aún no está conectado a backend
import 'mock_usuario_dao.dart';
import 'mock_espacio_dao.dart';
import 'mock_calificacion_dao.dart';
import 'mock_reporte_ocupacion_dao.dart';
import 'mock_categoria_dao.dart';

class HttpDAOFactory implements DAOFactory {
  // Por ahora solo Auth va contra el backend.
  // El resto sigue usando mocks.
  final MockUsuarioDAO _mockUsuarioDao = MockUsuarioDAO();

  @override
  AuthDAO createAuthDAO() => HttpAuthDAO(
        // 👇 IMPORTANTE: para emulador Android usa 10.0.2.2
        baseUrl: 'http://10.0.2.2:4000/api/v1',
      );

  @override
  UsuarioDAO createUsuarioDAO() => _mockUsuarioDao;

  @override
  EspacioDAO createEspacioDAO() => MockEspacioDAO();

  @override
  CalificacionDAO createCalificacionDAO() => MockCalificacionDAO();

  @override
  ReporteOcupacionDAO createReporteOcupacionDAO() => MockReporteOcupacionDAO();

  @override
  CategoriaDAO createCategoriaDAO() => MockCategoriaDAO();
}
