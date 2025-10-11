import 'auth_dao.dart';
import '../models/usuario.dart';
import '../models/estudiante.dart';
import 'mock_usuario_dao.dart';

class MockAuthDAO implements AuthDAO {
  final MockUsuarioDAO _usuarioDAO;

  MockAuthDAO(this._usuarioDAO);

  @override
  Future<bool> iniciarSesion({
    required String email,
    required String pass,
  }) async {
    try {
      final usuario = await _usuarioDAO.obtenerPorEmail(email);
      if (usuario != null) {
        return usuario.passwordHash == pass;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> crearCuenta(Map<String, dynamic> datos) async {
    final nuevoUsuario = Estudiante(
      idUsuario: DateTime.now().millisecondsSinceEpoch.toString(),
      email: datos['email'] as String,
      passwordHash: datos['password'] as String,
      fechaCreacion: DateTime.now(),
      estado: EstadoUsuario.activo,
      codigoAlumno: datos['codigoAlumno'] as String,
      nombreCompleto: datos['nombreCompleto'] as String,
      ubicacionCompartida: false,
      carrera: datos['carrera'] as String,
    );
    await _usuarioDAO.crear(nuevoUsuario);
  }
}
