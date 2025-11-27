import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Importaciones corregidas basadas en tu estructura
import 'package:smart_break/dao/calificacion_dao.dart';
import 'package:smart_break/models/calificacion.dart'; 
import 'package:smart_break/screens/gestionar_comentarios_screen.dart'; 
import 'package:smart_break/dao/dao_factory.dart';

// Importa todas las clases fake que definimos
import 'fakes/fake_calificacion_dao.dart';


void main() {

  // Función auxiliar para inyectar el DAO falso a la pantalla.
  Widget createTestWidget({required CalificacionDAO dao}) {
    // 1. Creamos el FakeDAOFactory, inyectando el DAO que queremos usar en este test
    final fakeFactory = FakeDAOFactory(dao); 

    return MaterialApp(
      home: Builder(
        builder: (context) {
          // 2. Provee el DAOFactory (que es lo que la pantalla espera)
          return Provider<DAOFactory>(
            create: (_) => fakeFactory,
            child: const GestionarComentariosScreen(),
          );
        }
      ),
    );
  }

  // --- CP11: Estado Cargando ---
  testWidgets('CP11: Muestra CircularProgressIndicator mientras carga', (WidgetTester tester) async {
    final fakeDao = FakeCalificacionDAO();
    await tester.pumpWidget(createTestWidget(dao: fakeDao));
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Esperamos a que la carga termine (para limpiar)
    await tester.pumpAndSettle();
  });


  // --- CP12: Lista con N comentarios ---
  testWidgets('CP12: Muestra 2 comentarios con sus campos y encabezados', (WidgetTester tester) async {
    final fakeDao = FakeCalificacionDAO();
    await tester.pumpWidget(createTestWidget(dao: fakeDao));
    
    await tester.pumpAndSettle();

    // Validación de Encabezados
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Espacio'), findsOneWidget);
    
    // Validación de Contenido
    expect(find.text('JPEREZ'), findsOneWidget); // Comentario 1: Usa codigoAlumno
    expect(find.text('Sala de Cómputo 1'), findsOneWidget); 
    expect(find.text('María Gómez'), findsOneWidget); // Comentario 2: Usa nombreUsuario 
    
    expect(find.byIcon(Icons.delete), findsNWidgets(2));
  });
  
  // --- CP13: Lista vacía ---
  testWidgets('CP13: Muestra mensaje de lista vacía', (WidgetTester tester) async {
    final fakeDao = FakeCalificacionDAO();
    // Vaciamos la lista del DAO para este test
    fakeDao._comentarios.clear(); 
    
    await tester.pumpWidget(createTestWidget(dao: fakeDao));
    await tester.pumpAndSettle(); 

    expect(find.text('No hay comentarios registrados.'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsNothing);
  });
  
  // --- CP14: Error al cargar (Caja Blanca) ---
  testWidgets('CP14: Muestra error y botón Reintentar', (WidgetTester tester) async {
    // Usamos el DAO que fuerza el error en obtenerTodas()
    final failingDao = _FailingCalificacionDAO(FakeCalificacionDAO());
    await tester.pumpWidget(createTestWidget(dao: failingDao));
    
    await tester.pumpAndSettle(); 
    
    // 1. Validación: Se muestra el mensaje de error de la pantalla.
    expect(find.textContaining('Ocurrió un error al cargar los comentarios'), findsOneWidget); 
    
    // 2. Validación: Se muestra el botón de Reintentar.
    expect(find.byType(ElevatedButton), findsOneWidget);
    
    // 3. Simular Reintentar
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle(); 
    
    // Validamos que el error siga visible después del reintento fallido
    expect(find.textContaining('Ocurrió un error al cargar los comentarios'), findsOneWidget);
  });
  
  // --- CP15: Eliminación exitosa ---
  testWidgets('CP15: Eliminar, muestra confirmación, recarga y SnackBar', (WidgetTester tester) async {
    final fakeDao = FakeCalificacionDAO();
    await tester.pumpWidget(createTestWidget(dao: fakeDao));
    
    await tester.pumpAndSettle(); 
    
    // 1. Simular click en el botón de eliminar del primer comentario (JPEREZ)
    final deleteButton = find.byIcon(Icons.delete).first;
    await tester.tap(deleteButton);
    await tester.pump(); 
    
    // 2. Simular click en el botón de confirmación ('Eliminar')
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle(); 
    
    // 3. Validación: El comentario de JPEREZ YA NO DEBE ESTAR
    expect(find.text('JPEREZ'), findsNothing); 
    
    // 4. Validación: Que se haya mostrado el SnackBar
    expect(find.text('Comentario eliminado'), findsOneWidget);
  });
}