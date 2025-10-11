import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/espacio.dart';
import '../models/ubicacion.dart';
import '../models/caracteristica_espacio.dart';
import 'espacio_dao.dart';
import 'database_provider.dart';

class SqliteEspacioDAO implements EspacioDAO {
  final Future<Database> _dbFuture =
      DatabaseProvider.instance.database as Future<Database>;

  SqliteEspacioDAO();

  Map<String, dynamic> _toMap(Espacio e) {
    return {
      'idEspacio': e.idEspacio,
      'nombre': e.nombre,
      'tipo': e.tipo,
      'nivelOcupacion': e.nivelOcupacion.name,
      'promedioCalificacion': e.promedioCalificacion,
      'ubicacion': jsonEncode(e.ubicacion.toJson()),
      'caracteristicas': jsonEncode(
        e.caracteristicas.map((c) => c.toJson()).toList(),
      ),
    };
  }

  Espacio _fromMap(Map<String, dynamic> m) {
    final ubicacionJson = jsonDecode(m['ubicacion']);
    final caracteristicasJson = jsonDecode(m['caracteristicas']) as List;

    return Espacio(
      idEspacio: m['idEspacio'],
      nombre: m['nombre'],
      tipo: m['tipo'],
      nivelOcupacion: NivelOcupacion.values.firstWhere(
        (e) => e.name == m['nivelOcupacion'],
        orElse: () => NivelOcupacion.medio,
      ),
      promedioCalificacion: (m['promedioCalificacion'] as num).toDouble(),
      ubicacion: Ubicacion.fromJson(ubicacionJson),
      caracteristicas: caracteristicasJson
          .map((c) => CaracteristicaEspacio.fromJson(c))
          .toList(),
    );
  }

  @override
  Future<void> crear(Espacio espacio) async {
    final db = await _dbFuture;
    await db.insert(
      'espacios',
      _toMap(espacio),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> actualizar(Espacio espacio) async {
    final db = await _dbFuture;
    await db.update(
      'espacios',
      _toMap(espacio),
      where: 'idEspacio = ?',
      whereArgs: [espacio.idEspacio],
    );
  }

  @override
  Future<void> eliminar(String id) async {
    final db = await _dbFuture;
    await db.delete('espacios', where: 'idEspacio = ?', whereArgs: [id]);
  }

  @override
  Future<Espacio?> obtenerPorId(String id) async {
    final db = await _dbFuture;
    final result = await db.query(
      'espacios',
      where: 'idEspacio = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return _fromMap(result.first);
  }

  @override
  Future<List<Espacio>> obtenerTodos() async {
    final db = await _dbFuture;
    final result = await db.query('espacios');
    return result.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<List<Espacio>> obtenerPorTipo(String tipo) async {
    final db = await _dbFuture;
    final result = await db.query(
      'espacios',
      where: 'tipo LIKE ?',
      whereArgs: ['%$tipo%'],
    );
    return result.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<List<Espacio>> obtenerPorNivelOcupacion(String nivel) async {
    final db = await _dbFuture;
    final result = await db.query(
      'espacios',
      where: 'nivelOcupacion = ?',
      whereArgs: [nivel],
    );
    return result.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<List<Espacio>> filtrarPorCaracteristicas(
    Map<String, String> filtros,
  ) async {
    final espacios = await obtenerTodos();
    return espacios.where((espacio) {
      return filtros.entries.every((filtro) {
        return espacio.caracteristicas.any(
          (caracteristica) =>
              caracteristica.nombre.toLowerCase() == filtro.key.toLowerCase() &&
              caracteristica.valor.toLowerCase().contains(
                filtro.value.toLowerCase(),
              ),
        );
      });
    }).toList();
  }
}

/* Removed custom Database class to avoid shadowing sqflite's Database */
