// lib/dao/http_auth_dao.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import '../models/estudiante.dart';
import '../models/administrador_sistema.dart';
import 'auth_dao.dart';
import 'auth_service.dart';

class HttpAuthDAO implements AuthDAO {
  final String baseUrl;

  HttpAuthDAO({this.baseUrl = 'http://10.0.2.2:4000/api/v1'});

  // === Helper para extraer el token del JSON (raíz o anidado) ===
  String? _extraerToken(Map<String, dynamic> json) {
    if (json['token'] != null) return json['token'].toString();
    if (json['accessToken'] != null) return json['accessToken'].toString();
    if (json['jwt'] != null) return json['jwt'].toString();
    if (json['access_token'] != null) return json['access_token'].toString();
    return null;
  }

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

    // Log de depuración
    print('RESP LOGIN [${resp.statusCode}]: ${resp.body}');

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;

      // 1) Intentar token en la raíz
      String? token = _extraerToken(data);

      // 2) Si no está, intentar dentro de "data" (u otro contenedor)
      if (token == null && data['data'] is Map<String, dynamic>) {
        token = _extraerToken(data['data'] as Map<String, dynamic>);
      }

      // Log de token
      print('TOKEN EXTRAÍDO: $token');

      // Usuario puede estar en raíz o dentro de "data"
      Map<String, dynamic>? usuarioJson;

      if (data['usuario'] is Map<String, dynamic>) {
        usuarioJson = data['usuario'] as Map<String, dynamic>;
      } else if (data['data'] is Map<String, dynamic> &&
          (data['data'] as Map<String, dynamic>)['usuario']
              is Map<String, dynamic>) {
        usuarioJson =
            (data['data'] as Map<String, dynamic>)['usuario'] as Map<String, dynamic>;
      } else {
        // Si tu back devuelve el usuario directamente sin "usuario":
        if (data['idUsuario'] != null && data['email'] != null) {
          usuarioJson = data;
        }
      }

      if (usuarioJson == null) {
        throw Exception('Formato de respuesta inesperado: no se encontró "usuario".');
      }

      final rolStr = usuarioJson['rol'] as String? ?? 'estudiante';

      late final Usuario usuario;
      if (rolStr == 'admin') {
        usuario = AdministradorSistema(
          idUsuario: usuarioJson['idUsuario'],
          email: usuarioJson['email'],
          passwordHash: '',
          fechaCreacion: DateTime.parse(usuarioJson['fechaCreacion']),
          estado: _estadoFromString(usuarioJson['estado']),
        );
      } else {
        usuario = Estudiante(
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

      // 🔥 Guardar usuario + token en AuthService
      AuthService().setSession(
        usuario: usuario,
        accessToken: token,
      );

      print('Usuario logueado: ${usuario.email}');
      print('Token en AuthService al final de login: ${AuthService().token}');

      return usuario;
    }

    if (resp.statusCode == 400 || resp.statusCode == 401) {
      // credenciales inválidas
      return null;
    }

    throw Exception(
      'Error al iniciar sesión: [${resp.statusCode}] ${resp.body}',
    );
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
      'Error al registrar usuario: [${resp.statusCode}] ${resp.body}',
    );
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
