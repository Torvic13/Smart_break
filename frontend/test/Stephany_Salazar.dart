import 'package:flutter_test/flutter_test.dart';
import 'package:smart_break/models/incidencia.dart';
import 'package:smart_break/dao/mock_incidencia_dao.dart';

void main() {
  group('Reportar Incidencia - Tests de DAO', () {
    late MockIncidenciaDAO dao;

    setUp(() {
      dao = MockIncidenciaDAO();
    });

    test('MockIncidenciaDAO crea una incidencia correctamente', () async {
      final newIncidencia = Incidencia(
        idIncidencia: 'test-001',
        idEspacio: '081e35ff-47ce-4cee-b46c-3e0121fefcbb',
        nombreEspacio: 'Auditorio Principal',
        tipoIncidencia: 'Ruido excesivo',
        descripcion: 'Hay mucho ruido durante el evento',
        fechaReporte: DateTime.now(),
        usuarioReporte: 'test@email.com',
        resuelta: false,
      );

      // Crear la incidencia
      await dao.crear(newIncidencia);

      // Obtener todas las incidencias
      final todasIncidencias = await dao.obtenerTodas();

      // Verificar que se creó
      expect(todasIncidencias.isNotEmpty, true);
      expect(
        todasIncidencias.any((inc) => inc.idIncidencia == 'test-001'),
        true,
      );
    });

    test('Las incidencias se filtran correctamente por espacio', () async {
      final incidencias = await dao.obtenerPorEspacio('081e35ff-47ce-4cee-b46c-3e0121fefcbb');

      // Verificar que todas tienen el mismo idEspacio
      for (final inc in incidencias) {
        expect(inc.idEspacio, '081e35ff-47ce-4cee-b46c-3e0121fefcbb');
      }
    });

    test('Solo se devuelven incidencias no resueltas', () async {
      final incidencias = await dao.obtenerPorEspacio('081e35ff-47ce-4cee-b46c-3e0121fefcbb');

      // Verificar que todas están sin resolver
      for (final inc in incidencias) {
        expect(inc.resuelta, false);
      }
    });

    test('Obtener una incidencia por ID específico', () async {
      final incidencia = await dao.obtenerPorId('1');

      // Verificar que existe
      expect(incidencia, isNotNull);
      if (incidencia != null) {
        expect(incidencia.idIncidencia, '1');
      }
    });

    test('Retorna null para ID inexistente', () async {
      final incidencia = await dao.obtenerPorId('xyz-no-existe');

      expect(incidencia, isNull);
    });

    test('Actualizar una incidencia marca como resuelta', () async {
      final incidenciaOriginal = await dao.obtenerPorId('1');
      expect(incidenciaOriginal?.resuelta, false);

      if (incidenciaOriginal != null) {
        final incidenciaActualizada = Incidencia(
          idIncidencia: incidenciaOriginal.idIncidencia,
          idEspacio: incidenciaOriginal.idEspacio,
          nombreEspacio: incidenciaOriginal.nombreEspacio,
          tipoIncidencia: incidenciaOriginal.tipoIncidencia,
          descripcion: incidenciaOriginal.descripcion,
          fechaReporte: incidenciaOriginal.fechaReporte,
          usuarioReporte: incidenciaOriginal.usuarioReporte,
          resuelta: true,
          fechaResolucion: DateTime.now(),
          notas: 'Problema solucionado',
        );

        await dao.actualizar(incidenciaActualizada);

        final actualizado = await dao.obtenerPorId('1');
        expect(actualizado?.resuelta, true);
      }
    });

    test('Modelo Incidencia tiene todos los campos requeridos', () {
      final incidencia = Incidencia(
        idIncidencia: 'test-model-001',
        idEspacio: 'space-123',
        nombreEspacio: 'Biblioteca',
        tipoIncidencia: 'Falta de limpieza',
        descripcion: 'El piso está sucio',
        fechaReporte: DateTime.now(),
        usuarioReporte: 'user@example.com',
        resuelta: false,
      );

      expect(incidencia.idIncidencia, 'test-model-001');
      expect(incidencia.idEspacio, 'space-123');
      expect(incidencia.nombreEspacio, 'Biblioteca');
      expect(incidencia.tipoIncidencia, 'Falta de limpieza');
      expect(incidencia.descripcion, 'El piso está sucio');
      expect(incidencia.usuarioReporte, 'user@example.com');
      expect(incidencia.resuelta, false);
    });

    test('Serialización JSON de Incidencia', () {
      final incidencia = Incidencia(
        idIncidencia: 'json-test-001',
        idEspacio: 'space-456',
        nombreEspacio: 'Cafetería',
        tipoIncidencia: 'Ruido excesivo',
        descripcion: 'Mucho ruido',
        fechaReporte: DateTime(2025, 11, 23, 10, 30),
        usuarioReporte: 'user@email.com',
        resuelta: false,
      );

      final json = incidencia.toJson();

      expect(json['idIncidencia'], 'json-test-001');
      expect(json['idEspacio'], 'space-456');
      expect(json['nombreEspacio'], 'Cafetería');
      expect(json['tipoIncidencia'], 'Ruido excesivo');
      expect(json['descripcion'], 'Mucho ruido');
      expect(json['usuarioReporte'], 'user@email.com');
      expect(json['resuelta'], false);
    });

    test('Deserialización JSON de Incidencia', () {
      final json = {
        'idIncidencia': 'from-json-001',
        'idEspacio': 'space-789',
        'nombreEspacio': 'Sala de Estudio',
        'tipoIncidencia': 'Problemas de temperatura',
        'descripcion': 'Hace mucho calor',
        'fechaReporte': '2025-11-23T10:30:00.000Z',
        'usuarioReporte': 'test@test.com',
        'resuelta': false,
        'notas': '',
      };

      final incidencia = Incidencia.fromJson(json);

      expect(incidencia.idIncidencia, 'from-json-001');
      expect(incidencia.idEspacio, 'space-789');
      expect(incidencia.nombreEspacio, 'Sala de Estudio');
      expect(incidencia.tipoIncidencia, 'Problemas de temperatura');
      expect(incidencia.descripcion, 'Hace mucho calor');
      expect(incidencia.usuarioReporte, 'test@test.com');
      expect(incidencia.resuelta, false);
    });

    test('Tipos de incidencia válidos', () {
      const tiposValidos = [
        'Daño en infraestructura',
        'Falta de limpieza',
        'Ruido excesivo',
        'Problemas de temperatura',
        'Falta de servicios (WiFi, enchufes)',
        'Seguridad',
        'Otro',
      ];

      for (int i = 0; i < tiposValidos.length; i++) {
        final tipo = tiposValidos[i];
        final incidencia = Incidencia(
          idIncidencia: 'tipo-test-$i',
          idEspacio: 'space-test',
          nombreEspacio: 'Test',
          tipoIncidencia: tipo,
          descripcion: 'Test',
          fechaReporte: DateTime.now(),
          usuarioReporte: 'test@test.com',
          resuelta: false,
        );

        expect(incidencia.tipoIncidencia, tipo);
      }
    });
  });
}
