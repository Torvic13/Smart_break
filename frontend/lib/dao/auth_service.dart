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
  String? _accessToken;

  /// Usuario actualmente autenticado
  Usuario? get usuarioActual => _usuarioActual;

  /// Token JWT actual (para llamar al backend)
  String? get token => _accessToken;

  /// ¿Hay usuario + token?
  bool get isAuthenticated => _usuarioActual != null && _accessToken != null;

  /// ¿Es admin?
  bool get isAdmin {
    final u = _usuarioActual;
    if (u == null) return false;
    if (u is AdministradorSistema) return true;
    // Si más adelante usas un campo rol, aquí podrías chequearlo también.
    return false;
  }

  // =========================================================
  //  MÉTODOS PRINCIPALES (que debería usar el DAO de login)
  // =========================================================

  /// Guarda usuario + token en memoria y en disco
  void setSession({
    required Usuario usuario,
    String? accessToken,
  }) {
    _usuarioActual = usuario;
    _accessToken = accessToken;
    _guardarSesion(usuario, accessToken);
    notifyListeners();
  }

  /// Cierra sesión
  void logout() {
    _usuarioActual = null;
    _accessToken = null;
    _borrarSesion();
    notifyListeners();
  }

  /// Actualiza los datos del usuario actual (sin cambiar token)
  void actualizarUsuario(Usuario usuario) {
    if (_usuarioActual?.idUsuario == usuario.idUsuario) {
      _usuarioActual = usuario;
      _guardarSesion(usuario, _accessToken);
      notifyListeners();
    }
  }

  // =========================================================
  //  MÉTODOS DE COMPATIBILIDAD CON TU CÓDIGO ANTERIOR
  // =========================================================

  /// Compatibilidad: antes usabas AuthService().setUsuario(usuario);
  /// Ahora delega a setSession pero SIN token (por si no lo tienes ahí).
  void setUsuario(Usuario usuario) {
    setSession(usuario: usuario, accessToken: _accessToken);
  }

  // =========================================================
  //  PERSISTENCIA EN SHARED PREFERENCES
  // =========================================================

  Future<void> _guardarSesion(Usuario usuario, String? token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idUsuario', usuario.idUsuario);
    await prefs.setString('email', usuario.email);
    await prefs.setString('rol', usuario.runtimeType.toString());

    if (token != null) {
      await prefs.setString('accessToken', token);
    }

    // Si el usuario es estudiante, guardamos sus datos específicos
    if (usuario is Estudiante) {
      await prefs.setString('codigoAlumno', usuario.codigoAlumno);
      await prefs.setString('nombreCompleto', usuario.nombreCompleto);
      await prefs.setBool('ubicacionCompartida', usuario.ubicacionCompartida);
      await prefs.setString('carrera', usuario.carrera);
    } else {
      // Limpiar campos de estudiante si no aplica
      await prefs.remove('codigoAlumno');
      await prefs.remove('nombreCompleto');
      await prefs.remove('ubicacionCompartida');
      await prefs.remove('carrera');
    }
  }

  /// Carga la sesión (cuando inicia la app)
  Future<void> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('idUsuario');
    final email = prefs.getString('email');
    final rol = prefs.getString('rol');
    final savedToken = prefs.getString('accessToken');

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
        final nombreCompleto =
            prefs.getString('nombreCompleto') ?? 'Usuario guardado';
        final carrera = prefs.getString('carrera') ?? 'No especificada';
        final ubicacionCompartida =
            prefs.getBool('ubicacionCompartida') ?? false;

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

      _accessToken = savedToken;
      notifyListeners();
    }
  }

  /// Borra los datos guardados
  Future<void> _borrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}