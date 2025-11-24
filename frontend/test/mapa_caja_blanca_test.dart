// test/mapa_caja_blanca_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_break/models/espacio.dart';
import 'package:smart_break/models/ubicacion.dart';
void main() {
  group('CAJA BLANCA - HU01: Filtrar espacios cercanos (complejidad ciclomática > 3)', () {
    late List<Espacio> todosLosEspacios;
    late Ubicacion miUbicacion;

    setUp(() {
      miUbicacion = Ubicacion(latitud: -12.0675, longitud: -77.0342, piso: 3, idUbicacion: 'user');
      
      todosLosEspacios = [
        Espacio(
          idEspacio: "1", nombre: "Biblio A", tipo: "biblioteca",
          nivelOcupacion: NivelOcupacion.vacio, promedioCalificacion: 4.8,
          ubicacion: Ubicacion(latitud: -12.0676, longitud: -77.0343, piso: 2, idUbicacion: "1"),
          caracteristicas: [], categoriaIds: ["biblio"]
        ),
        Espacio(
          idEspacio: "2", nombre: "Cafetería Central", tipo: "cafetería",
          nivelOcupacion: NivelOcupacion.medio, promedioCalificacion: 4.2,
          ubicacion: Ubicacion(latitud: -12.0680, longitud: -77.0350, piso: 1, idUbicacion: "2"),
          caracteristicas: [], categoriaIds: ["cafe"]
        ),
        Espacio(
          idEspacio: "3", nombre: "Sala D", tipo: "sala de estudio",
          nivelOcupacion: NivelOcupacion.lleno, promedioCalificacion: 3.9,
          ubicacion: Ubicacion(latitud: -12.0700, longitud: -77.0400, piso: 4, idUbicacion: "3"),
          caracteristicas: [], categoriaIds: ["sala"]
        ),
      ];
    });

    List<Espacio> filtrarCercanos(List<Espacio> espacios, Ubicacion user, double maxDistancia) {
      final resultados = <Espacio>[];
      for (final espacio in espacios) {
        final distancia = (espacio.ubicacion.latitud - user.latitud).abs() * 111000 +
                         (espacio.ubicacion.longitud - user.longitud).abs() * 111000 * 0.7;
        if (distancia <= maxDistancia) { // rama 1
          if (espacio.nivelOcupacion != NivelOcupacion.lleno) { // rama 2
            resultados.add(espacio);
          } else if (espacio.promedioCalificacion >= 4.5) { // rama 3
            resultados.add(espacio);
          }
        } else if (espacio.tipo == "cafetería") { // rama 4 (lejos pero es café)
          resultados.add(espacio);
        }
      }
      return resultados;
    }

    test('Debe filtrar correctamente con múltiples condiciones (complejidad > 3)', () {
      final cercanos = filtrarCercanos(todosLosEspacios, miUbicacion, 600); // ~600m

      expect(cercanos.length, 2);
      expect(cercanos.any((e) => e.nombre.contains("Biblio")), isTrue);
      expect(cercanos.any((e) => e.nombre.contains("Cafetería")), isTrue);
      expect(cercanos.any((e) => e.nombre.contains("Sala")), isFalse);
    });
  });
}