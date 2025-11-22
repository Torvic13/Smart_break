import 'reporte_ocupacion_dao.dart';
import '../models/reporte_ocupacion.dart';

class ReporteOcupacionDAOImpl extends ReporteOcupacionDAO {
  @override
  Future<ReporteOcupacion?> obtenerPorId(String id) async {
    // Tu implementación aquí
    return null;
  }

  @override
  Future<List<ReporteOcupacion>> obtenerPorEspacio(String espacioId) async {
    // Tu implementación aquí
    return [];
  }

  @override
  Future<List<ReporteOcupacion>> obtenerPorUsuario(String usuarioId) async {
    // Tu implementación aquí
    return [];
  }

  @override
  Future<List<ReporteOcupacion>> obtenerTodos() async {
    // Tu implementación aquí
    return [];
  }

  @override
  Future<void> crear(ReporteOcupacion reporte) async {
    // Tu implementación aquí
  }

  @override
  Future<void> actualizar(ReporteOcupacion reporte) async {
    // Tu implementación aquí
  }

  @override
  Future<void> eliminar(String id) async {
    // Tu implementación aquí
  }
}