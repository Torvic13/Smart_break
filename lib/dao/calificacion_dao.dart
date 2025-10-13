import '../models/calificacion.dart';

abstract class CalificacionDAO {
  Future<Calificacion?> obtenerPorId(String id);
  Future<List<Calificacion>> obtenerPorEspacio(String espacioId);
  Future<List<Calificacion>> obtenerPorUsuario(String usuarioId);
  Future<List<Calificacion>> obtenerTodas();

  Future<void> crear(Calificacion calificacion);
  Future<void> actualizar(Calificacion calificacion);
  Future<void> eliminar(String id);
}