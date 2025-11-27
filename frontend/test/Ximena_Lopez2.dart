import 'package:flutter_test/flutter_test.dart';
import 'package:smart_break/models/categoria_espacio.dart';

void main() {
  group('Modelo CategoriaEspacio', () {
    test('Crea categoría correctamente', () {
      // Arrange & Act
      final categoria = CategoriaEspacio(
        idCategoria: 'cat-123',
        nombre: 'Cafetería',
        tipo: TipoCategoria.tipoEspacio,
        fechaCreacion: DateTime.now(),
      );

      // Assert
      expect(categoria.idCategoria, 'cat-123');
      expect(categoria.nombre, 'Cafetería');
      expect(categoria.tipo, TipoCategoria.tipoEspacio);
    });

    test('TipoCategoria tiene todos los valores esperados', () {
      // Assert
      expect(TipoCategoria.values.length, 5);
      expect(TipoCategoria.values, contains(TipoCategoria.tipoEspacio));
      expect(TipoCategoria.values, contains(TipoCategoria.nivelRuido));
      expect(TipoCategoria.values, contains(TipoCategoria.comodidad));
      expect(TipoCategoria.values, contains(TipoCategoria.capacidad));
      expect(TipoCategoria.values, contains(TipoCategoria.bloqueHorario));
    });

    test('displayName retorna nombre correcto para cada tipo', () {
      expect(TipoCategoria.tipoEspacio.displayName, 'Tipos de Espacio');
      expect(TipoCategoria.nivelRuido.displayName, 'Niveles de Ruido');
      expect(TipoCategoria.comodidad.displayName, 'Comodidades');
      expect(TipoCategoria.capacidad.displayName, 'Capacidades');
      expect(TipoCategoria.bloqueHorario.displayName, 'Bloques Horarios Disponibles');
    });
  });

  group('Lógica de asignación de categorías', () {
    test('Agregar categoría a lista vacía', () {
      // Arrange
      final categorias = <String>[];

      // Act
      categorias.add('cat-1');

      // Assert
      expect(categorias.length, 1);
      expect(categorias.contains('cat-1'), true);
    });

    test('Agregar múltiples categorías', () {
      // Arrange
      final categorias = <String>[];

      // Act
      categorias.addAll(['cat-1', 'cat-2', 'cat-3']);

      // Assert
      expect(categorias.length, 3);
      expect(categorias, containsAll(['cat-1', 'cat-2', 'cat-3']));
    });

    test('Eliminar categoría de lista', () {
      // Arrange
      final categorias = ['cat-1', 'cat-2', 'cat-3'];

      // Act
      categorias.remove('cat-2');

      // Assert
      expect(categorias.length, 2);
      expect(categorias.contains('cat-2'), false);
      expect(categorias, containsAll(['cat-1', 'cat-3']));
    });

    test('Set no permite categorías duplicadas', () {
      // Arrange
      final categorias = <String>{};

      // Act
      categorias.add('cat-1');
      categorias.add('cat-1'); // Duplicado
      categorias.add('cat-2');

      // Assert
      expect(categorias.length, 2);
      expect(categorias, contains('cat-1'));
      expect(categorias, contains('cat-2'));
    });

    test('Convertir Set a List para enviar al backend', () {
      // Arrange
      final categoriasSet = {'cat-1', 'cat-2', 'cat-3'};

      // Act
      final categoriasList = categoriasSet.toList();

      // Assert
      expect(categoriasList, isList);
      expect(categoriasList.length, 3);
    });
  });

  group('Validaciones de datos', () {
    test('Nombre de categoría no debe estar vacío', () {
      // Arrange
      final nombre = 'Cafetería';

      // Act
      final esValido = nombre.trim().isNotEmpty;

      // Assert
      expect(esValido, true);
    });

    test('Nombre de categoría vacío es inválido', () {
      // Arrange
      final nombre = '   ';

      // Act
      final esValido = nombre.trim().isNotEmpty;

      // Assert
      expect(esValido, false);
    });

    test('Validar longitud mínima del nombre', () {
      // Arrange
      final nombreCorto = 'Ca';
      final nombreValido = 'Cafetería';

      // Act
      final esCortoValido = nombreCorto.trim().length >= 3;
      final esValidoValido = nombreValido.trim().length >= 3;

      // Assert
      expect(esCortoValido, false);
      expect(esValidoValido, true);
    });

    test('Validar que idCategoria no esté vacío', () {
      // Arrange
      final categoria = CategoriaEspacio(
        idCategoria: 'cat-123',
        nombre: 'Test',
        tipo: TipoCategoria.tipoEspacio,
        fechaCreacion: DateTime.now(),
      );

      // Assert
      expect(categoria.idCategoria.isNotEmpty, true);
    });
  });

  group('Filtrado de categorías por tipo', () {
    test('Filtrar categorías de tipo tipoEspacio', () {
      // Arrange
      final todasCategorias = [
        CategoriaEspacio(
          idCategoria: 'cat-1',
          nombre: 'Cafetería',
          tipo: TipoCategoria.tipoEspacio,
          fechaCreacion: DateTime.now(),
        ),
        CategoriaEspacio(
          idCategoria: 'cat-2',
          nombre: 'Silencioso',
          tipo: TipoCategoria.nivelRuido,
          fechaCreacion: DateTime.now(),
        ),
        CategoriaEspacio(
          idCategoria: 'cat-3',
          nombre: 'Biblioteca',
          tipo: TipoCategoria.tipoEspacio,
          fechaCreacion: DateTime.now(),
        ),
      ];

      // Act
      final tiposEspacio = todasCategorias
          .where((cat) => cat.tipo == TipoCategoria.tipoEspacio)
          .toList();

      // Assert
      expect(tiposEspacio.length, 2);
      expect(tiposEspacio.every((c) => c.tipo == TipoCategoria.tipoEspacio), true);
    });

    test('Agrupar categorías por tipo', () {
      // Arrange
      final categorias = [
        CategoriaEspacio(
          idCategoria: 'cat-1',
          nombre: 'Cafetería',
          tipo: TipoCategoria.tipoEspacio,
          fechaCreacion: DateTime.now(),
        ),
        CategoriaEspacio(
          idCategoria: 'cat-2',
          nombre: 'Wi-Fi',
          tipo: TipoCategoria.comodidad,
          fechaCreacion: DateTime.now(),
        ),
        CategoriaEspacio(
          idCategoria: 'cat-3',
          nombre: 'Biblioteca',
          tipo: TipoCategoria.tipoEspacio,
          fechaCreacion: DateTime.now(),
        ),
      ];

      // Act
      final porTipo = <TipoCategoria, List<CategoriaEspacio>>{};
      for (var tipo in TipoCategoria.values) {
        porTipo[tipo] = categorias.where((cat) => cat.tipo == tipo).toList();
      }

      // Assert
      expect(porTipo[TipoCategoria.tipoEspacio]?.length, 2);
      expect(porTipo[TipoCategoria.comodidad]?.length, 1);
      expect(porTipo[TipoCategoria.nivelRuido]?.length, 0);
    });
  });

  group('Lógica de negocio - Validaciones', () {
    test('No puede asignar categoría duplicada a un espacio', () {
      // Arrange
      final categoriasEspacio = <String>{'cat-1', 'cat-2'};
      final nuevaCategoria = 'cat-1'; // Duplicada

      // Act
      final antesLength = categoriasEspacio.length;
      categoriasEspacio.add(nuevaCategoria);
      final despuesLength = categoriasEspacio.length;

      // Assert
      expect(antesLength, despuesLength);
      expect(categoriasEspacio.length, 2);
    });

    test('Puede agregar nueva categoría no duplicada', () {
      // Arrange
      final categoriasEspacio = <String>{'cat-1', 'cat-2'};
      final nuevaCategoria = 'cat-3';

      // Act
      categoriasEspacio.add(nuevaCategoria);

      // Assert
      expect(categoriasEspacio.length, 3);
      expect(categoriasEspacio.contains('cat-3'), true);
    });

    test('Limpiar todas las categorías de un espacio', () {
      // Arrange
      final categoriasEspacio = <String>{'cat-1', 'cat-2', 'cat-3'};

      // Act
      categoriasEspacio.clear();

      // Assert
      expect(categoriasEspacio.isEmpty, true);
      expect(categoriasEspacio.length, 0);
    });

    test('Reemplazar todas las categorías de un espacio', () {
      // Arrange
      final categoriasEspacio = <String>{'cat-1', 'cat-2'};
      final nuevasCategorias = {'cat-3', 'cat-4', 'cat-5'};

      // Act
      categoriasEspacio
        ..clear()
        ..addAll(nuevasCategorias);

      // Assert
      expect(categoriasEspacio.length, 3);
      expect(categoriasEspacio.contains('cat-1'), false);
      expect(categoriasEspacio.containsAll(nuevasCategorias), true);
    });
  });
}
