// lib/dao/reporte_ocupacion_dao.dart
import '../models/reporte_ocupacion.dart';

abstract class ReporteOcupacionDAO {
  // Métodos CRUD completos (opcionales por ahora)
  Future<ReporteOcupacion?> obtenerPorId(String id) async => null;
  Future<List<ReporteOcupacion>> obtenerPorEspacio(String espacioId) async => [];
  Future<List<ReporteOcupacion>> obtenerPorUsuario(String usuarioId) async => [];
  Future<List<ReporteOcupacion>> obtenerTodos() async => [];
  Future<void> crear(ReporteOcupacion reporte) async {}
  Future<void> actualizar(ReporteOcupacion reporte) async {}
  Future<void> eliminar(String id) async {}

  // ESTE ES EL ÚNICO QUE NECESITAMOS AHORA → OBLIGATORIO
  Future<bool> reportar(String espacioId, String nivelOcupacion);
}