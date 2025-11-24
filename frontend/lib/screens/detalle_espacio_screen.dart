// lib/screens/detalle_espacio_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';                    // ← AÑADIDO
import '../models/espacio.dart';
import '../dao/dao_factory.dart';                        // ← AÑADIDO
import '../dao/reporte_ocupacion_dao.dart';              // ← AÑADIDO (para el tipo)

class DetalleEspacioScreen extends StatefulWidget {
  final Espacio espacio;

  const DetalleEspacioScreen({super.key, required this.espacio});

  @override
  State<DetalleEspacioScreen> createState() => _DetalleEspacioScreenState();
}

class _DetalleEspacioScreenState extends State<DetalleEspacioScreen> {
  final TextEditingController _comentarioController = TextEditingController();

  // ← CORREGIDO: tipo correcto del DAO
  late final ReporteOcupacionDAO _daoReporte;

  double _puntuacion = 0.0;
  bool _isSubmitting = false;
  bool _isReporting = false;

  @override
  void initState() {
    super.initState();
    // ← CORREGIDO: ahora sí encuentra Provider y DAOFactory
    _daoReporte = Provider.of<DAOFactory>(context, listen: false)
        .createReporteOcupacionDAO();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _mostrarDialogoReporte() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Cómo está el espacio ahora?',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNivelButton('vacio', 'Vacío', Colors.green, Icons.sentiment_very_satisfied),
            _buildNivelButton('bajo', 'Baja ocupación', Colors.lightGreen, Icons.sentiment_satisfied),
            _buildNivelButton('medio', 'Ocupación media', Colors.orange, Icons.sentiment_neutral),
            _buildNivelButton('alto', 'Alta ocupación', Colors.red, Icons.sentiment_dissatisfied),
            _buildNivelButton('lleno', 'Lleno', Colors.purple, Icons.sentiment_very_dissatisfied),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNivelButton(String nivel, String texto, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        onPressed: _isReporting
            ? null
            : () {
                Navigator.pop(context);
                _reportarOcupacionReal(nivel);
              },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          texto,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ← CORREGIDO: el método del DAO se llama "reportar", no "reportarOcupacion"
  Future<void> _reportarOcupacionReal(String nivel) async {
    setState(() => _isReporting = true);

    try {
      final success = await _daoReporte.reportar(
        widget.espacio.idEspacio,
        nivel,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reporte enviado correctamente!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        widget.espacio.nivelOcupacion = NivelOcupacion.values.firstWhere(
          (e) => e.name == nivel,
          orElse: () => NivelOcupacion.medio,
        );
      });
    } catch (e) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.red[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 48),
          title: Text(
            'No se puede reportar',
            style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Entendido', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isReporting = false);
    }
  }

  // ======================= TUS FUNCIONES PERFECTAS (SIN CAMBIOS) =======================
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

  Future<void> _submitCalificacion() async {
    if (_puntuacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una puntuación')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificación enviada exitosamente')),
      );
    }

    _comentarioController.clear();
    setState(() {
      _puntuacion = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.espacio.nombre),
        backgroundColor: const Color(0xFF1976D2),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _getOcupacionColor(widget.espacio.nivelOcupacion),
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
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.espacio.tipo,
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getOcupacionColor(widget.espacio.nivelOcupacion).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getOcupacionColor(widget.espacio.nivelOcupacion),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getOcupacionText(widget.espacio.nivelOcupacion),
                        style: TextStyle(
                          color: _getOcupacionColor(widget.espacio.nivelOcupacion),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.espacio.promedioCalificacion.toStringAsFixed(1)} / 5.0',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === BLOQUE REPORTAR OCUPACIÓN (HU22) ===
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reportar nivel de ocupación actual',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isReporting ? null : _mostrarDialogoReporte,
                        icon: _isReporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.bar_chart, color: Colors.white),
                        label: Text(
                          _isReporting ? 'Enviando reporte...' : 'Reportar ahora',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReporting ? Colors.grey[600] : Colors.orange[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Límite: 1 reporte cada 15 minutos por espacio • Máximo 10 al día',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Text('${widget.espacio.ubicacion.latitud.toStringAsFixed(4)}, ${widget.espacio.ubicacion.longitud.toStringAsFixed(4)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Características', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.espacio.caracteristicas.map((caracteristica) {
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
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildCalificacionItem(
                      puntuacion: 5,
                      comentario: 'Excelente lugar para estudiar, muy silencioso',
                      fecha: DateTime.now().subtract(const Duration(days: 2)),
                    ),
                    const Divider(),
                    _buildCalificacionItem(
                      puntuacion: 4,
                      comentario: 'Buen ambiente, pero a veces hay mucho ruido',
                      fecha: DateTime.now().subtract(const Duration(days: 5)),
                    ),
                    const Divider(),
                    _buildCalificacionItem(
                      puntuacion: 3,
                      comentario: 'Regular, podría mejorar la limpieza',
                      fecha: DateTime.now().subtract(const Duration(days: 7)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calificar este espacio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _puntuacion,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _puntuacion = rating;
                          });
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
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Enviar Calificación', style: TextStyle(fontSize: 16)),
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

  Widget _buildCalificacionItem({
    required int puntuacion,
    required String comentario,
    required DateTime fecha,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingBar.builder(
                initialRating: puntuacion.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 16,
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {},
                ignoreGestures: true,
              ),
              const Spacer(),
              Text(
                '${fecha.day}/${fecha.month}/${fecha.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comentario, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}