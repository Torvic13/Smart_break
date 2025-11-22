import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calificacion.dart';
import 'calificacion_dao.dart';

class HttpCalificacionDAO implements CalificacionDAO {
  final String baseUrl;

  HttpCalificacionDAO({required this.baseUrl});

  @override
  Future<Calificacion> crearCalificacion({
    required String idEspacio,
    required double puntuacion,
    required String comentario,
    required String authToken,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/calificaciones');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'idEspacio': idEspacio,
        'puntuacion': puntuacion,
        'comentario': comentario,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Calificacion.fromJson(data['calificacion']);
    } else {
      throw Exception('Error al crear calificación: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future<List<Calificacion>> obtenerCalificacionesPorEspacio({
    required String idEspacio,
    required String authToken,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/calificaciones/espacios/$idEspacio');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Calificacion.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener calificaciones: ${response.statusCode}');
    }
  }

  @override
  Future<List<Calificacion>> obtenerCalificacionesPorUsuario({
    required String idUsuario,
    required String authToken,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/calificaciones/usuarios/$idUsuario');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Calificacion.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener calificaciones: ${response.statusCode}');
    }
  }

  // 👇 IMPLEMENTAR MÉTODOS NUEVOS
  @override
  Future<void> eliminarCalificacion({
    required String idCalificacion,
    required String authToken,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/calificaciones/$idCalificacion');

    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar calificación: ${response.statusCode}');
    }
  }

  @override
  Future<Calificacion> actualizarCalificacion({
    required String idCalificacion,
    required double puntuacion,
    required String comentario,
    required String authToken,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/calificaciones/$idCalificacion');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'puntuacion': puntuacion,
        'comentario': comentario,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Calificacion.fromJson(data['calificacion']);
    } else {
      throw Exception('Error al actualizar calificación: ${response.statusCode} ${response.body}');
    }
  }
}