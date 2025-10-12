import '../models/espacio.dart';
import '../models/ubicacion.dart';
import '../models/caracteristica_espacio.dart';
import 'espacio_dao.dart';

class MockEspacioDAO implements EspacioDAO {
  static final List<Espacio> _espacios = [
    Espacio(
      idEspacio: '1',
      nombre: 'Biblioteca Central ULima',
      tipo: 'Biblioteca',
      nivelOcupacion: NivelOcupacion.medio,
      promedioCalificacion: 4.5,
      ubicacion: Ubicacion(
        idUbicacion: '1',
        latitud: -12.0464,
        longitud: -77.0428,
        piso: 1,
      ),
      caracteristicas: [
        CaracteristicaEspacio(
          idCaracteristica: '1',
          nombre: 'WiFi',
          valor: 'Gratuito',
          tipoFiltro: 'servicio',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '2',
          nombre: 'Silencio',
          valor: 'Alto',
          tipoFiltro: 'ambiente',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '3',
          nombre: 'Aire Acondicionado',
          valor: 'Disponible',
          tipoFiltro: 'servicio',
        ),
      ],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '2',
      nombre: 'Cafetería Estudiantil',
      tipo: 'Cafetería',
      nivelOcupacion: NivelOcupacion.alto,
      promedioCalificacion: 3.8,
      ubicacion: Ubicacion(
        idUbicacion: '2',
        latitud: -12.0458,
        longitud: -77.0432,
        piso: 0,
      ),
      caracteristicas: [
        CaracteristicaEspacio(
          idCaracteristica: '4',
          nombre: 'Comida',
          valor: 'Disponible',
          tipoFiltro: 'servicio',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '5',
          nombre: 'Ruido',
          valor: 'Medio',
          tipoFiltro: 'ambiente',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '6',
          nombre: 'Precios',
          valor: 'Económicos',
          tipoFiltro: 'servicio',
        ),
      ],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '3',
      nombre: 'Jardín Central ULima',
      tipo: 'Exterior',
      nivelOcupacion: NivelOcupacion.bajo,
      promedioCalificacion: 4.7,
      ubicacion: Ubicacion(
        idUbicacion: '3',
        latitud: -12.0460,
        longitud: -77.0425,
        piso: 0,
      ),
      caracteristicas: [
        CaracteristicaEspacio(
          idCaracteristica: '7',
          nombre: 'Naturaleza',
          valor: 'Alto',
          tipoFiltro: 'ambiente',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '8',
          nombre: 'Silencio',
          valor: 'Alto',
          tipoFiltro: 'ambiente',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '9',
          nombre: 'Sombras',
          valor: 'Disponibles',
          tipoFiltro: 'servicio',
        ),
      ],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '4',
      nombre: 'Sala de Estudio 24/7',
      tipo: 'Sala de Estudio',
      nivelOcupacion: NivelOcupacion.vacio,
      promedioCalificacion: 4.2,
      ubicacion: Ubicacion(
        idUbicacion: '4',
        latitud: -12.0468,
        longitud: -77.0435,
        piso: 2,
      ),
      caracteristicas: [
        CaracteristicaEspacio(
          idCaracteristica: '10',
          nombre: 'Horario',
          valor: '24/7',
          tipoFiltro: 'servicio',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '11',
          nombre: 'Silencio',
          valor: 'Alto',
          tipoFiltro: 'ambiente',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '12',
          nombre: 'Computadoras',
          valor: 'Disponibles',
          tipoFiltro: 'servicio',
        ),
      ],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '5',
      nombre: 'Patio de Comidas ULima',
      tipo: 'Comedor',
      nivelOcupacion: NivelOcupacion.lleno,
      promedioCalificacion: 3.5,
      ubicacion: Ubicacion(
        idUbicacion: '5',
        latitud: -12.0455,
        longitud: -77.0430,
        piso: 0,
      ),
      caracteristicas: [
        CaracteristicaEspacio(
          idCaracteristica: '13',
          nombre: 'Comida',
          valor: 'Variada',
          tipoFiltro: 'servicio',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '14',
          nombre: 'Ruido',
          valor: 'Alto',
          tipoFiltro: 'ambiente',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '15',
          nombre: 'Horario',
          valor: 'Amplio',
          tipoFiltro: 'servicio',
        ),
      ],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '6',
      nombre: 'Laboratorio de Computación',
      tipo: 'Laboratorio',
      nivelOcupacion: NivelOcupacion.medio,
      promedioCalificacion: 4.0,
      ubicacion: Ubicacion(
        idUbicacion: '6',
        latitud: -12.0462,
        longitud: -77.0438,
        piso: 3,
      ),
      caracteristicas: [
        CaracteristicaEspacio(
          idCaracteristica: '16',
          nombre: 'Computadoras',
          valor: 'Modernas',
          tipoFiltro: 'servicio',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '17',
          nombre: 'Internet',
          valor: 'Rápido',
          tipoFiltro: 'servicio',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '18',
          nombre: 'Aire Acondicionado',
          valor: 'Disponible',
          tipoFiltro: 'servicio',
        ),
      ],
      categoriaIds: const [],
    ),
    Espacio(
      idEspacio: '7',
      nombre: 'Auditorio Principal',
      tipo: 'Auditorio',
      nivelOcupacion: NivelOcupacion.bajo,
      promedioCalificacion: 4.3,
      ubicacion: Ubicacion(
        idUbicacion: '7',
        latitud: -12.0450,
        longitud: -77.0420,
        piso: 1,
      ),
      caracteristicas: [
        CaracteristicaEspacio(
          idCaracteristica: '19',
          nombre: 'Capacidad',
          valor: 'Grande',
          tipoFiltro: 'servicio',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '20',
          nombre: 'Silencio',
          valor: 'Alto',
          tipoFiltro: 'ambiente',
        ),
        CaracteristicaEspacio(
          idCaracteristica: '21',
          nombre: 'Proyección',
          valor: 'Disponible',
          tipoFiltro: 'servicio',
        ),
      ],
      categoriaIds: const [],
    ),
  ];

  @override
  Future<Espacio?> obtenerPorId(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _espacios.firstWhere((e) => e.idEspacio == id);
    } catch (e) {
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
    return _espacios.where((e) => e.tipo.toLowerCase().contains(tipo.toLowerCase())).toList();
  }

  @override
  Future<List<Espacio>> obtenerPorNivelOcupacion(String nivel) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _espacios.where((e) => e.nivelOcupacion.name == nivel.toLowerCase()).toList();
  }

  @override
  Future<List<Espacio>> filtrarPorCaracteristicas(Map<String, String> filtros) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _espacios.where((espacio) {
      return filtros.entries.every((filtro) {
        return espacio.caracteristicas.any((caracteristica) =>
            caracteristica.nombre.toLowerCase() == filtro.key.toLowerCase() &&
            caracteristica.valor.toLowerCase().contains(filtro.value.toLowerCase()));
      });
    }).toList();
  }

  @override
  Future<void> crear(Espacio espacio) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _espacios.add(espacio);
  }

  @override
  Future<void> actualizar(Espacio espacio) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _espacios.indexWhere((e) => e.idEspacio == espacio.idEspacio);
    if (index != -1) {
      _espacios[index] = espacio;
    }
  }

  @override
  Future<void> eliminar(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _espacios.removeWhere((e) => e.idEspacio == id);
  }
}
