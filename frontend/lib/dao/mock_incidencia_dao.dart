import '../models/incidencia.dart';

class MockIncidenciaDAO {
  static final MockIncidenciaDAO _instance = MockIncidenciaDAO._internal();
  late final List<Incidencia> _incidencias;

  MockIncidenciaDAO._internal() {
    _incidencias = [
      Incidencia(
        idIncidencia: '1',
        idEspacio: '081e35ff-47ce-4cee-b46c-3e0121fefcbb',
        nombreEspacio: 'Auditorio Principal',
        tipoIncidencia: 'Falta de limpieza',
        descripcion: 'Los pisos están muy sucios',
        fechaReporte: DateTime.now().subtract(const Duration(days: 2)),
        usuarioReporte: 'user1@email.com',
        resuelta: false,
      ),
      Incidencia(
        idIncidencia: '2',
        idEspacio: 'b9e090d8-3050-483b-9a7a-a3459996b259',
        nombreEspacio: 'Cafetería Estudiantil',
        tipoIncidencia: 'Ruido excesivo',
        descripcion: 'Hay mucho ruido, no se puede concentrar',
        fechaReporte: DateTime.now().subtract(const Duration(days: 1)),
        usuarioReporte: 'user2@email.com',
        resuelta: false,
      ),
      Incidencia(
        idIncidencia: '3',
        idEspacio: 'e94d3400-94db-4b4f-92a0-f534bbc5d38d',
        nombreEspacio: 'Patio de Comidas ULima',
        tipoIncidencia: 'Problemas de temperatura',
        descripcion: 'El aire acondicionado no funciona bien',
        fechaReporte: DateTime.now().subtract(const Duration(hours: 3)),
        usuarioReporte: 'user3@email.com',
        resuelta: false,
      ),
    ];
  }

  factory MockIncidenciaDAO() {
    return _instance;
  }

  Future<Incidencia?> obtenerPorId(String idIncidencia) async {
    try {
      return _incidencias.firstWhere((inc) => inc.idIncidencia == idIncidencia);
    } catch (e) {
      return null;
    }
  }

  Future<List<Incidencia>> obtenerTodas() async {
    return _incidencias;
  }

  Future<List<Incidencia>> obtenerPorEspacio(String idEspacio) async {
    final idInt = int.tryParse(idEspacio) ?? 0;
    return _incidencias
        .where((inc) => inc.idEspacio == idInt && !inc.resuelta)
        .toList();
  }

  Future<void> crear(Incidencia incidencia) async {
    _incidencias.add(incidencia);
  }

  Future<void> actualizar(Incidencia incidencia) async {
    final index =
        _incidencias.indexWhere((inc) => inc.idIncidencia == incidencia.idIncidencia);
    if (index != -1) {
      _incidencias[index] = incidencia;
    }
  }

  Future<void> eliminar(String idIncidencia) async {
    _incidencias.removeWhere((inc) => inc.idIncidencia == idIncidencia);
  }
}
