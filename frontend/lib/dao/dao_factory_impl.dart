import 'dao_factory.dart';
import 'usuario_dao.dart';
import 'usuario_dao_impl.dart';
import 'espacio_dao.dart';
import 'espacio_dao_impl.dart';
import 'calificacion_dao.dart';
import 'http_calificacion_dao.dart';
import 'reporte_ocupacion_dao.dart';
import 'reporte_ocupacion_dao_impl.dart';
import 'auth_dao.dart';
import 'http_auth_dao.dart';
import 'categoria_dao.dart';
import 'categoria_dao_impl.dart';
import 'http_espacio_dao.dart';

class DAOFactoryImpl extends DAOFactory {
  final String baseUrl = 'http://10.0.2.2:4000';

  @override
  UsuarioDAO createUsuarioDAO() {
    return UsuarioDAOImpl();
  }

  @override
  AuthDAO createAuthDAO() {
    return HttpAuthDAO(baseUrl: baseUrl);
  }

  @override
  EspacioDAO createEspacioDAO() {
    return HttpEspacioDAO(baseUrl: baseUrl);
  }

  @override
  CalificacionDAO createCalificacionDAO() {
    return HttpCalificacionDAO(baseUrl: baseUrl);
  }

  @override
  ReporteOcupacionDAO createReporteOcupacionDAO() {
    return ReporteOcupacionDAOImpl();
  }

  @override
  CategoriaDAO createCategoriaDAO() {
    return CategoriaDAOImpl();
  }
}