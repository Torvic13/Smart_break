// lib/dao/espacio_dao.dart
import '../models/espacio.dart';

abstract class EspacioDAO {
  Future<Espacio?> obtenerPorId(String id);
  Future<List<Espacio>> obtenerTodos();
  Future<List<Espacio>> obtenerPorTipo(String tipo);
  Future<List<Espacio>> obtenerPorNivelOcupacion(String nivel);
  Future<List<Espacio>> filtrarPorCaracteristicas(Map<String, String> filtros);

  /// Ahora el backend devuelve el espacio creado
  Future<Espacio> crear(Espacio espacio);

  /// Y también devuelve el espacio actualizado
  Future<Espacio> actualizar(Espacio espacio);

  Future<void> eliminar(String id);
}
