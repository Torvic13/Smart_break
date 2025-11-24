import 'package:smart_break/dao/dao_factory.dart';
// Importar todas las interfaces DAO
import 'package:smart_break/dao/usuario_dao.dart';
import 'package:smart_break/dao/auth_dao.dart';
import 'package:smart_break/dao/espacio_dao.dart';
import 'package:smart_break/dao/calificacion_dao.dart';
import 'package:smart_break/dao/reporte_ocupacion_dao.dart';
import 'package:smart_break/dao/categoria_dao.dart';
// Importar todas las implementaciones concretas HTTP (DEBES CREAR ESTOS ARCHIVOS)
import 'package:smart_break/dao/http_usuario_dao.dart';
import 'package:smart_break/dao/http_auth_dao.dart';
import 'package:smart_break/dao/http_espacio_dao.dart';
import 'package:smart_break/dao/http_calificacion_dao.dart';
import 'package:smart_break/dao/http_reporte_ocupacion_dao.dart';
import 'package:smart_break/dao/http_categoria_dao.dart';


// Fábrica concreta que crea DAOs que se comunican con un backend HTTP
class HttpDAOFactory implements DAOFactory {
  final String baseUrl;

  HttpDAOFactory({required this.baseUrl});

  // ----------------------------------------------------------------
  // DEBES CREAR LAS OTRAS CLASES HTTP DAOs (Ej: HttpUsuarioDAO, etc.)
  // Si no existen, el compilador lanzará errores de archivos no encontrados.
  // Por ahora, asumimos que has creado archivos placeholder con sus clases.
  // ----------------------------------------------------------------

  @override
  UsuarioDAO createUsuarioDAO() {
    return HttpUsuarioDAO(baseUrl: baseUrl);
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
    // Usamos la implementación corregida que tiene todos los métodos
    return HttpReporteOcupacionDAO(baseUrl: baseUrl);
  }

  @override
  CategoriaDAO createCategoriaDAO() {
    return HttpCategoriaDAO(baseUrl: baseUrl);
  }
}