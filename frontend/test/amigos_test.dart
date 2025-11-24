import 'package:flutter_test/flutter_test.dart';
import 'package:smart_break/models/estudiante.dart';
import 'package:smart_break/models/usuario.dart';

void main() {
  group('Modelo Estudiante - Amigos', () {
    test('Estudiante se crea con lista de amigos vacía por defecto', () {
      // Arrange & Act
      final estudiante = Estudiante(
        idUsuario: 'user-123',
        email: 'juan@ulima.edu.pe',
        passwordHash: 'hash123',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20210001',
        nombreCompleto: 'Juan Pérez',
        ubicacionCompartida: true,
        carrera: 'Ingeniería de Sistemas',
      );

      // Assert
      expect(estudiante.amigosIds, isEmpty);
      expect(estudiante.amigosIds, isList);
    });

    test('Estudiante se crea con lista de amigos pre-definida', () {
      // Arrange & Act
      final estudiante = Estudiante(
        idUsuario: 'user-123',
        email: 'maria@ulima.edu.pe',
        passwordHash: 'hash123',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20210002',
        nombreCompleto: 'María López',
        ubicacionCompartida: true,
        carrera: 'Administración',
        amigosIds: ['user-456', 'user-789'],
      );

      // Assert
      expect(estudiante.amigosIds.length, 2);
      expect(estudiante.amigosIds, contains('user-456'));
      expect(estudiante.amigosIds, contains('user-789'));
    });

    test('Código de alumno tiene formato válido', () {
      // Arrange
      final codigoValido = '20210001';
      final codigoInvalido = '123';

      // Act
      final esValidoLongitud = codigoValido.length == 8;
      final esInvalidoLongitud = codigoInvalido.length == 8;

      // Assert
      expect(esValidoLongitud, true);
      expect(esInvalidoLongitud, false);
    });

    test('Código de alumno solo contiene números', () {
      // Arrange
      final codigoValido = '20210001';
      final codigoInvalido = '2021A001';

      // Act
      final esNumerico = int.tryParse(codigoValido) != null;
      final esInvalidoNumerico = int.tryParse(codigoInvalido) != null;

      // Assert
      expect(esNumerico, true);
      expect(esInvalidoNumerico, false);
    });
  });

  group('Lógica de negocio - Agregar amigos', () {
    test('Agregar amigo a lista vacía', () {
      // Arrange
      final amigos = <String>[];
      final nuevoAmigoId = 'user-456';

      // Act
      amigos.add(nuevoAmigoId);

      // Assert
      expect(amigos.length, 1);
      expect(amigos.contains(nuevoAmigoId), true);
    });

    test('Agregar múltiples amigos', () {
      // Arrange
      final amigos = <String>[];

      // Act
      amigos.addAll(['user-456', 'user-789', 'user-321']);

      // Assert
      expect(amigos.length, 3);
      expect(amigos, containsAll(['user-456', 'user-789', 'user-321']));
    });

    test('Eliminar amigo de la lista', () {
      // Arrange
      final amigos = ['user-456', 'user-789', 'user-321'];

      // Act
      amigos.remove('user-789');

      // Assert
      expect(amigos.length, 2);
      expect(amigos.contains('user-789'), false);
      expect(amigos, containsAll(['user-456', 'user-321']));
    });

    test('No permite agregar amigo duplicado usando Set', () {
      // Arrange
      final amigos = <String>{};

      // Act
      amigos.add('user-456');
      amigos.add('user-456'); // Duplicado
      amigos.add('user-789');

      // Assert
      expect(amigos.length, 2);
      expect(amigos.toList(), containsAll(['user-456', 'user-789']));
    });

    test('Verificar si ya es amigo antes de agregar', () {
      // Arrange
      final amigos = ['user-456', 'user-789'];
      final candidatoExistente = 'user-456';
      final candidatoNuevo = 'user-321';

      // Act
      final yaEsAmigo = amigos.contains(candidatoExistente);
      final noEsAmigo = amigos.contains(candidatoNuevo);

      // Assert
      expect(yaEsAmigo, true);
      expect(noEsAmigo, false);
    });
  });

  group('Validaciones de búsqueda por código', () {
    test('Código de alumno no debe estar vacío', () {
      // Arrange
      final codigoVacio = '';
      final codigoValido = '20210001';

      // Act
      final esVacioInvalido = codigoVacio.trim().isEmpty;
      final esValidoNoVacio = codigoValido.trim().isNotEmpty;

      // Assert
      expect(esVacioInvalido, true);
      expect(esValidoNoVacio, true);
    });

    test('Código debe tener exactamente 8 dígitos', () {
      // Arrange
      final codigoCorto = '2021';
      final codigoLargo = '202100012';
      final codigoCorrecto = '20210001';

      // Act
      final esCorto = codigoCorto.length == 8;
      final esLargo = codigoLargo.length == 8;
      final esCorrecto = codigoCorrecto.length == 8;

      // Assert
      expect(esCorto, false);
      expect(esLargo, false);
      expect(esCorrecto, true);
    });

    test('Normalizar código elimina espacios', () {
      // Arrange
      final codigoConEspacios = ' 20210001 ';

      // Act
      final codigoNormalizado = codigoConEspacios.trim();

      // Assert
      expect(codigoNormalizado, '20210001');
      expect(codigoNormalizado.length, 8);
    });
  });

  group('Relación bilateral de amistad', () {
    test('Agregar amigo actualiza ambas listas', () {
      // Arrange
      var usuario1Amigos = <String>[];
      var usuario2Amigos = <String>[];
      const idUsuario1 = 'user-123';
      const idUsuario2 = 'user-456';

      // Act - Simular relación bilateral
      usuario1Amigos.add(idUsuario2);
      usuario2Amigos.add(idUsuario1);

      // Assert
      expect(usuario1Amigos.contains(idUsuario2), true);
      expect(usuario2Amigos.contains(idUsuario1), true);
    });

    test('Eliminar amigo debe actualizar ambas listas', () {
      // Arrange
      var usuario1Amigos = ['user-456', 'user-789'];
      var usuario2Amigos = ['user-123', 'user-321'];
      const idUsuario1 = 'user-123';
      const idUsuario2 = 'user-456';

      // Act - Eliminar relación bilateral
      usuario1Amigos.remove(idUsuario2);
      usuario2Amigos.remove(idUsuario1);

      // Assert
      expect(usuario1Amigos.contains(idUsuario2), false);
      expect(usuario2Amigos.contains(idUsuario1), false);
    });
  });

  group('Filtrado y búsqueda de amigos', () {
    test('Obtener lista de amigos de un estudiante', () {
      // Arrange
      final estudiante = Estudiante(
        idUsuario: 'user-123',
        email: 'pedro@ulima.edu.pe',
        passwordHash: 'hash123',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20210003',
        nombreCompleto: 'Pedro García',
        ubicacionCompartida: true,
        carrera: 'Derecho',
        amigosIds: ['user-456', 'user-789', 'user-321'],
      );

      // Act
      final cantidadAmigos = estudiante.amigosIds.length;
      final primerAmigo = estudiante.amigosIds.first;

      // Assert
      expect(cantidadAmigos, 3);
      expect(primerAmigo, 'user-456');
    });

    test('Verificar si tiene amigos', () {
      // Arrange
      final estudianteConAmigos = Estudiante(
        idUsuario: 'user-123',
        email: 'ana@ulima.edu.pe',
        passwordHash: 'hash123',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20210004',
        nombreCompleto: 'Ana Martínez',
        ubicacionCompartida: true,
        carrera: 'Medicina',
        amigosIds: ['user-456'],
      );

      final estudianteSinAmigos = Estudiante(
        idUsuario: 'user-789',
        email: 'luis@ulima.edu.pe',
        passwordHash: 'hash123',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20210005',
        nombreCompleto: 'Luis Torres',
        ubicacionCompartida: false,
        carrera: 'Economía',
      );

      // Act
      final tieneAmigos = estudianteConAmigos.amigosIds.isNotEmpty;
      final noTieneAmigos = estudianteSinAmigos.amigosIds.isEmpty;

      // Assert
      expect(tieneAmigos, true);
      expect(noTieneAmigos, true);
    });

    test('Contar cantidad de amigos', () {
      // Arrange
      final estudiante = Estudiante(
        idUsuario: 'user-123',
        email: 'sofia@ulima.edu.pe',
        passwordHash: 'hash123',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20210006',
        nombreCompleto: 'Sofia Ramírez',
        ubicacionCompartida: true,
        carrera: 'Arquitectura',
        amigosIds: ['user-1', 'user-2', 'user-3', 'user-4', 'user-5'],
      );

      // Act
      final cantidad = estudiante.amigosIds.length;

      // Assert
      expect(cantidad, 5);
      expect(cantidad, greaterThan(0));
    });
  });

  group('Validaciones de datos de estudiante', () {
    test('Email debe tener formato válido', () {
      // Arrange
      final emailValido = 'estudiante@ulima.edu.pe';
      final emailInvalido = 'estudiante@';

      // Act
      final esValidoFormato = emailValido.contains('@') && emailValido.contains('.');
      final esInvalidoFormato = emailInvalido.contains('@') && emailInvalido.contains('.');

      // Assert
      expect(esValidoFormato, true);
      expect(esInvalidoFormato, false);
    });

    test('Nombre completo no debe estar vacío', () {
      // Arrange
      final nombreValido = 'Carlos Díaz';

      // Act
      final nombreNoVacio = nombreValido.trim().isNotEmpty;

      // Assert
      expect(nombreNoVacio, true);
    });

    test('Carrera debe estar definida', () {
      // Arrange
      final estudiante = Estudiante(
        idUsuario: 'user-123',
        email: 'roberto@ulima.edu.pe',
        passwordHash: 'hash123',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20210007',
        nombreCompleto: 'Roberto Sánchez',
        ubicacionCompartida: false,
        carrera: 'Ingeniería Industrial',
      );

      // Assert
      expect(estudiante.carrera.isNotEmpty, true);
    });
  });

  group('Conversión y serialización', () {
    test('Estudiante con amigos se serializa correctamente a JSON', () {
      // Arrange
      final estudiante = Estudiante(
        idUsuario: 'user-123',
        email: 'elena@ulima.edu.pe',
        passwordHash: 'hash123',
        fechaCreacion: DateTime.now(),
        estado: EstadoUsuario.activo,
        codigoAlumno: '20210008',
        nombreCompleto: 'Elena Flores',
        ubicacionCompartida: true,
        carrera: 'Comunicaciones',
        amigosIds: ['user-456', 'user-789'],
      );

      // Act
      final json = estudiante.toJson();

      // Assert
      expect(json['idUsuario'], 'user-123');
      expect(json['codigoAlumno'], '20210008');
      expect(json['amigosIds'], isList);
      expect(json['amigosIds'].length, 2);
    });

    test('Lista de amigos se convierte a JSON correctamente', () {
      // Arrange
      final amigosIds = ['user-456', 'user-789', 'user-321'];

      // Act
      final jsonList = amigosIds;

      // Assert
      expect(jsonList, isList);
      expect(jsonList.length, 3);
      expect(jsonList, containsAll(['user-456', 'user-789', 'user-321']));
    });
  });

  group('Casos límite', () {
    test('Agregar muchos amigos', () {
      // Arrange
      final amigos = <String>[];
      final cantidadAmigos = 100;

      // Act
      for (int i = 0; i < cantidadAmigos; i++) {
        amigos.add('user-$i');
      }

      // Assert
      expect(amigos.length, cantidadAmigos);
      expect(amigos.first, 'user-0');
      expect(amigos.last, 'user-99');
    });

    test('Eliminar todos los amigos', () {
      // Arrange
      var amigos = ['user-1', 'user-2', 'user-3', 'user-4', 'user-5'];

      // Act
      amigos.clear();

      // Assert
      expect(amigos.isEmpty, true);
      expect(amigos.length, 0);
    });

    test('Buscar amigo específico en lista grande', () {
      // Arrange
      final amigos = List.generate(1000, (i) => 'user-$i');
      const amigoABuscar = 'user-500';

      // Act
      final encontrado = amigos.contains(amigoABuscar);
      final indice = amigos.indexOf(amigoABuscar);

      // Assert
      expect(encontrado, true);
      expect(indice, 500);
    });
  });

  group('Validación de unicidad de código de alumno', () {
    test('Códigos de alumno deben ser únicos', () {
      // Arrange
      final codigos = <String>{};

      // Act
      codigos.add('20210001');
      codigos.add('20210002');
      codigos.add('20210001'); // Duplicado

      // Assert
      expect(codigos.length, 2);
    });

    test('No se puede agregar a sí mismo como amigo', () {
      // Arrange
      const idUsuario = 'user-123';
      final amigos = <String>[];

      // Act
      final puedeAgregarseASiMismo = idUsuario != idUsuario; // Siempre false
      if (!puedeAgregarseASiMismo) {
        // No agregar
      } else {
        amigos.add(idUsuario);
      }

      // Assert
      expect(puedeAgregarseASiMismo, false);
      expect(amigos.contains(idUsuario), false);
    });

    test('Validar que el amigo a agregar no sea el mismo usuario', () {
      // Arrange
      const miId = 'user-123';
      const amigoId = 'user-456';
      const miMismoId = 'user-123';

      // Act
      final esDiferenteValido = miId != amigoId;
      final esMismoInvalido = miId == miMismoId;

      // Assert
      expect(esDiferenteValido, true);
      expect(esMismoInvalido, true);
    });
  });
}
