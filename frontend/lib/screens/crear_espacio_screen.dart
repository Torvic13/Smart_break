import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/espacio.dart' as espacio_model;
import '../models/ubicacion.dart' as ubicacion_model;
import '../models/administrador_sistema.dart';
import '../dao/dao_factory.dart';
import 'package:provider/provider.dart';
import '../models/nivel_ocupacion.dart';

class CrearEspacioScreen extends StatefulWidget {
  final AdministradorSistema usuarioActual;

  const CrearEspacioScreen({
    super.key,
    required this.usuarioActual,
  });

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

  List<espacio_model.Espacio> _espacios = [];
  LatLng? _selectedPoint;
  bool _isSaving = false;

  static const LatLng _campusCenter = LatLng(-12.084778, -76.971357);

  @override
  void initState() {
    super.initState();
    _loadEspacios();
  }

  Future<void> _loadEspacios() async {
    final daoFactory = Provider.of<DAOFactory>(context, listen: false);
    final espacioDAO = daoFactory.createEspacioDAO();
    final espacios = await espacioDAO.obtenerTodos();

    setState(() {
      _espacios = espacios;
    });
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

    // Crear ubicación
    final ubicacion = ubicacion_model.Ubicacion(
      latitud: _selectedPoint!.latitude,
      longitud: _selectedPoint!.longitude,
      piso: _pisoController.text.trim(),
    );

    final nuevoEspacio = espacio_model.Espacio(
      idEspacio: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      tipo: _tipoController.text.trim(),
      descripcion: "Sin descripción",
      capacidad: 10,
      nivelOcupacion: NivelOcupacion.vacio.name,
      promedioCalificacion: 0.0,
      ubicacion: ubicacion,
      caracteristicas: const [],
      categoriaIds: const [],
      calificaciones: const [],
    );

    try {
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      final espacioDAO = daoFactory.createEspacioDAO();

      await espacioDAO.crear(nuevoEspacio);

      setState(() {
        _espacios.add(nuevoEspacio);
        _isSaving = false;
      });

      _nombreController.clear();
      _tipoController.clear();
      _pisoController.clear();
      _latitudController.clear();
      _longitudController.clear();
      _selectedPoint = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Espacio guardado correctamente.'),
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar espacio: $e')),
      );
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
                  labelText: 'Tipo del espacio',
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
