// lib/services/incidencia_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/incidencia.dart';

class IncidenciaService {
  // Usar 10.0.2.2 en emulador de Android para conectar a localhost de la máquina
  static const String baseUrl = 'http://10.0.2.2:4000/api/v1';

  // GET - Obtener incidencias no resueltas de un espacio
  static Future<List<Incidencia>> obtenerIncidenciasEspacio(
    String idEspacio,
    String token,
  ) async {
    try {
      print('📡 GET /incidencias/espacio/$idEspacio');
      final response = await http.get(
        Uri.parse('$baseUrl/incidencias/espacio/$idEspacio'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Status: ${response.statusCode}');
      print('📋 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Parseado ${data.length} incidencias');
        final result = data.map((inc) {
          print('🔍 Procesando: $inc');
          return Incidencia.fromJson(inc);
        }).toList();
        return result;
      } else if (response.statusCode == 404) {
        print('⚠️ Espacio no encontrado (404)');
        return []; // Espacio no encontrado
      } else {
        throw Exception('Error al obtener incidencias: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      throw Exception('Error en obtenerIncidenciasEspacio: $e');
    }
  }

  // POST - Crear nueva incidencia
  static Future<Incidencia> crearIncidencia(
    String idEspacio,
    String tipoIncidencia,
    String descripcion,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/incidencias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idEspacio': idEspacio,
          'tipoIncidencia': tipoIncidencia,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Incidencia.fromJson(data['incidencia']);
      } else if (response.statusCode == 401) {
        throw Exception('Usuario no autenticado');
      } else if (response.statusCode == 404) {
        throw Exception('Espacio no encontrado');
      } else {
        throw Exception('Error al crear incidencia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en crearIncidencia: $e');
    }
  }

  // GET - Obtener todas las incidencias (solo admin)
  static Future<List<Incidencia>> listarTodasIncidencias(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incidencias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((inc) => Incidencia.fromJson(inc)).toList();
      } else {
        throw Exception('Error al listar incidencias: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en listarTodasIncidencias: $e');
    }
  }

  // PATCH - Resolver una incidencia
  static Future<Incidencia> resolverIncidencia(
    String idIncidencia,
    String? notas,
    String token,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/incidencias/$idIncidencia/resolver'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (notas != null) 'notas': notas,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Incidencia.fromJson(data['incidencia']);
      } else if (response.statusCode == 404) {
        throw Exception('Incidencia no encontrada');
      } else {
        throw Exception('Error al resolver incidencia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en resolverIncidencia: $e');
    }
  }

  // DELETE - Eliminar una incidencia
  static Future<void> eliminarIncidencia(
    String idIncidencia,
    String token,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/incidencias/$idIncidencia'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar incidencia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en eliminarIncidencia: $e');
    }
  }

  // GET - Obtener incidencias reportadas por un usuario
  static Future<List<Incidencia>> obtenerIncidenciasUsuario(
    String idUsuario,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incidencias/usuario/$idUsuario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((inc) => Incidencia.fromJson(inc)).toList();
      } else {
        throw Exception('Error al obtener incidencias del usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en obtenerIncidenciasUsuario: $e');
    }
  }
}
