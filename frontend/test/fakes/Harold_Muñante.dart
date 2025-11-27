import 'package:smart_break/dao/calificacion_dao.dart';
import 'package:smart_break/models/calificacion.dart';

// Lista de datos MOCK inicial para las pruebas
final _mockCalificaciones = [
  Calificacion(
    idCalificacion: 'A1',
    idUsuario: 'user-001',
    codigoAlumno: 'JPEREZ',
    nombreEspacio: 'Sala de Cómputo 1',
    comentario: 'El aire acondicionado no sirve.',
    puntuacion: 1,
    fecha: DateTime.now().subtract(const Duration(days: 2)),
    estado: EstadoCalificacion.aprobada,
  ),
  Calificacion(
    idCalificacion: 'B2',
    idUsuario: 'user-002',
    nombreUsuario: 'María Gómez',
    nombreEspacio: 'Cafetería Central',
    comentario: 'Excelente servicio y comida!',
    puntuacion: 5,
    fecha: DateTime.now().subtract(const Duration(days: 1)),
    estado: EstadoCalificacion.pendiente,
  ),
];

class FakeCalificacionDAO implements CalificacionDAO {
  // Usamos una copia de la lista MOCK para que las eliminaciones solo afecten al test actual.
  final List<Calificacion> _comentarios = List.from(_mockCalificaciones);

  @override
  Future<List<Calificacion>> obtenerTodas() async {
    // Simula un pequeño retraso de red (CP11 - Cargando)
    await Future.delayed(const Duration(milliseconds: 100));
    return _comentarios;
  }

  // Método para simular la obtención con ERROR (CP14)
  Future<List<Calificacion>> obtenerTodasWithError() async {
    await Future.delayed(const Duration(milliseconds: 100));
    throw Exception('Error simulado: 500 Internal Server Error');
  }

  // --- Implementación de los otros métodos del DAO ---
  @override
  Future<void> eliminar(String idCalificacion) async {
    // CP15: Simula la eliminación
    _comentarios.removeWhere((c) => c.idCalificacion == idCalificacion);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> actualizar(Calificacion calificacion) async {}
  @override
  Future<void> crear(Calificacion calificacion) async {}
  @override
  Future<Calificacion?> obtenerPorId(String id) async => null;
  @override
  Future<List<Calificacion>> obtenerPorEspacio(String espacioId) async => [];
  @override
  Future<List<Calificacion>> obtenerPorUsuario(String usuarioId) async => [];
}

// Clase auxiliar para forzar el fallo en el test (necesaria para el CP14)
class _FailingCalificacionDAO extends FakeCalificacionDAO {
  final FakeCalificacionDAO _realDao;
  _FailingCalificacionDAO(this._realDao);
  
  @override
  Future<List<Calificacion>> obtenerTodas() {
    return _realDao.obtenerTodasWithError();
  }
}