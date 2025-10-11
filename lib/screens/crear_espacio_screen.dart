import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dao/mock_dao_factory.dart';
import '../models/espacio.dart';
import '../models/ubicacion.dart';
import '../models/caracteristica_espacio.dart';
import '../models/usuario.dart'; // asegúrate de importar tu modelo Usuario
import '../models/administrador_sistema.dart';

class CrearEspacioScreen extends StatefulWidget {
  final Usuario
  usuarioActual; // 👈 nuevo parámetro para saber quién está usando la app

  const CrearEspacioScreen({super.key, required this.usuarioActual});

  @override
  State<CrearEspacioScreen> createState() => _CrearEspacioScreenState();
}

class _CrearEspacioScreenState extends State<CrearEspacioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _pisoController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  double _promedioCalificacion = 0;
  NivelOcupacion _nivelOcupacion = NivelOcupacion.vacio;

  bool _isSaving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _pisoController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _guardarEspacio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final daoFactory = Provider.of<MockDAOFactory>(context, listen: false);
      final espacioDAO = daoFactory.createEspacioDAO();

      final nuevoEspacio = Espacio(
        idEspacio: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreController.text.trim(),
        tipo: _tipoController.text.trim(),
        nivelOcupacion: _nivelOcupacion,
        promedioCalificacion: _promedioCalificacion,
        ubicacion: Ubicacion(
          idUbicacion: DateTime.now().microsecondsSinceEpoch.toString(),
          latitud: double.tryParse(_latController.text.trim()) ?? 0.0,
          longitud: double.tryParse(_lonController.text.trim()) ?? 0.0,
          piso: int.tryParse(_pisoController.text.trim()) ?? 0,
        ),
        caracteristicas: [
          CaracteristicaEspacio(
            idCaracteristica: '1',
            nombre: 'WiFi',
            valor: 'Disponible',
            tipoFiltro: 'servicio',
          ),
        ],
      );

      await espacioDAO.crear(nuevoEspacio);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Espacio creado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al crear el espacio: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Espacio'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del espacio',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo (ej. Biblioteca, Cafetería)',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<NivelOcupacion>(
                value: _nivelOcupacion,
                items: NivelOcupacion.values
                    .map(
                      (nivel) => DropdownMenuItem(
                        value: nivel,
                        child: Text(nivel.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _nivelOcupacion = value);
                },
                decoration: const InputDecoration(
                  labelText: 'Nivel de Ocupación',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pisoController,
                decoration: const InputDecoration(labelText: 'Piso'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lonController,
                decoration: const InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // 🔒 Solo el admin puede ver el botón
              if (widget.usuarioActual is AdministradorSistema ||
                  widget.usuarioActual.rol == RolUsuario.admin)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _guardarEspacio,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Guardar Espacio'),
                  ),
                )
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Solo los administradores pueden crear nuevos espacios.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
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
