// lib/dao/mock_espacio_dao.dart
import '../models/espacio.dart';
import '../models/ubicacion.dart';
import 'espacio_dao.dart';
import '../models/nivel_ocupacion.dart';

class CaracteristicaSimple {
  final String nombre;
  final String valor;

  const CaracteristicaSimple({
    required this.nombre,
    required this.valor,
  });
}

class MockEspacioDAO implements EspacioDAO {
  static final List<Espacio> _espacios = [
    Espacio(
      idEspacio: '1',
      nombre: 'Biblioteca Central ULima',
      tipo: 'Biblioteca',
      descripcion: 'Biblioteca principal del campus ULima',
      capacidad: 120,
      nivelOcupacion: NivelOcupacion.medio.name,
      promedioCalificacion: 4.5,
      ubicacion: Ubicacion(
        latitud: -12.085384,
        longitud: -76.972002,
        piso: '1',
      ),
      caracteristicas: const [],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '2',
      nombre: 'Cafetería Estudiantil',
      tipo: 'Cafetería',
      descripcion: 'Cafetería principal para estudiantes',
      capacidad: 80,
      nivelOcupacion: NivelOcupacion.alto.name,
      promedioCalificacion: 3.8,
      ubicacion: Ubicacion(
        latitud: -12.084125494983718,
        longitud: -76.97080240788367,
        piso: '0',
      ),
      caracteristicas: const [],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '3',
      nombre: 'Jardín Central ULima',
      tipo: 'Exterior',
      descripcion: 'Zona verde del campus',
      capacidad: 200,
      nivelOcupacion: NivelOcupacion.bajo.name,
      promedioCalificacion: 4.7,
      ubicacion: Ubicacion(
        latitud: -12.085493,
        longitud: -76.970593,
        piso: '0',
      ),
      caracteristicas: const [],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '4',
      nombre: 'Sala de Estudio 24/7',
      tipo: 'Sala de Estudio',
      descripcion: 'Sala de estudio disponible 24 horas',
      capacidad: 50,
      nivelOcupacion: NivelOcupacion.vacio.name,
      promedioCalificacion: 4.2,
      ubicacion: Ubicacion(
        latitud: -12.0468,
        longitud: -77.0435,
        piso: '2',
      ),
      caracteristicas: const [],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '5',
      nombre: 'Patio de Comidas ULima',
      tipo: 'Comedor',
      descripcion: 'Zona central de comidas para estudiantes',
      capacidad: 150,
      nivelOcupacion: NivelOcupacion.lleno.name,
      promedioCalificacion: 3.5,
      ubicacion: Ubicacion(
        latitud: -12.085318620825518,
        longitud: -76.97001296236631,
        piso: '0',
      ),
      caracteristicas: const [],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '6',
      nombre: 'Laboratorio de Computación',
      tipo: 'Laboratorio',
      descripcion: 'Laboratorio de computadoras para clases',
      capacidad: 45,
      nivelOcupacion: NivelOcupacion.medio.name,
      promedioCalificacion: 4.0,
      ubicacion: Ubicacion(
        latitud: -12.085413880927165,
        longitud: -76.97162823993533,
        piso: '3',
      ),
      caracteristicas: const [],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '7',
      nombre: 'Auditorio Principal',
      tipo: 'Auditorio',
      descripcion: 'Auditorio grande para eventos y conferencias',
      capacidad: 300,
      nivelOcupacion: NivelOcupacion.bajo.name,
      promedioCalificacion: 4.3,
      ubicacion: Ubicacion(
        latitud: -12.085550816932631,
        longitud: -76.97140706655006,
        piso: '1',
      ),
      caracteristicas: const [],
      categoriaIds: const [],
    ),
  ];

  @override
  Future<Espacio?> obtenerPorId(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _espacios.firstWhere((e) => e.idEspacio == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Espacio>> obtenerTodos() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_espacios);
  }

  @override
  Future<List<Espacio>> obtenerPorTipo(String tipo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _espacios
        .where((e) => e.tipo.toLowerCase().contains(tipo.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Espacio>> obtenerPorNivelOcupacion(String nivel) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _espacios.where((e) => e.nivelOcupacion == nivel).toList();
  }

  @override
  Future<List<Espacio>> filtrarPorCaracteristicas(
      Map<String, String> filtros) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Sin filtros reales por ahora
    return List.from(_espacios);
  }

  @override
  Future<Espacio> crear(Espacio espacio) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _espacios.add(espacio);
    return espacio;
  }

  @override
  Future<Espacio> actualizar(Espacio espacio) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _espacios.indexWhere((e) => e.idEspacio == espacio.idEspacio);
    if (index != -1) {
      _espacios[index] = espacio;
    }
    return espacio;
  }

  @override
  Future<void> eliminar(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _espacios.removeWhere((e) => e.idEspacio == id);
  }
}
