// lib/dao/http_espacio_dao.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/espacio.dart';
import '../models/caracteristica_espacio.dart';
import '../models/ubicacion.dart';
import 'espacio_dao.dart';

class HttpEspacioDAO implements EspacioDAO {
  final String baseUrl;
  final String? authToken;

  HttpEspacioDAO({
    required this.baseUrl,
    this.authToken,
  });

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  // ---------------------------------------------------------------------------
  // GET /api/v1/espacios
  // ---------------------------------------------------------------------------
  @override
  Future<List<Espacio>> obtenerTodos() async {
    final uri = Uri.parse('$baseUrl/api/v1/espacios');
    final resp = await http.get(uri, headers: _headers);

    if (resp.statusCode != 200) {
      throw Exception('Error al obtener espacios: ${resp.body}');
    }

    final dynamic data = jsonDecode(resp.body);
    if (data is! List) {
      throw Exception('Respuesta inesperada al listar espacios: ${resp.body}');
    }

    return data
        .where((e) => e != null)
        .map<Espacio>((e) => Espacio.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // POST /api/v1/espacios
  // ---------------------------------------------------------------------------
  @override
  Future<Espacio> crear(Espacio espacio) async {
    final uri = Uri.parse('$baseUrl/api/v1/espacios');
    final resp = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(espacio.toJson()),
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Error al crear espacio: ${resp.body}');
    }

    final dynamic data = jsonDecode(resp.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada al crear espacio: ${resp.body}');
    }

    return Espacio.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // PUT /api/v1/espacios/:id
  // ---------------------------------------------------------------------------
  @override
  Future<Espacio> actualizar(Espacio espacio) async {
    final uri = Uri.parse('$baseUrl/api/v1/espacios/${espacio.idEspacio}');
    final resp = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(espacio.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al actualizar espacio: ${resp.body}');
    }

    final dynamic data = jsonDecode(resp.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada al actualizar espacio: ${resp.body}');
    }

    return Espacio.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // DELETE /api/v1/espacios/:id
  // ---------------------------------------------------------------------------
  @override
  Future<void> eliminar(String idEspacio) async {
    final uri = Uri.parse('$baseUrl/api/v1/espacios/$idEspacio');
    final resp = await http.delete(uri, headers: _headers);

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Error al eliminar espacio: ${resp.body}');
    }
  }

  // ---------------------------------------------------------------------------
  // GET /api/v1/espacios/:id
  // ---------------------------------------------------------------------------
  @override
  Future<Espacio?> obtenerPorId(String idEspacio) async {
    final uri = Uri.parse('$baseUrl/api/v1/espacios/$idEspacio');
    final resp = await http.get(uri, headers: _headers);

    if (resp.statusCode == 200) {
      final dynamic data = jsonDecode(resp.body);
      if (data is Map<String, dynamic>) {
        return Espacio.fromJson(data);
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // FILTROS LOCALES
  // ---------------------------------------------------------------------------
  @override
  Future<List<Espacio>> obtenerPorTipo(String tipo) async {
    final todos = await obtenerTodos();
    return todos
        .where((e) => e.tipo.toLowerCase() == tipo.toLowerCase())
        .toList();
  }

  @override
  Future<List<Espacio>> obtenerPorNivelOcupacion(String nivel) async {
    final todos = await obtenerTodos();
    return todos
        .where((e) => e.nivelOcupacion.toLowerCase() == nivel.toLowerCase())
        .toList();
  }

  @override
  Future<List<Espacio>> filtrarPorCaracteristicas(
    Map<String, String> filtros,
  ) async {
    final todos = await obtenerTodos();
    return todos.where((e) => _coincideConFiltros(e, filtros)).toList();
  }

  bool _coincideConFiltros(Espacio espacio, Map<String, String> filtros) {
    if (filtros.isEmpty) return true;

    final List<CaracteristicaEspacio> car = espacio.caracteristicas;

    for (final f in filtros.entries) {
      final ok = car.any((c) => c.nombre == f.key && c.valor == f.value);
      if (!ok) return false;
    }

    return true;
  }
}
