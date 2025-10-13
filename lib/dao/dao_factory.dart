
import 'usuario_dao.dart';
import 'espacio_dao.dart';
import 'calificacion_dao.dart';
import 'reporte_ocupacion_dao.dart';
import 'auth_dao.dart';
import 'categoria_dao.dart';

/// Fábrica abstracta para crear los DAOs
abstract class DAOFactory {
  UsuarioDAO createUsuarioDAO();
  AuthDAO createAuthDAO();
  EspacioDAO createEspacioDAO();
  CalificacionDAO createCalificacionDAO();
  ReporteOcupacionDAO createReporteOcupacionDAO();
  CategoriaDAO createCategoriaDAO();
}
