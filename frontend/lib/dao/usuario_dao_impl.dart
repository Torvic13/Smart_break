import 'usuario_dao.dart';
import '../models/usuario.dart';

class UsuarioDAOImpl extends UsuarioDAO {
  @override
  Future<Usuario?> obtenerPorId(String id) async {
    // Tu implementación aquí
    return null;
  }

  @override
  Future<Usuario?> obtenerPorEmail(String email) async {
    // Tu implementación aquí
    return null;
  }

  @override
  Future<List<Usuario>> obtenerTodos() async {
    // Tu implementación aquí
    return [];
  }

  @override
  Future<void> crear(Usuario usuario) async {
    // Tu implementación aquí
  }

  @override
  Future<void> actualizar(Usuario usuario) async {
    // Tu implementación aquí
  }

  @override
  Future<void> eliminar(String id) async {
    // Tu implementación aquí
  }
}