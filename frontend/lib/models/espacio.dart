import 'ubicacion.dart';
import 'caracteristica_espacio.dart';

enum NivelOcupacion { vacio, bajo, medio, alto, lleno }

class Espacio {
  final String idEspacio;
  final String nombre;
  final String tipo;
  final NivelOcupacion nivelOcupacion;
  final double promedioCalificacion;
  final Ubicacion ubicacion;
  final List<CaracteristicaEspacio> caracteristicas;
  final List<String>? _categoriaIds;

  // 🆕 Campos para aforo / ocupación
  final int ocupacionActual;   // ej. 12
  final int? aforoMaximo;      // ej. 50 (puede ser nulo)

  List<String> get categoriaIds => _categoriaIds ?? [];

  Espacio({
    required this.idEspacio,
    required this.nombre,
    required this.tipo,
    required this.nivelOcupacion,
    required this.promedioCalificacion,
    required this.ubicacion,
    required this.caracteristicas,
    List<String>? categoriaIds,
    int? ocupacionActual,
    int? aforoMaximo,
  })  : _categoriaIds = categoriaIds ?? [],
        ocupacionActual = ocupacionActual ?? 0,
        aforoMaximo = aforoMaximo;

  Map<String, dynamic> toJson() {
    return {
      'idEspacio': idEspacio,
      'nombre': nombre,
      'tipo': tipo,
      'nivelOcupacion': nivelOcupacion.name,
      'promedioCalificacion': promedioCalificacion,
      'ubicacion': ubicacion.toJson(),
      'caracteristicas': caracteristicas.map((c) => c.toJson()).toList(),
      'categoriaIds': _categoriaIds ?? [],
      'ocupacionActual': ocupacionActual,
      'aforoMaximo': aforoMaximo,
    };
  }

  factory Espacio.fromJson(Map<String, dynamic> json) {
    return Espacio(
      idEspacio: json['idEspacio'] ?? json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      nivelOcupacion: NivelOcupacion.values.firstWhere(
        (e) => e.name == (json['nivelOcupacion'] ?? 'medio'),
        orElse: () => NivelOcupacion.medio,
      ),
      promedioCalificacion:
          (json['promedioCalificacion'] as num?)?.toDouble() ?? 0.0,
      ubicacion: Ubicacion.fromJson(
        (json['ubicacion'] as Map<String, dynamic>? ?? {}),
      ),
      caracteristicas: (json['caracteristicas'] as List? ?? [])
          .map((c) => CaracteristicaEspacio.fromJson(
                c as Map<String, dynamic>,
              ))
          .toList(),
      categoriaIds: json['categoriaIds'] != null
          ? List<String>.from(json['categoriaIds'])
          : [],
      // 🆕 Nuevos campos
      ocupacionActual: (json['ocupacionActual'] as num?)?.toInt() ?? 0,
      aforoMaximo: (json['aforoMaximo'] as num?)?.toInt(),
    );
  }
}