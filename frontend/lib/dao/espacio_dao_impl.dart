// lib/dao/espacio_dao_impl.dart
import 'espacio_dao.dart';
import '../models/espacio.dart';

/// Implementación local de EspacioDAO (no se usa en producción).
/// Si en algún momento se llega a usar, lanzará UnimplementedError.
class EspacioDAOImpl extends EspacioDAO {
  @override
  Future<Espacio?> obtenerPorId(String id) async {
    throw UnimplementedError('EspacioDAOImpl.obtenerPorId no implementado');
  }

  @override
  Future<List<Espacio>> obtenerTodos() async {
    throw UnimplementedError('EspacioDAOImpl.obtenerTodos no implementado');
  }

  @override
  Future<List<Espacio>> obtenerPorTipo(String tipo) async {
    throw UnimplementedError('EspacioDAOImpl.obtenerPorTipo no implementado');
  }

  @override
  Future<List<Espacio>> obtenerPorNivelOcupacion(String nivel) async {
    throw UnimplementedError(
        'EspacioDAOImpl.obtenerPorNivelOcupacion no implementado');
  }

  @override
  Future<List<Espacio>> filtrarPorCaracteristicas(
      Map<String, String> filtros) async {
    throw UnimplementedError(
        'EspacioDAOImpl.filtrarPorCaracteristicas no implementado');
  }

  @override
  Future<Espacio> crear(Espacio espacio) async {
    throw UnimplementedError('EspacioDAOImpl.crear no implementado');
  }

  @override
  Future<Espacio> actualizar(Espacio espacio) async {
    throw UnimplementedError('EspacioDAOImpl.actualizar no implementado');
  }

  @override
  Future<void> eliminar(String id) async {
    throw UnimplementedError('EspacioDAOImpl.eliminar no implementado');
  }
}
