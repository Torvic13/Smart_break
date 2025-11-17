import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import '../models/estudiante.dart';
import '../models/administrador_sistema.dart';
import 'auth_dao.dart';

class HttpAuthDAO implements AuthDAO {
  final String baseUrl;

  HttpAuthDAO({this.baseUrl = 'http://10.0.2.2:4000/api/v1'});

  @override
  Future<Usuario?> iniciarSesion({
    required String email,
    required String pass,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': pass,
      }),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final usuarioJson = data['usuario'] as Map<String, dynamic>;

      // Mapeamos según el rol que viene del backend ("admin" / "estudiante")
      final rolStr = usuarioJson['rol'] as String? ?? 'estudiante';

      if (rolStr == 'admin') {
        return AdministradorSistema(
          idUsuario: usuarioJson['idUsuario'],
          email: usuarioJson['email'],
          passwordHash: '', // el backend no envía hash, no lo necesitamos aquí
          fechaCreacion: DateTime.parse(usuarioJson['fechaCreacion']),
          estado: _estadoFromString(usuarioJson['estado']),
        );
      } else {
        return Estudiante(
          idUsuario: usuarioJson['idUsuario'],
          email: usuarioJson['email'],
          passwordHash: '',
          fechaCreacion: DateTime.parse(usuarioJson['fechaCreacion']),
          estado: _estadoFromString(usuarioJson['estado']),
          codigoAlumno: usuarioJson['codigoAlumno'] ?? '',
          nombreCompleto: usuarioJson['nombreCompleto'] ?? '',
          ubicacionCompartida:
              usuarioJson['ubicacionCompartida'] as bool? ?? false,
          carrera: usuarioJson['carrera'] ?? 'No especificada',
        );
      }
    }

    if (resp.statusCode == 400 || resp.statusCode == 401) {
      // credenciales inválidas
      return null;
    }

    throw Exception(
        'Error al iniciar sesión: [${resp.statusCode}] ${resp.body}');
  }

  @override
  Future<Usuario> crearCuenta(Map<String, dynamic> datos) async {
    final uri = Uri.parse('$baseUrl/usuarios');

    final body = {
      'email': datos['email'],
      'password': datos['password'],
      'rol': 'estudiante',
      'codigoAlumno': datos['codigoAlumno'],
      'nombreCompleto': datos['nombreCompleto'],
      'carrera': datos['carrera'],
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final usuarioJson = data['usuario'] as Map<String, dynamic>;

      return Estudiante(
        idUsuario: usuarioJson['idUsuario'],
        email: usuarioJson['email'],
        passwordHash: '',
        fechaCreacion: DateTime.parse(usuarioJson['fechaCreacion']),
        estado: _estadoFromString(usuarioJson['estado']),
        codigoAlumno: usuarioJson['codigoAlumno'] ?? '',
        nombreCompleto: usuarioJson['nombreCompleto'] ?? '',
        ubicacionCompartida:
            usuarioJson['ubicacionCompartida'] as bool? ?? false,
        carrera: usuarioJson['carrera'] ?? 'No especificada',
      );
    }

    throw Exception(
        'Error al registrar usuario: [${resp.statusCode}] ${resp.body}');
  }

  EstadoUsuario _estadoFromString(String? value) {
    switch (value) {
      case 'inactivo':
        return EstadoUsuario.inactivo;
      case 'suspendido':
        return EstadoUsuario.suspendido;
      case 'activo':
      default:
        return EstadoUsuario.activo;
    }
  }
}
