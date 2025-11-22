import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_dao.dart';
import '../models/usuario.dart';
import '../models/estudiante.dart';
import '../models/administrador_sistema.dart';

class HttpAuthDAO implements AuthDAO {
  final String baseUrl;
  String? _lastToken;

  HttpAuthDAO({required this.baseUrl});

  @override
  String? getToken() => _lastToken;

  // Función para convertir string a EstadoUsuario
  EstadoUsuario _parseEstadoUsuario(String estadoStr) {
    switch (estadoStr.toLowerCase()) {
      case 'activo':
        return EstadoUsuario.activo;
      case 'inactivo':
        return EstadoUsuario.inactivo;
      case 'suspendido':
        return EstadoUsuario.suspendido;
      default:
        return EstadoUsuario.activo;
    }
  }

  // Función para convertir string a RolUsuario
  RolUsuario _parseRolUsuario(String rolStr) {
    switch (rolStr.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return RolUsuario.admin;
      case 'estudiante':
        return RolUsuario.estudiante;
      default:
        return RolUsuario.estudiante;
    }
  }

  @override
  Future<Usuario?> iniciarSesion({
    required String email,
    required String pass,
  }) async {
    try {
      final url = '$baseUrl/api/v1/auth/login';
      print('🔐 [DEBUG] URL de login: $url');
      print('🔐 [DEBUG] Email: $email');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': pass,
        }),
      );

      print('🔐 [DEBUG] Respuesta del servidor: ${response.statusCode}');
      print('🔐 [DEBUG] Body de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // 👇 GUARDAR EL TOKEN DEL BACKEND
        _lastToken = data['accessToken'];
        print('🔐 [DEBUG] Token guardado: ${_lastToken?.substring(0, 20)}...');

        final Map<String, dynamic> usuarioData = data['usuario'];
        
        // Parsear estado y rol
        final estado = _parseEstadoUsuario(usuarioData['estado']?.toString() ?? 'activo');
        final rol = _parseRolUsuario(usuarioData['rol']?.toString() ?? 'estudiante');
        
        // Crear el usuario según el rol
        if (rol == RolUsuario.estudiante) {
          return Estudiante(
            idUsuario: usuarioData['idUsuario'] ?? '',
            email: usuarioData['email'] ?? '',
            passwordHash: '', // No guardamos el hash
            fechaCreacion: DateTime.parse(usuarioData['fechaCreacion'] ?? DateTime.now().toString()),
            estado: estado,
            codigoAlumno: usuarioData['codigoAlumno'] ?? '',
            nombreCompleto: usuarioData['nombreCompleto'] ?? '',
            ubicacionCompartida: usuarioData['ubicacionCompartida'] ?? false,
            carrera: usuarioData['carrera'] ?? '',
          );
        } else if (rol == RolUsuario.admin) {
          return AdministradorSistema(
            idUsuario: usuarioData['idUsuario'] ?? '',
            email: usuarioData['email'] ?? '',
            passwordHash: '',
            fechaCreacion: DateTime.parse(usuarioData['fechaCreacion'] ?? DateTime.now().toString()),
            estado: estado,
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('🔐 [DEBUG] Error en login: $e');
      rethrow;
    }
    return null;
  }

  @override
  Future<Usuario> crearCuenta(Map<String, dynamic> datos) async {
    try {
      final url = '$baseUrl/api/v1/auth/register';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        _lastToken = data['accessToken'];
        
        final Map<String, dynamic> usuarioData = data['usuario'];
        
        return Estudiante(
          idUsuario: usuarioData['idUsuario'] ?? '',
          email: usuarioData['email'] ?? '',
          passwordHash: '',
          fechaCreacion: DateTime.parse(usuarioData['fechaCreacion'] ?? DateTime.now().toString()),
          estado: _parseEstadoUsuario(usuarioData['estado']?.toString() ?? 'activo'),
          codigoAlumno: usuarioData['codigoAlumno'] ?? '',
          nombreCompleto: usuarioData['nombreCompleto'] ?? '',
          ubicacionCompartida: usuarioData['ubicacionCompartida'] ?? false,
          carrera: usuarioData['carrera'] ?? '',
        );
      } else {
        throw Exception('Error al crear cuenta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }
}