import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/calificacion.dart';
import 'calificacion_dao.dart';
import 'auth_service.dart';

class HttpCalificacionDAO implements CalificacionDAO {
  final String baseUrl;

  HttpCalificacionDAO({required this.baseUrl});

  Uri _uriLista(String espacioId) =>
      Uri.parse('$baseUrl/espacios/$espacioId/calificaciones');

  Uri _uriDetalle(String idCalificacion) =>
      Uri.parse('$baseUrl/calificaciones/$idCalificacion');

  Map<String, String> _headers({bool auth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = AuthService().token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw Exception('No hay token de sesión. Inicia sesión nuevamente.');
      }
    }

    return headers;
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    if (normalized['fecha'] == null && normalized['fechaCreacion'] != null) {
      normalized['fecha'] = normalized['fechaCreacion'];
    }

    normalized['estado'] ??= 'aprobada';

    return normalized;
  }

  @override
  Future<List<Calificacion>> obtenerPorEspacio(String espacioId) async {
    final resp = await http.get(
      _uriLista(espacioId),
      headers: _headers(),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener calificaciones (${resp.statusCode}): ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! List) return [];

    return decoded
        .map<Calificacion>((e) =>
            Calificacion.fromJson(_normalize(e as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<void> crear(Calificacion calificacion) async {
    final espacioId = calificacion.idEspacio;
    if (espacioId == null || espacioId.isEmpty) {
      throw Exception('idEspacio es requerido para crear calificación');
    }

    final resp = await http.post(
      _uriLista(espacioId),
      headers: _headers(auth: true),
      body: jsonEncode({
        'puntuacion': calificacion.puntuacion,
        'comentario': calificacion.comentario,
      }),
    );

    if (resp.statusCode != 201) {
      throw Exception(
        'Error al crear calificación (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  @override
  Future<void> actualizar(Calificacion calificacion) async {
    if (calificacion.idCalificacion.isEmpty) {
      throw Exception('idCalificacion requerido para actualizar');
    }

    final resp = await http.put(
      _uriDetalle(calificacion.idCalificacion),
      headers: _headers(auth: true),
      body: jsonEncode({
        'puntuacion': calificacion.puntuacion,
        'comentario': calificacion.comentario,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al actualizar calificación (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  @override
  Future<void> eliminar(String id) async {
    final resp = await http.delete(
      _uriDetalle(id),
      headers: _headers(auth: true),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al eliminar calificación (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  // No los usas aún
  @override
  Future<Calificacion?> obtenerPorId(String id) {
    throw UnimplementedError('obtenerPorId no está implementado en HTTP DAO');
  }

  @override
  Future<List<Calificacion>> obtenerPorUsuario(String usuarioId) {
    throw UnimplementedError(
        'obtenerPorUsuario no está implementado en HTTP DAO');
  }

  @override
  Future<List<Calificacion>> obtenerTodas() {
    throw UnimplementedError('obtenerTodas no está implementado en HTTP DAO');
  }
}
