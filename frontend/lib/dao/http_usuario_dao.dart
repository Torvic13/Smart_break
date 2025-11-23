import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estudiante.dart';
import '../models/usuario.dart';
import 'usuario_dao.dart';

class HttpUsuarioDAO implements UsuarioDAO {
  final String baseUrl;

  HttpUsuarioDAO({this.baseUrl = 'http://10.0.2.2:4000/api/v1'});

  @override
  Future<Usuario?> obtenerPorId(String id) async {
    final uri = Uri.parse('$baseUrl/usuarios');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final List<dynamic> usuarios = jsonDecode(resp.body);
      final usuarioJson = usuarios.firstWhere(
        (u) => u['idUsuario'] == id,
        orElse: () => null,
      );

      if (usuarioJson == null) return null;

      return _parseUsuario(usuarioJson);
    }

    throw Exception('Error al obtener usuario: ${resp.statusCode}');
  }

  @override
  Future<Usuario?> obtenerPorEmail(String email) async {
    final uri = Uri.parse('$baseUrl/usuarios');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final List<dynamic> usuarios = jsonDecode(resp.body);
      final usuarioJson = usuarios.firstWhere(
        (u) => u['email'] == email,
        orElse: () => null,
      );

      if (usuarioJson == null) return null;

      return _parseUsuario(usuarioJson);
    }

    throw Exception('Error al obtener usuario: ${resp.statusCode}');
  }

  @override
  Future<List<Usuario>> obtenerTodos() async {
    final uri = Uri.parse('$baseUrl/usuarios');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final List<dynamic> usuarios = jsonDecode(resp.body);
      return usuarios.map((u) => _parseUsuario(u)).toList();
    }

    throw Exception('Error al listar usuarios: ${resp.statusCode}');
  }

  @override
  Future<void> crear(Usuario usuario) async {
    throw UnimplementedError('Usar AuthDAO para crear usuarios');
  }

  @override
  Future<void> actualizar(Usuario usuario) async {
    throw UnimplementedError('Actualización no implementada');
  }

  @override
  Future<void> eliminar(String id) async {
    throw UnimplementedError('Eliminación no implementada');
  }

  // Métodos específicos para amigos
  Future<Estudiante?> buscarPorCodigo(String codigoAlumno) async {
    final uri = Uri.parse('$baseUrl/usuarios/buscar/$codigoAlumno');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final usuarioJson = data['usuario'];
      return _parseUsuario(usuarioJson) as Estudiante;
    }

    if (resp.statusCode == 404) {
      return null;
    }

    throw Exception('Error al buscar usuario: ${resp.statusCode}');
  }

  Future<void> agregarAmigo(String idUsuario, String amigoId) async {
    final uri = Uri.parse('$baseUrl/usuarios/$idUsuario/amigos');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amigoId': amigoId}),
    );

    if (resp.statusCode == 200) {
      return;
    }

    if (resp.statusCode == 400) {
      final data = jsonDecode(resp.body);
      throw Exception(data['message'] ?? 'Error al agregar amigo');
    }

    throw Exception('Error al agregar amigo: ${resp.statusCode}');
  }

  Future<List<Estudiante>> obtenerAmigos(String idUsuario) async {
    final uri = Uri.parse('$baseUrl/usuarios/$idUsuario/amigos');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final List<dynamic> amigos = data['amigos'];
      return amigos.map((a) => _parseUsuario(a) as Estudiante).toList();
    }

    throw Exception('Error al obtener amigos: ${resp.statusCode}');
  }

  // Método privado para parsear usuarios
  Usuario _parseUsuario(Map<String, dynamic> json) {
    final rolStr = json['rol'] as String? ?? 'estudiante';

    if (rolStr == 'estudiante') {
      return Estudiante(
        idUsuario: json['idUsuario'],
        email: json['email'],
        passwordHash: '',
        fechaCreacion: DateTime.parse(json['fechaCreacion']),
        estado: _estadoFromString(json['estado']),
        codigoAlumno: json['codigoAlumno'] ?? '',
        nombreCompleto: json['nombreCompleto'] ?? '',
        ubicacionCompartida: json['ubicacionCompartida'] as bool? ?? false,
        carrera: json['carrera'] ?? 'No especificada',
        amigosIds: json['amigosIds'] != null
            ? List<String>.from(json['amigosIds'])
            : [],
      );
    }

    return Usuario(
      idUsuario: json['idUsuario'],
      email: json['email'],
      passwordHash: '',
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      estado: _estadoFromString(json['estado']),
      rol: RolUsuario.admin,
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
