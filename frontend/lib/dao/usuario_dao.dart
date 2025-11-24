import '../models/usuario.dart';

abstract class UsuarioDAO {
  Future<Usuario?> obtenerPorId(String id);
  Future<Usuario?> obtenerPorEmail(String email);
  Future<List<Usuario>> obtenerTodos();
  Future<void> crear(Usuario usuario);
  Future<void> actualizar(Usuario usuario);
  Future<void> eliminar(String id);
  Future<void> actualizarUbicacionCompartida(String idUsuario, bool compartir);
}
