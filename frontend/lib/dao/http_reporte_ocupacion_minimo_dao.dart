// lib/dao/http_reporte_ocupacion_minimo_dao.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ReporteOcupacionMinimoDAO {
  Future<bool> reportar(String espacioId, String nivelOcupacion);
}

class HttpReporteOcupacionMinimoDAO implements ReporteOcupacionMinimoDAO {
  final String baseUrl;

  HttpReporteOcupacionMinimoDAO({required this.baseUrl});

  @override
  Future<bool> reportar(String espacioId, String nivelOcupacion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reportes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'espacioId': espacioId,
          'nivelOcupacion': nivelOcupacion,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error al reportar: $e");
      return false;
    }
  }
}