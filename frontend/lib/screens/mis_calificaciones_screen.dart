// lib/screens/mis_calificaciones_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calificacion.dart';
import '../dao/dao_factory.dart';
import '../dao/calificacion_dao.dart';

class MisCalificacionesScreen extends StatefulWidget {
  final String userId;
  final String authToken;

  const MisCalificacionesScreen({
    super.key,
    required this.userId,
    required this.authToken,
  });

  @override
  State<MisCalificacionesScreen> createState() =>
      _MisCalificacionesScreenState();
}

class _MisCalificacionesScreenState extends State<MisCalificacionesScreen> {
  List<Calificacion> _calificaciones = [];
  bool _isLoading = true;
  late CalificacionDAO _calificacionDao;

  @override
  void initState() {
    super.initState();
    _cargarCalificaciones();
  }

  Future<void> _cargarCalificaciones() async {
    try {
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      _calificacionDao = daoFactory.createCalificacionDAO();

      final calificaciones =
          await _calificacionDao.obtenerCalificacionesPorUsuario(
        idUsuario: widget.userId,
        authToken: widget.authToken,
      );

      setState(() {
        _calificaciones = calificaciones;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando calificaciones: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarCalificacion(String ratingId) async {
    try {
      await _calificacionDao.eliminarCalificacion(
        idCalificacion: ratingId,
        authToken: widget.authToken,
      );

      await _cargarCalificaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificación eliminada exitosamente')),
      );
    } catch (e) {
      print('Error eliminando calificación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar calificación: $e')),
      );
    }
  }

  Future<void> _editarCalificacion(
      Calificacion calificacion, double newRating) async {
    try {
      await _calificacionDao.actualizarCalificacion(
        idCalificacion: calificacion.idCalificacion,
        puntuacion: newRating,
        comentario: calificacion.comentario ?? '',
        authToken: widget.authToken,
      );

      await _cargarCalificaciones();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificación actualizada exitosamente')),
      );
    } catch (e) {
      print('Error editando calificación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar calificación: $e')),
      );
    }
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: const Color(0xFFF97316),
          size: 20,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _mostrarDialogoEditar(Calificacion calificacion) {
    double newRating = calificacion.puntuacion;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Calificación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona nueva puntuación:'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starNumber = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() => newRating = starNumber.toDouble());
                      },
                      child: Icon(
                        starNumber <= newRating
                            ? Icons.star
                            : Icons.star_border,
                        color: const Color(0xFFF97316),
                        size: 40,
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _editarCalificacion(calificacion, newRating);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(Calificacion calificacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Calificación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar esta calificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _eliminarCalificacion(calificacion.idCalificacion);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Calificaciones'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _calificaciones.isEmpty
              ? const Center(
                  child: Text(
                    'No has realizado ninguna calificación',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _calificaciones.length,
                  itemBuilder: (context, index) {
                    final calificacion = _calificaciones[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading:
                            _buildStarRating(calificacion.puntuacion),
                        title: Text(
                          'Espacio ID: ${calificacion.idEspacio}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (calificacion.comentario != null &&
                                calificacion.comentario!.isNotEmpty)
                              Text(
                                  'Comentario: ${calificacion.comentario}'),
                            Text('Fecha: ${_formatDate(calificacion.fecha)}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _mostrarDialogoEditar(calificacion);
                            } else if (value == 'delete') {
                              _mostrarDialogoEliminar(calificacion);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
