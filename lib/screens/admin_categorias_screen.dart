import 'package:flutter/material.dart';
import '../models/categoria_espacio.dart';
import '../dao/categoria_dao.dart';
import '../dao/mock_categoria_dao.dart';

/// Pantalla para administrar todas las categorías del sistema
class AdminCategoriasScreen extends StatefulWidget {
  const AdminCategoriasScreen({super.key});

  @override
  State<AdminCategoriasScreen> createState() => _AdminCategoriasScreenState();
}

class _AdminCategoriasScreenState extends State<AdminCategoriasScreen> {
  final CategoriaDAO _categoriaDAO = MockCategoriaDAO();
  Map<TipoCategoria, List<CategoriaEspacio>> _categoriasPorTipo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    setState(() => _isLoading = true);
    try {
      final categorias = await _categoriaDAO.obtenerTodas();
      
      _categoriasPorTipo = {
        TipoCategoria.tipoEspacio: [],
        TipoCategoria.nivelRuido: [],
        TipoCategoria.comodidad: [],
        TipoCategoria.capacidad: [],
        TipoCategoria.bloqueHorario: [],
      };

      for (var categoria in categorias) {
        if (_categoriasPorTipo.containsKey(categoria.tipo)) {
          _categoriasPorTipo[categoria.tipo]!.add(categoria);
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarSnackBar('Error al cargar categorías: $e', esError: true);
    }
  }

  void _mostrarSnackBar(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _agregarCategoria(TipoCategoria tipo) async {
    final TextEditingController nombreController = TextEditingController();
    TimeOfDay? horaInicio;
    TimeOfDay? horaFin;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(24),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF97316).withOpacity(0.2),
                        const Color(0xFFF97316).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFFF97316),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    tipo == TipoCategoria.bloqueHorario
                        ? 'Añadir Bloque Horario'
                        : 'Añadir ${tipo.singularName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tipo != TipoCategoria.bloqueHorario) ...[
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ej: ${_getEjemplo(tipo)}',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.label_outline, color: Color(0xFFF97316)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
                        ),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del bloque',
                        hintText: 'Ej: Mañana',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.access_time, color: Color(0xFFF97316)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Selector de hora inicio
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: horaInicio ?? const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (picked != null) {
                          setStateDialog(() => horaInicio = picked);
                        }
                      },
                      icon: const Icon(Icons.schedule, size: 22),
                      label: Text(
                        horaInicio != null
                            ? 'Inicio: ${horaInicio!.format(context)}'
                            : 'Seleccionar Hora Inicio',
                        style: const TextStyle(fontSize: 15),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF97316),
                        side: const BorderSide(color: Color(0xFFF97316), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Selector de hora fin
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: horaFin ?? const TimeOfDay(hour: 12, minute: 0),
                        );
                        if (picked != null) {
                          setStateDialog(() => horaFin = picked);
                        }
                      },
                      icon: const Icon(Icons.schedule, size: 22),
                      label: Text(
                        horaFin != null
                            ? 'Fin: ${horaFin!.format(context)}'
                            : 'Seleccionar Hora Fin',
                        style: const TextStyle(fontSize: 15),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF97316),
                        side: const BorderSide(color: Color(0xFFF97316), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nombreController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('El nombre es obligatorio'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (tipo == TipoCategoria.bloqueHorario && (horaInicio == null || horaFin == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Debes seleccionar hora de inicio y fin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Crear',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (resultado == true) {
      String nombre = nombreController.text.trim();
      
      // Si es bloque horario, agregar las horas al nombre
      if (tipo == TipoCategoria.bloqueHorario && horaInicio != null && horaFin != null) {
        nombre = '$nombre (${horaInicio!.format(context)} - ${horaFin!.format(context)})';
      }

      final nuevaCategoria = CategoriaEspacio(
        idCategoria: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        tipo: tipo,
        fechaCreacion: DateTime.now(),
      );

      try {
        await _categoriaDAO.crear(nuevaCategoria);
        await _cargarCategorias();
        _mostrarSnackBar('Categoría creada exitosamente');
      } catch (e) {
        _mostrarSnackBar('Error al crear categoría: $e', esError: true);
      }
    }

    nombreController.dispose();
  }

  String _getEjemplo(TipoCategoria tipo) {
    switch (tipo) {
      case TipoCategoria.tipoEspacio:
        return 'Estudio, Descanso, Cafetería';
      case TipoCategoria.nivelRuido:
        return 'Silencioso, Moderado, Animado';
      case TipoCategoria.comodidad:
        return 'WiFi, Enchufes, Aire Acondicionado';
      case TipoCategoria.capacidad:
        return 'Individual, Pequeño, Grande';
      case TipoCategoria.bloqueHorario:
        return 'Mañana, Tarde, Noche';
    }
  }

  IconData _getIconoTipo(TipoCategoria tipo) {
    switch (tipo) {
      case TipoCategoria.tipoEspacio:
        return Icons.category_outlined;
      case TipoCategoria.nivelRuido:
        return Icons.volume_up_outlined;
      case TipoCategoria.comodidad:
        return Icons.emoji_emotions_outlined;
      case TipoCategoria.capacidad:
        return Icons.people_outline;
      case TipoCategoria.bloqueHorario:
        return Icons.access_time_outlined;
    }
  }

  Future<void> _editarCategoria(CategoriaEspacio categoria) async {
    final TextEditingController nombreController = TextEditingController(text: categoria.nombre);

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.2),
                    const Color(0xFFF59E0B).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFFF59E0B),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Editar Categoría',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: nombreController,
          decoration: InputDecoration(
            labelText: 'Nombre',
            prefixIcon: const Icon(Icons.edit, color: Color(0xFFF59E0B)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (resultado == true) {
      final nombre = nombreController.text.trim();
      if (nombre.isNotEmpty) {
        final categoriaActualizada = categoria.copyWith(nombre: nombre);
        try {
          await _categoriaDAO.actualizar(categoriaActualizada);
          await _cargarCategorias();
          _mostrarSnackBar('Categoría actualizada exitosamente');
        } catch (e) {
          _mostrarSnackBar('Error al actualizar: $e', esError: true);
        }
      }
    }

    nombreController.dispose();
  }

  Future<void> _eliminarCategoria(CategoriaEspacio categoria) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Confirmar Eliminación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar "${categoria.nombre}"?',
          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        await _categoriaDAO.eliminar(categoria.idCategoria);
        await _cargarCategorias();
        _mostrarSnackBar('Categoría eliminada exitosamente');
      } catch (e) {
        _mostrarSnackBar('Error al eliminar: $e', esError: true);
      }
    }
  }

  Widget _buildSeccionCategoria(TipoCategoria tipo) {
    final categorias = _categoriasPorTipo[tipo] ?? [];
    
    // Si es Bloque Horario, usar diseño especial
    if (tipo == TipoCategoria.bloqueHorario) {
      return _buildSeccionBloqueHorario(categorias);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección con icono
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconoTipo(tipo),
                  color: const Color(0xFFF97316),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                tipo.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Lista de categorías
          if (categorias.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay ${tipo.displayName.toLowerCase()} registrados',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...categorias.map((categoria) => _buildCategoriaItem(categoria)),
          
          const SizedBox(height: 16),
          
          // Campo de texto y botón para agregar
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () => _agregarCategoria(tipo),
                  decoration: InputDecoration(
                    hintText: 'Nombre del nuevo ${tipo.singularName}...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _agregarCategoria(tipo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  tipo.buttonText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Diseño especial para Bloques Horarios
  Widget _buildSeccionBloqueHorario(List<CategoriaEspacio> categorias) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección con icono
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_outlined,
                  color: Color(0xFFF97316),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bloques Horarios Disponibles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Lista de bloques horarios
          if (categorias.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay bloques horarios registrados',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...categorias.map((categoria) => _buildBloqueHorarioItem(categoria)),
          
          const SizedBox(height: 20),
          
          // Botón para añadir bloque horario
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _agregarCategoria(TipoCategoria.bloqueHorario),
              icon: const Icon(Icons.add, size: 22),
              label: const Text(
                'Añadir Bloque Horario',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Item especial para bloques horarios con el diseño de la imagen
  Widget _buildBloqueHorarioItem(CategoriaEspacio categoria) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: Row(
        children: [
          // Icono de reloj
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFFF97316),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Nombre y horario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria.nombre.split('(')[0].trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                if (categoria.nombre.contains('('))
                  Text(
                    categoria.nombre.substring(
                      categoria.nombre.indexOf('(') + 1,
                      categoria.nombre.indexOf(')'),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Botón Editar con icono
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _editarCategoria(categoria),
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.white,
              tooltip: 'Editar',
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 8),
          // Botón Eliminar con icono
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _eliminarCategoria(categoria),
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.white,
              tooltip: 'Eliminar',
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaItem(CategoriaEspacio categoria) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              categoria.nombre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón Editar con icono
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _editarCategoria(categoria),
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.white,
              tooltip: 'Editar',
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 8),
          // Botón Eliminar con icono
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _eliminarCategoria(categoria),
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.white,
              tooltip: 'Eliminar',
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Gestionar Categorías',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF97316),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFFF97316),
              onRefresh: _cargarCategorias,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSeccionCategoria(TipoCategoria.tipoEspacio),
                    _buildSeccionCategoria(TipoCategoria.nivelRuido),
                    _buildSeccionCategoria(TipoCategoria.comodidad),
                    _buildSeccionCategoria(TipoCategoria.capacidad),
                    _buildSeccionCategoria(TipoCategoria.bloqueHorario),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
