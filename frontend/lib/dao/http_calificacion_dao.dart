import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/calificacion.dart';
import 'calificacion_dao.dart';
import 'auth_service.dart';

class HttpCalificacionDAO implements CalificacionDAO {
  final String baseUrl;

  HttpCalificacionDAO({required this.baseUrl});

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers({bool auth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = AuthService().token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Calificacion _fromJson(Map<String, dynamic> json) {
    return Calificacion.fromJson(json);
  }

  @override
  Future<Calificacion?> obtenerPorId(String id) async {
    throw UnimplementedError('obtenerPorId aún no se usa en la app');
  }

  @override
  Future<List<Calificacion>> obtenerPorEspacio(String espacioId) async {
    // GET /api/v1/espacios/:idEspacio/calificaciones
    final resp = await http.get(
      _uri('/espacios/$espacioId/calificaciones'),
      headers: _headers(auth: true),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener calificaciones del espacio '
        '(${resp.statusCode}): ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    final list = decoded is List
        ? decoded
        : (decoded['calificaciones'] as List? ?? []);

    return list
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Calificacion>> obtenerPorUsuario(String usuarioId) async {
    throw UnimplementedError('obtenerPorUsuario aún no se usa en la app');
  }

  @override
  Future<List<Calificacion>> obtenerTodas() async {
    // GET /api/v1/calificaciones  (solo admin)
    final resp = await http.get(
      _uri('/calificaciones'),
      headers: _headers(auth: true),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener todas las calificaciones '
        '(${resp.statusCode}): ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    final list = decoded is List
        ? decoded
        : (decoded['calificaciones'] as List? ?? []);

    return list
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> crear(Calificacion calificacion) async {
    if (calificacion.idEspacio == null) {
      throw Exception('idEspacio requerido para crear calificación');
    }

    final body = {
      'puntuacion': calificacion.puntuacion,
      'comentario': calificacion.comentario,
    };

    final resp = await http.post(
      _uri('/espacios/${calificacion.idEspacio}/calificaciones'),
      headers: _headers(auth: true),
      body: jsonEncode(body),
    );

    if (resp.statusCode != 201) {
      throw Exception(
        'Error al crear calificación '
        '(${resp.statusCode}): ${resp.body}',
      );
    }
  }

  @override
  Future<void> actualizar(Calificacion calificacion) async {
    final body = {
      'puntuacion': calificacion.puntuacion,
      'comentario': calificacion.comentario,
    };

    final resp = await http.put(
      _uri('/calificaciones/${calificacion.idCalificacion}'),
      headers: _headers(auth: true),
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al actualizar calificación '
        '(${resp.statusCode}): ${resp.body}',
      );
    }
  }

  @override
  Future<void> eliminar(String id) async {
    final resp = await http.delete(
      _uri('/calificaciones/$id'),
      headers: _headers(auth: true),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al eliminar calificación '
        '(${resp.statusCode}): ${resp.body}',
      );
    }
  }
}
