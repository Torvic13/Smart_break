import 'auth_dao.dart';
import '../models/usuario.dart';
import '../models/estudiante.dart';
import 'mock_usuario_dao.dart';

class MockAuthDAO implements AuthDAO {
  final MockUsuarioDAO _usuarioDAO;

  // Token en memoria (solo para pruebas)
  String? _token;

  MockAuthDAO(this._usuarioDAO);

  @override
  Future<Usuario?> iniciarSesion({
    required String email,
    required String pass,
  }) async {
    try {
      final usuario = await _usuarioDAO.obtenerPorEmail(email);

      if (usuario != null && usuario.passwordHash == pass) {
        // Generar token ficticio para ambiente mock
        _token = 'mock-token-${usuario.idUsuario}';
        return usuario;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Usuario> crearCuenta(Map<String, dynamic> datos) async {
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

    // Generar token ficticio
    _token = 'mock-token-${nuevoUsuario.idUsuario}';

    return nuevoUsuario;
  }

  // ⭐ NUEVO: implementación obligatoria
  @override
  String? getToken() {
    return _token;
  }
}
