import 'dao_factory.dart';

// DAOs de autenticación / usuario
import 'auth_dao.dart';
import 'http_auth_dao.dart';
import 'usuario_dao.dart';
import 'http_usuario_dao.dart';

// DAOs de dominio
import 'espacio_dao.dart';
import 'calificacion_dao.dart';
import 'reporte_ocupacion_dao.dart';
import 'categoria_dao.dart';

// NUEVO: Espacio HTTP DAO
import 'http_espacio_dao.dart';

// Mocks
import 'mock_calificacion_dao.dart';
import 'mock_reporte_ocupacion_dao.dart';
import 'mock_categoria_dao.dart';

class HttpDAOFactory implements DAOFactory {
  @override
  AuthDAO createAuthDAO() => HttpAuthDAO(
        // Emulador Android → localhost = 10.0.2.2
        baseUrl: 'http://10.0.2.2:4000/api/v1',
      );

  @override
  UsuarioDAO createUsuarioDAO() => HttpUsuarioDAO(
        baseUrl: 'http://10.0.2.2:4000/api/v1',
      );

  // 👉 AHORA ESPACIOS SE CARGAN DESDE EL BACKEND
  @override
  EspacioDAO createEspacioDAO() =>
      HttpEspacioDAO(baseUrl: 'http://10.0.2.2:4000/api/v1');

  @override
  CalificacionDAO createCalificacionDAO() => MockCalificacionDAO();

  @override
  ReporteOcupacionDAO createReporteOcupacionDAO() =>
      MockReporteOcupacionDAO();

  @override
  CategoriaDAO createCategoriaDAO() => MockCategoriaDAO();
}
