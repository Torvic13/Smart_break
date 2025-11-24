// lib/dao/http_dao_factory.dart
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

// HTTP DAOs
import 'http_espacio_dao.dart';
import 'http_calificacion_dao.dart';
import 'http_categoria_dao.dart';

// Mocks (solo lo que aún no va al backend)
import 'mock_reporte_ocupacion_dao.dart';

class HttpDAOFactory implements DAOFactory {
  static const String _baseUrl = 'http://10.0.2.2:4000/api/v1';

  @override
  AuthDAO createAuthDAO() => HttpAuthDAO(
        baseUrl: _baseUrl,
      );

  @override
  UsuarioDAO createUsuarioDAO() => HttpUsuarioDAO(
        baseUrl: _baseUrl,
      );

  // Espacios se cargan/crean desde el backend
  @override
  EspacioDAO createEspacioDAO() => HttpEspacioDAO(baseUrl: _baseUrl);

  // Categorías desde el backend
  @override
  CategoriaDAO createCategoriaDAO() => HttpCategoriaDAO(baseUrl: _baseUrl);

  // 🔥 Calificaciones ahora van contra el backend
  @override
  CalificacionDAO createCalificacionDAO() =>
      HttpCalificacionDAO(baseUrl: _baseUrl);

  @override
  ReporteOcupacionDAO createReporteOcupacionDAO() =>
      MockReporteOcupacionDAO();
}