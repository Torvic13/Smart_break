import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dao/dao_factory.dart';
import '../dao/calificacion_dao.dart';
import '../models/calificacion.dart';

class GestionarComentariosScreen extends StatefulWidget {
  const GestionarComentariosScreen({super.key});

  @override
  State<GestionarComentariosScreen> createState() =>
      _GestionarComentariosScreenState();
}

class _GestionarComentariosScreenState
    extends State<GestionarComentariosScreen> {
  late CalificacionDAO _calificacionDao;

  bool _cargando = true;
  String? _error;
  List<Calificacion> _calificaciones = [];

  @override
  void initState() {
    super.initState();
    _calificacionDao =
        Provider.of<DAOFactory>(context, listen: false).createCalificacionDAO();
    _cargarCalificaciones();
  }

  Future<void> _cargarCalificaciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista = await _calificacionDao.obtenerTodas();
      if (!mounted) return;
      setState(() {
        _calificaciones = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _eliminarCalificacion(Calificacion calif) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text(
            '¿Estás seguro de eliminar este comentario? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _calificacionDao.eliminar(calif.idCalificacion);
      await _cargarCalificaciones();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Comentarios'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _cuerpo(),
      ),
    );
  }

  Widget _cuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ocurrió un error al cargar los comentarios',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarCalificaciones,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_calificaciones.isEmpty) {
      return const Center(
        child: Text(
          'No hay comentarios registrados.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado tipo tabla
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'Usuario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Espacio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  'Comentario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 40), // espacio para el botón
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            itemCount: _calificaciones.length,
            itemBuilder: (context, index) {
              final calif = _calificaciones[index];

              final usuarioLabel =
                  (calif.codigoAlumno != null && calif.codigoAlumno!.isNotEmpty)
                      ? calif.codigoAlumno!
                      : (calif.nombreUsuario != null &&
                              calif.nombreUsuario!.isNotEmpty)
                          ? calif.nombreUsuario!
                          : (calif.idUsuario ?? 'Sin usuario');

              final espacioLabel =
                  (calif.nombreEspacio != null && calif.nombreEspacio!.isNotEmpty)
                      ? calif.nombreEspacio!
                      : 'Sin espacio';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna Usuario
                      Expanded(
                        flex: 2,
                        child: Text(
                          usuarioLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Columna Espacio
                      Expanded(
                        flex: 3,
                        child: Text(
                          espacioLabel,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),

                      // Columna Comentario
                      Expanded(
                        flex: 5,
                        child: Text(
                          calif.comentario,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),

                      // Botón eliminar
                      IconButton(
                        onPressed: () => _eliminarCalificacion(calif),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
