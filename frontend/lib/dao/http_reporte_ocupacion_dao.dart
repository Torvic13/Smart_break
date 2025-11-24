import 'dart:convert';
import 'package:http/http.dart' as http;
// Asegúrate de que estas rutas sean correctas
import 'package:smart_break/dao/reporte_ocupacion_dao.dart'; 
import 'package:smart_break/models/reporte_ocupacion.dart';

// Implementación concreta para la persistencia vía HTTP
class HttpReporteOcupacionDAO implements ReporteOcupacionDAO {
  final String baseUrl;

  HttpReporteOcupacionDAO({required this.baseUrl});

  // -----------------------------------------------------------------------
  // IMPLEMENTACIONES REQUERIDAS POR LA INTERFAZ ReporteOcupacionDAO
  // -----------------------------------------------------------------------

  @override
  Future<void> actualizar(ReporteOcupacion reporte) async {
    // Lógica HTTP PUT/PATCH: Aún no implementada, se lanza un error de compilación
    throw UnimplementedError('El método actualizar(ReporteOcupacion) aún no está implementado.');
  }

  @override
  Future<void> crear(ReporteOcupacion reporte) async {
    // Lógica HTTP POST: Aún no implementada, se lanza un error de compilación
    throw UnimplementedError('El método crear(ReporteOcupacion) aún no está implementado.');
  }

  @override
  Future<void> eliminar(String id) async {
    // Lógica HTTP DELETE: Aún no implementada, se lanza un error de compilación
    throw UnimplementedError('El método eliminar(String) aún no está implementado.');
  }

  @override
  Future<List<ReporteOcupacion>> obtenerPorEspacio(String espacioId) async {
    // Lógica HTTP GET: Aún no implementada, se lanza un error de compilación
    throw UnimplementedError('El método obtenerPorEspacio(String) aún no está implementado.');
  }

  @override
  Future<ReporteOcupacion?> obtenerPorId(String id) async {
    // Lógica HTTP GET: Aún no implementada, se lanza un error de compilación
    throw UnimplementedError('El método obtenerPorId(String) aún no está implementado.');
  }

  @override
  Future<List<ReporteOcupacion>> obtenerPorUsuario(String usuarioId) async {
    // Lógica HTTP GET: Aún no implementada, se lanza un error de compilación
    throw UnimplementedError('El método obtenerPorUsuario(String) aún no está implementado.');
  }

  @override
  Future<List<ReporteOcupacion>> obtenerTodos() async {
    // Lógica HTTP GET: Aún no implementada, se lanza un error de compilación
    throw UnimplementedError('El método obtenerTodos() aún no está implementado.');
  }

  // --- MÉTODO EXISTENTE (El que habías implementado previamente) ---
  @override
  Future<bool> reportar(String espacioId, String nivelOcupacion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reportes'),
        headers: {
          'Content-Type': 'application/json',
          // Aquí iría el token de autenticación si estuviera implementado
        },
        body: json.encode({
          'espacioId': espacioId,
          'nivelOcupacion': nivelOcupacion, // "bajo", "medio", "alto", "lleno"
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error al reportar ocupación: $e");
      return false;
    }
  }
}