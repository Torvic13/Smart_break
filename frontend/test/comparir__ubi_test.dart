import 'package:flutter_test/flutter_test.dart';
import 'package:smart_break/models/estudiante.dart';
import 'package:smart_break/models/usuario.dart';

void main() {
  group('Compartir Ubicación - Pruebas Unitarias', () {
    
    test('Estudiante puede cambiar ubicacionCompartida de false a true', () {
      final estudiante = Estudiante(
        idUsuario: 'EST001',
        email: 'test@ulima.edu.pe',
        passwordHash: 'hash',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20220001',
        nombreCompleto: 'Juan Pérez',
        ubicacionCompartida: false,
        carrera: 'Ingeniería',
      );

      expect(estudiante.ubicacionCompartida, false);

      final actualizado = Estudiante(
        idUsuario: estudiante.idUsuario,
        email: estudiante.email,
        passwordHash: estudiante.passwordHash,
        fechaCreacion: estudiante.fechaCreacion,
        estado: estudiante.estado,
        codigoAlumno: estudiante.codigoAlumno,
        nombreCompleto: estudiante.nombreCompleto,
        ubicacionCompartida: true,
        carrera: estudiante.carrera,
      );

      expect(actualizado.ubicacionCompartida, true);
    });

    test('fromJson parsea correctamente ubicacionCompartida', () {
      final json = {
        'idUsuario': 'EST002',
        'email': 'test2@ulima.edu.pe',
        'passwordHash': 'hash',
        'fechaCreacion': DateTime.now().toIso8601String(),
        'estado': 'activo',
        'rol': 'estudiante',
        'codigoAlumno': '20220002',
        'nombreCompleto': 'María López',
        'ubicacionCompartida': true,
        'carrera': 'Ingeniería',
        'amigosIds': ['EST001'],
      };

      final estudiante = Estudiante.fromJson(json);

      expect(estudiante.ubicacionCompartida, true);
    });

    test('toJson incluye ubicacionCompartida', () {
      final estudiante = Estudiante(
        idUsuario: 'EST003',
        email: 'test3@ulima.edu.pe',
        passwordHash: 'hash',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20220003',
        nombreCompleto: 'Carlos Ruiz',
        ubicacionCompartida: true,
        carrera: 'Ingeniería',
      );

      final json = estudiante.toJson();

      expect(json['ubicacionCompartida'], true);
    });

    test('Filtrar amigos que comparten ubicación', () {
      final amigos = [
        Estudiante(
          idUsuario: 'EST004',
          email: 'test4@ulima.edu.pe',
          passwordHash: 'hash',
          fechaCreacion: DateTime.now(),
          estado: EstadoUsuario.activo,
          codigoAlumno: '20220004',
          nombreCompleto: 'Amigo 1',
          ubicacionCompartida: true,
          carrera: 'Ingeniería',
        ),
        Estudiante(
          idUsuario: 'EST005',
          email: 'test5@ulima.edu.pe',
          passwordHash: 'hash',
          fechaCreacion: DateTime.now(),
          estado: EstadoUsuario.activo,
          codigoAlumno: '20220005',
          nombreCompleto: 'Amigo 2',
          ubicacionCompartida: false,
          carrera: 'Ingeniería',
        ),
      ];

      final amigosCompartiendo = amigos.where((a) => a.ubicacionCompartida).toList();

      expect(amigosCompartiendo.length, 1);
      expect(amigosCompartiendo[0].nombreCompleto, 'Amigo 1');
    });

    test('Mensaje correcto según estado de ubicacionCompartida', () {
      const compartida = true;
      final mensajeCompartida = compartida 
        ? 'Ubicación compartida con amigos'
        : 'Ubicación oculta';

      expect(mensajeCompartida, 'Ubicación compartida con amigos');

      const oculta = false;
      final mensajeOculta = oculta 
        ? 'Ubicación compartida con amigos'
        : 'Ubicación oculta';

      expect(mensajeOculta, 'Ubicación oculta');
    });
  });
}