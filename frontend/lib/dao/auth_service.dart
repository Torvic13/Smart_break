import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../models/administrador_sistema.dart';
import '../models/estudiante.dart';

/// Servicio singleton para manejar la sesión del usuario actual
/// con persistencia local usando SharedPreferences
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Usuario? _usuarioActual;
  String _token = '';

  /// Obtiene el usuario actualmente autenticado
  Usuario? get usuarioActual => _usuarioActual;

  /// Obtiene el token de autenticación
  String get token => _token;

  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => _usuarioActual != null && _token.isNotEmpty;

  /// Verifica si el usuario actual es un administrador
  bool get isAdmin => _usuarioActual != null &&
      _usuarioActual!.runtimeType.toString() == 'AdministradorSistema';

  /// Establece el usuario actual después del login
  void setUsuario(Usuario usuario, {String token = ''}) {
    _usuarioActual = usuario;
    _token = token;
    _guardarSesion(usuario, token);
    notifyListeners();
  }

  /// Cierra la sesión del usuario actual
  void logout() {
    _usuarioActual = null;
    _token = '';
    _borrarSesion();
    notifyListeners();
  }

  /// Actualiza los datos del usuario actual
  void actualizarUsuario(Usuario usuario) {
    if (_usuarioActual?.idUsuario == usuario.idUsuario) {
      _usuarioActual = usuario;
      _guardarSesion(usuario, _token);
      notifyListeners();
    }
  }

  // 🔹 Guarda la sesión en SharedPreferences
  Future<void> _guardarSesion(Usuario usuario, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idUsuario', usuario.idUsuario);
    await prefs.setString('email', usuario.email);
    await prefs.setString('rol', usuario.runtimeType.toString());
    await prefs.setString('auth_token', token);

    // Si el usuario es estudiante, guardamos sus datos específicos
    if (usuario is Estudiante) {
      await prefs.setString('codigoAlumno', usuario.codigoAlumno);
      await prefs.setString('nombreCompleto', usuario.nombreCompleto);
      await prefs.setBool('ubicacionCompartida', usuario.ubicacionCompartida);
      await prefs.setString('carrera', usuario.carrera);
    }
  }

  // 🔹 Carga la sesión (cuando inicia la app)
  Future<void> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('idUsuario');
    final email = prefs.getString('email');
    final rol = prefs.getString('rol');
    final token = prefs.getString('auth_token');

    if (id != null && email != null && rol != null) {
      if (rol == 'AdministradorSistema') {
        _usuarioActual = AdministradorSistema(
          idUsuario: id,
          email: email,
          passwordHash: '',
          fechaCreacion: DateTime.now(),
          estado: EstadoUsuario.activo,
        );
      } else {
        // Recuperamos los datos adicionales del estudiante
        final codigoAlumno = prefs.getString('codigoAlumno') ?? email;
        final nombreCompleto = prefs.getString('nombreCompleto') ?? 'Usuario guardado';
        final carrera = prefs.getString('carrera') ?? 'No especificada';
        final ubicacionCompartida = prefs.getBool('ubicacionCompartida') ?? false;

        _usuarioActual = Estudiante(
          idUsuario: id,
          email: email,
          passwordHash: '',
          fechaCreacion: DateTime.now(),
          estado: EstadoUsuario.activo,
          codigoAlumno: codigoAlumno,
          nombreCompleto: nombreCompleto,
          ubicacionCompartida: ubicacionCompartida,
          carrera: carrera,
        );
      }
      
      _token = token ?? '';
      notifyListeners();
    }
  }

  // 🔹 Borra los datos guardados
  Future<void> _borrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}