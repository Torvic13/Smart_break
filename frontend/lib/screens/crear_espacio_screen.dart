import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/espacio.dart';
import '../models/ubicacion.dart';
import '../models/administrador_sistema.dart';
import '../dao/dao_factory.dart';

class CrearEspacioScreen extends StatefulWidget {
  final AdministradorSistema usuarioActual;

  const CrearEspacioScreen({super.key, required this.usuarioActual});

  @override
  State<CrearEspacioScreen> createState() => _CrearEspacioScreenState();
}

class _CrearEspacioScreenState extends State<CrearEspacioScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _pisoController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();

  List<Espacio> _espacios = [];
  LatLng? _selectedPoint;
  bool _isSaving = false;

  static const LatLng _campusCenter = LatLng(-12.084778, -76.971357);

  @override
  void initState() {
    super.initState();
    _loadEspacios();
  }

  Future<void> _loadEspacios() async {
    try {
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      final espacioDAO = daoFactory.createEspacioDAO();
      final espacios = await espacioDAO.obtenerTodos();

      setState(() {
        _espacios = espacios;
      });
    } catch (_) {
      // podrías mostrar un snackbar si quieres
    }
  }

  Future<void> _guardarEspacio() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ubicación en el mapa.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final ahora = DateTime.now().millisecondsSinceEpoch.toString();

      // 1) Crear el objeto Espacio que enviaremos al backend
      final nuevoEspacio = Espacio(
        idEspacio: ahora, // el back genera el suyo, este se ignora
        nombre: _nombreController.text.trim(),
        tipo: _tipoController.text.trim(),
        nivelOcupacion: NivelOcupacion.vacio,
        promedioCalificacion: 0.0,
        ubicacion: Ubicacion(
          idUbicacion: ahora,
          latitud: _selectedPoint!.latitude,
          longitud: _selectedPoint!.longitude,
          piso: int.tryParse(_pisoController.text.trim()) ?? 0,
        ),
        caracteristicas: const [],
        categoriaIds: const [],
      );

      // 2) Llamar al DAO HTTP para hacer el POST al backend
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      final espacioDAO = daoFactory.createEspacioDAO();
      await espacioDAO.crear(nuevoEspacio);

      // 3) Recargar lista desde el backend para ver el pin nuevo
      await _loadEspacios();

      // 4) Limpiar formulario
      _nombreController.clear();
      _tipoController.clear();
      _pisoController.clear();
      _latitudController.clear();
      _longitudController.clear();
      setState(() {
        _selectedPoint = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Espacio creado correctamente'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear espacio: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Espacio'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del espacio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo (ej. Biblioteca, Cafetería)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pisoController,
                decoration: const InputDecoration(
                  labelText: 'Piso',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latitudController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Latitud',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _longitudController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Longitud',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Guardar Espacio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _isSaving ? null : _guardarEspacio,
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _campusCenter,
                      initialZoom: 18.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedPoint = point;
                          _latitudController.text =
                              point.latitude.toStringAsFixed(6);
                          _longitudController.text =
                              point.longitude.toStringAsFixed(6);
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),

                      // Puntos existentes (naranja)
                      MarkerLayer(
                        markers: _espacios.map((espacio) {
                          return Marker(
                            width: 45,
                            height: 45,
                            point: LatLng(
                              espacio.ubicacion.latitud,
                              espacio.ubicacion.longitud,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFFF97316),
                              size: 35,
                            ),
                          );
                        }).toList(),
                      ),

                      // Punto nuevo seleccionado (rojo)
                      if (_selectedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 50,
                              height: 50,
                              point: _selectedPoint!,
                              child: const Icon(
                                Icons.place,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}