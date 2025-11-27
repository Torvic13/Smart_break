import '../models/espacio.dart';

abstract class EspacioDAO {
  Future<List<Espacio>> obtenerTodos();
  Future<Espacio?> obtenerPorId(String id);
  Future<List<Espacio>> obtenerPorTipo(String tipo);
  Future<List<Espacio>> obtenerPorNivelOcupacion(String nivel);
  Future<List<Espacio>> filtrarPorCaracteristicas(Map<String, String> filtros);

  Future<void> crear(Espacio espacio);
  Future<void> actualizar(Espacio espacio);
  Future<void> eliminar(String id);

  // 🔹 NUEVOS MÉTODOS
  Future<Espacio> ocuparEspacio(String idEspacio);
  Future<Espacio> liberarEspacio(String idEspacio);
  Future<void> resetOcupacionGlobal();
}