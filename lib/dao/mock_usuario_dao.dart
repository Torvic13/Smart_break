import '../models/usuario.dart';
import '../models/estudiante.dart';
import '../models/administrador_sistema.dart';
import 'usuario_dao.dart';

class MockUsuarioDAO implements UsuarioDAO {
  static final List<Usuario> _usuarios = [
    Estudiante(
      idUsuario: '1',
      email: '20251234@aloe.ulima.edu.pe',
      passwordHash: '123456',
      fechaCreacion: DateTime.now().subtract(const Duration(days: 30)),
      estado: EstadoUsuario.activo,
      codigoAlumno: '20251234',
      nombreCompleto: 'Juan Pérez',
      ubicacionCompartida: true,
      carrera: 'Ingeniería de Sistemas',
    ),
    AdministradorSistema(
      idUsuario: '2',
      email: 'admin@aloe.ulima.edu.pe',
      passwordHash: 'admin123',
      fechaCreacion: DateTime.now().subtract(const Duration(days: 60)),
      estado: EstadoUsuario.activo,
    ),
  ];

  @override
  Future<Usuario?> obtenerPorId(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _usuarios.firstWhere((u) => u.idUsuario == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Usuario?> obtenerPorEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _usuarios.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Usuario>> obtenerTodos() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_usuarios);
  }

  @override
  Future<void> crear(Usuario usuario) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _usuarios.add(usuario);
  }

  @override
  Future<void> actualizar(Usuario usuario) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _usuarios.indexWhere((u) => u.idUsuario == usuario.idUsuario);
    if (index != -1) {
      _usuarios[index] = usuario;
    }
  }

  @override
  Future<void> eliminar(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _usuarios.removeWhere((u) => u.idUsuario == id);
  }
}
