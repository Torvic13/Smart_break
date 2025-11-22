// lib/models/espacio.dart
import 'ubicacion.dart';
import 'calificacion.dart';
import 'caracteristica_espacio.dart';

class Espacio {
  final String idEspacio;
  final String nombre;
  final String tipo;
  final String descripcion;

  /// Capacidad aproximada del espacio (personas)
  final int capacidad;

  /// Nivel de ocupación actual: 'vacio', 'bajo', 'medio', 'alto', 'lleno'
  final String nivelOcupacion;

  /// Información de ubicación (edificio, piso, coordenadas)
  final Ubicacion ubicacion;

  /// Promedio de calificaciones (0.0 – 5.0)
  final double promedioCalificacion;

  /// IDs de categorías asociadas a este espacio
  final List<String> categoriaIds;

  /// Calificaciones individuales asociadas al espacio
  final List<Calificacion> calificaciones;

  /// Características adicionales (ruido, enchufes, etc.)
  final List<CaracteristicaEspacio> caracteristicas;

  Espacio({
    required this.idEspacio,
    required this.nombre,
    required this.tipo,
    required this.descripcion,
    required this.capacidad,
    required this.nivelOcupacion,
    required this.ubicacion,
    this.promedioCalificacion = 0.0,
    List<String>? categoriaIds,
    List<Calificacion>? calificaciones,
    List<CaracteristicaEspacio>? caracteristicas,
  })  : categoriaIds = categoriaIds ?? const [],
        calificaciones = calificaciones ?? const [],
        caracteristicas = caracteristicas ?? const [];

  factory Espacio.fromJson(Map<String, dynamic> json) {
    // Ubicación: puede venir anidada o con campos planos
    Ubicacion ubicacion;
    if (json['ubicacion'] is Map) {
      ubicacion = Ubicacion.fromJson(json['ubicacion'] as Map<String, dynamic>);
    } else {
      ubicacion = Ubicacion(
        latitud: (json['latitud'] ?? 0).toDouble(),
        longitud: (json['longitud'] ?? 0).toDouble(),
        edificio: json['edificio']?.toString(),
        piso: json['piso']?.toString(),
      );
    }

    // Categorías
    final rawCategorias = (json['categoriaIds'] as List?) ?? [];
    final categoriaIds =
        rawCategorias.map((e) => e.toString()).toList(growable: false);

    // Calificaciones
    final rawCalificaciones = (json['calificaciones'] as List?) ?? [];
    final calificaciones = rawCalificaciones
        .whereType<Map<String, dynamic>>()
        .map((e) => Calificacion.fromJson(e))
        .toList(growable: false);

    // Características
    final rawCaracts = (json['caracteristicas'] as List?) ?? [];
    final caracteristicas = rawCaracts
        .whereType<Map<String, dynamic>>()
        .map((e) => CaracteristicaEspacio.fromJson(e))
        .toList(growable: false);

    return Espacio(
      idEspacio: (json['idEspacio'] ?? json['_id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      capacidad: json['capacidad'] is int
          ? json['capacidad'] as int
          : int.tryParse(json['capacidad']?.toString() ?? '') ?? 0,
      nivelOcupacion: (json['nivelOcupacion'] ?? 'vacio').toString(),
      ubicacion: ubicacion,
      promedioCalificacion:
          (json['promedioCalificacion'] ?? 0).toDouble(),
      categoriaIds: categoriaIds,
      calificaciones: calificaciones,
      caracteristicas: caracteristicas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEspacio': idEspacio,
      'nombre': nombre,
      'tipo': tipo,
      'descripcion': descripcion,
      'capacidad': capacidad,
      'nivelOcupacion': nivelOcupacion,
      'ubicacion': ubicacion.toJson(),
      'promedioCalificacion': promedioCalificacion,
      'categoriaIds': categoriaIds,
      'calificaciones': calificaciones.map((c) => c.toJson()).toList(),
      'caracteristicas': caracteristicas.map((c) => c.toJson()).toList(),
    };
  }
}
