import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../models/espacio.dart';
import '../models/disponibilidad.dart';
import '../models/calificacion.dart';
import '../models/incidencia.dart';

import '../dao/mock_disponibilidad_dao.dart';
import '../dao/dao_factory.dart';
import '../dao/calificacion_dao.dart';
import '../dao/auth_service.dart';
import '../dao/mock_incidencia_dao.dart';

import '../services/incidencia_service.dart';

class DetalleEspacioScreen extends StatefulWidget {
  final Espacio espacio;

  const DetalleEspacioScreen({super.key, required this.espacio});

  @override
  State<DetalleEspacioScreen> createState() => _DetalleEspacioScreenState();
}

class _DetalleEspacioScreenState extends State<DetalleEspacioScreen> {
  final TextEditingController _comentarioController = TextEditingController();
  final MockDisponibilidadDAO _daoDisponibilidad = MockDisponibilidadDAO();
  final MockIncidenciaDAO _daoIncidenciaMock = MockIncidenciaDAO();

  final String _token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyLWlkIiwiZW1haWwiOiJ1c3VhcmlvQGVtYWlsLmNvbSIsInJvbCI6ImVzdHVkaWFudGUiLCJpYXQiOjE2MzIzMjMyMzIsImV4cCI6MTYzMjMzNjYzMn0.test';

  late CalificacionDAO _calificacionDao;

  double _puntuacion = 0.0;
  bool _isSubmitting = false;

  String? _estadoSeleccionado;

  List<Incidencia> _incidencias = [];
  List<Calificacion> _calificaciones = [];

  bool _cargandoCalificaciones = true;

  @override
  void initState() {
    super.initState();

    final daoFactory = Provider.of<DAOFactory>(context, listen: false);
    _calificacionDao = daoFactory.createCalificacionDAO();

    _cargarDisponibilidad();
    _cargarCalificaciones();
    _cargarIncidencias();
  }

  // ==========================
  //      INCIDENCIAS
  // ==========================

  Future<void> _cargarIncidencias() async {
    try {
      final incidencias =
          await IncidenciaService.obtenerIncidenciasEspacio(
              widget.espacio.idEspacio, _token);

      if (mounted) {
        setState(() => _incidencias = incidencias);
      }
    } catch (e) {
      try {
        final incidencias =
            await _daoIncidenciaMock.obtenerPorEspacio(widget.espacio.idEspacio);

        if (mounted) {
          setState(() => _incidencias = incidencias);
        }
      } catch (_) {}
    }
  }

  Future<void> _cargarDisponibilidad() async {
    final disponibilidad =
        await _daoDisponibilidad.obtenerPorEspacio(widget.espacio.idEspacio);

    if (disponibilidad != null && mounted) {
      setState(() => _estadoSeleccionado = disponibilidad.estado);
    }
  }

  Future<void> _cargarCalificaciones() async {
    try {
      final lista =
          await _calificacionDao.obtenerPorEspacio(widget.espacio.idEspacio);

      if (!mounted) return;

      setState(() {
        _calificaciones = lista;
        _cargandoCalificaciones = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargandoCalificaciones = false);
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Color _getOcupacionColor(NivelOcupacion nivel) {
    switch (nivel) {
      case NivelOcupacion.vacio:
        return Colors.green;
      case NivelOcupacion.bajo:
        return Colors.yellow[700]!;
      case NivelOcupacion.medio:
        return Colors.orange;
      case NivelOcupacion.alto:
        return Colors.red;
      case NivelOcupacion.lleno:
        return Colors.purple;
    }
  }

  String _getOcupacionText(NivelOcupacion nivel) {
    switch (nivel) {
      case NivelOcupacion.vacio:
        return 'Vacío';
      case NivelOcupacion.bajo:
        return 'Baja ocupación';
      case NivelOcupacion.medio:
        return 'Ocupación media';
      case NivelOcupacion.alto:
        return 'Alta ocupación';
      case NivelOcupacion.lleno:
        return 'Lleno';
    }
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'biblioteca':
        return Icons.library_books;
      case 'cafetería':
        return Icons.local_cafe;
      case 'exterior':
        return Icons.park;
      case 'sala de estudio':
        return Icons.school;
      case 'comedor':
        return Icons.restaurant;
      default:
        return Icons.place;
    }
  }

  Future<void> _reportarDisponibilidad(String estado) async {
    setState(() => _estadoSeleccionado = estado);

    final nueva =
        Disponibilidad(idEspacio: widget.espacio.idEspacio, estado: estado);

    await _daoDisponibilidad.guardar(nueva);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            estado == 'disponible'
                ? 'Espacio reportado como disponible'
                : 'Espacio reportado como ocupado'),
        backgroundColor:
            estado == 'disponible' ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
    // ==========================
  //   DIÁLOGO REPORTAR INCIDENCIA
  // ==========================

  void _mostrarDialogoReporteIncidencia() {
    final TextEditingController descripcionController =
        TextEditingController();
    String? tipoIncidenciaSeleccionado;

    final tiposIncidencia = [
      'Daño en infraestructura',
      'Falta de limpieza',
      'Ruido excesivo',
      'Problemas de temperatura',
      'Falta de servicios (WiFi, enchufes)',
      'Seguridad',
      'Otro',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Reportar incidencia'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de incidencia:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Selecciona un tipo'),
                      value: tipoIncidenciaSeleccionado,
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          tipoIncidenciaSeleccionado = newValue;
                        });
                      },
                      items: tiposIncidencia.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Descripción:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descripcionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe el problema con detalle',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (tipoIncidenciaSeleccionado == null ||
                        descripcionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completa todos los campos'),
                        ),
                      );
                      return;
                    }

                    try {
                      await IncidenciaService.crearIncidencia(
                        widget.espacio.idEspacio,
                        tipoIncidenciaSeleccionado!,
                        descripcionController.text,
                        _token,
                      );
                    } catch (e) {
                      final nueva = Incidencia(
                        idIncidencia:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        idEspacio: widget.espacio.idEspacio,
                        nombreEspacio: widget.espacio.nombre,
                        tipoIncidencia: tipoIncidenciaSeleccionado!,
                        descripcion: descripcionController.text,
                        fechaReporte: DateTime.now(),
                        usuarioReporte: 'usuario@email.com',
                        resuelta: false,
                      );
                      await _daoIncidenciaMock.crear(nueva);
                    }

                    await _cargarIncidencias();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Incidencia reportada: $tipoIncidenciaSeleccionado',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reportar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================
  //       CALIFICACIONES
  // ==========================

  Future<void> _submitCalificacion() async {
    if (_puntuacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una puntuación'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final ahora = DateTime.now();
      final nueva = Calificacion(
        idCalificacion: 'tmp-${ahora.millisecondsSinceEpoch}',
        idEspacio: widget.espacio.idEspacio,
        puntuacion: _puntuacion.toInt(),
        comentario: _comentarioController.text.trim(),
        fecha: ahora,
        estado: EstadoCalificacion.pendiente,
      );

      await _calificacionDao.crear(nueva);
      await _cargarCalificaciones();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calificación enviada exitosamente'),
        ),
      );

      _comentarioController.clear();
      setState(() => _puntuacion = 0.0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar calificación: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
    Future<void> _editarCalificacion(Calificacion calif) async {
    double nuevaPuntuacion = calif.puntuacion.toDouble();
    final controller = TextEditingController(text: calif.comentario);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar calificación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: nuevaPuntuacion,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  nuevaPuntuacion = rating;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Comentario',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      calif.puntuacion = nuevaPuntuacion.toInt();
      calif.comentario = controller.text.trim();

      try {
        await _calificacionDao.actualizar(calif);
        await _cargarCalificaciones();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calificación actualizada')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> _eliminarCalificacion(Calificacion calif) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar calificación'),
          content:
              const Text('¿Seguro que deseas eliminar esta calificación?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await _calificacionDao.eliminar(calif.idCalificacion);
        await _cargarCalificaciones();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calificación eliminada')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  void _mostrarDialogoReportes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reportes de incidencias'),
          content: SizedBox(
            width: double.maxFinite,
            child: _incidencias.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.green[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No hay reportes pendientes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _incidencias.length,
                    itemBuilder: (context, index) {
                      final inc = _incidencias[index];
                      final diff = DateTime.now().difference(inc.fechaReporte);
                      final diasAgo = diff.inDays;
                      final horasAgo = diff.inHours;
                      final minAgo = diff.inMinutes;

                      String fechaRelativa;
                      if (minAgo < 60) {
                        fechaRelativa =
                            'hace $minAgo minuto${minAgo != 1 ? 's' : ''}';
                      } else if (horasAgo < 24) {
                        fechaRelativa =
                            'hace $horasAgo hora${horasAgo != 1 ? 's' : ''}';
                      } else {
                        fechaRelativa =
                            'hace $diasAgo día${diasAgo != 1 ? 's' : ''}';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      inc.tipoIncidencia,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    fechaRelativa,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Espacio: ${inc.nombreEspacio}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                inc.descripcion,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().usuarioActual?.idUsuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.espacio.nombre),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER DEL ESPACIO ===
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              _getOcupacionColor(widget.espacio.nivelOcupacion),
                          child: Icon(
                            _getIconForTipo(widget.espacio.tipo),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.espacio.nombre,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.espacio.tipo,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Estado de ocupación
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getOcupacionColor(
                          widget.espacio.nivelOcupacion,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getOcupacionColor(
                            widget.espacio.nivelOcupacion,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getOcupacionText(widget.espacio.nivelOcupacion),
                        style: TextStyle(
                          color: _getOcupacionColor(
                            widget.espacio.nivelOcupacion,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Calificación promedio
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.espacio.promedioCalificacion.toStringAsFixed(1)} / 5.0',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Reportar disponibilidad ===
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reportar disponibilidad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEstadoButton('disponible', Colors.green),
                        _buildEstadoButton('ocupado', Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Reportar incidencia ===
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reportar problema o incidencia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _mostrarDialogoReporteIncidencia,
                        icon: const Icon(Icons.report_problem),
                        label: const Text('Reportar incidencia'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _mostrarDialogoReportes,
                        icon: const Icon(Icons.list),
                        label: Text('Ver reportes (${_incidencias.length})'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(
                            color: Colors.orange,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Ubicación ===
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('Piso ${widget.espacio.ubicacion.piso}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.espacio.ubicacion.latitud.toStringAsFixed(4)}, '
                          '${widget.espacio.ubicacion.longitud.toStringAsFixed(4)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Características ===
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Características',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          widget.espacio.caracteristicas.map((caracteristica) {
                        return Chip(
                          label: Text(caracteristica.nombre),
                          backgroundColor: Colors.blue[50],
                          side: BorderSide(color: Colors.blue[200]!),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Calificaciones ===
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calificaciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_cargandoCalificaciones) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ] else if (_calificaciones.isEmpty) ...[
                      const Text(
                        'Aún no hay calificaciones para este espacio.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ] else ...[
                      for (var i = 0; i < _calificaciones.length; i++) ...[
                        _buildCalificacionItem(
                          calificacion: _calificaciones[i],
                          esPropia: currentUserId != null &&
                              _calificaciones[i].idUsuario != null &&
                              _calificaciones[i].idUsuario == currentUserId,
                        ),
                        if (i < _calificaciones.length - 1)
                          const Divider(),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === Formulario de calificación ===
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calificar este espacio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _puntuacion,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() => _puntuacion = rating);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _comentarioController,
                      decoration: const InputDecoration(
                        labelText: 'Comentario (opcional)',
                        border: OutlineInputBorder(),
                        hintText: 'Comparte tu experiencia...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitCalificacion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Enviar Calificación',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoButton(String estado, Color color) {
    final bool isSelected = _estadoSeleccionado == estado;

    return ElevatedButton.icon(
      onPressed: () => _reportarDisponibilidad(estado),
      icon: Icon(
        estado == 'disponible' ? Icons.check_circle : Icons.cancel,
        color: isSelected ? Colors.white : color,
      ),
      label: Text(
        estado == 'disponible' ? 'Disponible' : 'Ocupado',
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildCalificacionItem({
    required Calificacion calificacion,
    required bool esPropia,
  }) {
    final fecha = calificacion.fecha;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingBar.builder(
                initialRating: calificacion.puntuacion.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 16,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (_) {},
                ignoreGestures: true,
              ),
              const SizedBox(width: 4),
              Text(
                calificacion.puntuacion.toDouble().toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${fecha.day}/${fecha.month}/${fecha.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            calificacion.comentario,
            style: const TextStyle(fontSize: 14),
          ),
          if (esPropia) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _editarCalificacion(calificacion),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _eliminarCalificacion(calificacion),
                  icon: const Icon(
                    Icons.delete,
                    size: 16,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}