// lib/screens/detalle_espacio_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/espacio.dart';
import '../models/categoria_espacio.dart';
import '../models/calificacion.dart';

import '../dao/dao_factory.dart';
import '../dao/categoria_dao.dart';
import '../dao/calificacion_dao.dart';
import '../dao/auth_service.dart';

/// Extension para obtener el id de la calificación
/// Funciona tanto si tu modelo tiene `idCalificacion` como `id`.
extension CalificacionIdExt on Calificacion {
  String get calificacionId {
    try {
      final dynamic self = this;
      final dynamic v = self.idCalificacion ?? self.id;
      if (v != null) return v.toString();
    } catch (_) {}
    return '';
  }
}

/// Pantalla para mostrar los detalles de un espacio con categorías
/// y gestión de calificaciones (⭐, comentar, editar, eliminar).
class DetalleEspacioScreen extends StatefulWidget {
  final Espacio espacio;

  const DetalleEspacioScreen({
    Key? key,
    required this.espacio,
  }) : super(key: key);

  @override
  State<DetalleEspacioScreen> createState() => _DetalleEspacioScreenState();
}

class _DetalleEspacioScreenState extends State<DetalleEspacioScreen> {
  late CategoriaDAO _categoriaDAO;
  late CalificacionDAO _calificacionDAO;
  bool _daoInicializado = false;

  Map<TipoCategoria, List<CategoriaEspacio>> _categoriasPorTipo = {};
  bool _isLoadingCategorias = true;
  String? _errorCategorias;

  // ---- Calificaciones ----
  List<Calificacion> _calificaciones = [];
  bool _isLoadingCalificaciones = true;
  String? _errorCalificaciones;

  double _ratingSeleccionado = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _guardandoCalificacion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_daoInicializado) {
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      _categoriaDAO = daoFactory.createCategoriaDAO();
      _calificacionDAO = daoFactory.createCalificacionDAO();
      _daoInicializado = true;
      _cargarCategorias();
      _cargarCalificaciones();
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  // ===================== CATEGORÍAS =====================

  Future<void> _cargarCategorias() async {
    setState(() {
      _isLoadingCategorias = true;
      _errorCategorias = null;
    });

    try {
      final Map<TipoCategoria, List<CategoriaEspacio>> tempMap = {};

      for (var tipo in TipoCategoria.values) {
        final todasCategorias = await _categoriaDAO.obtenerPorTipo(tipo);

        final categoriasAsignadas = todasCategorias
            .where(
                (cat) => widget.espacio.categoriaIds.contains(cat.idCategoria))
            .toList();

        if (categoriasAsignadas.isNotEmpty) {
          tempMap[tipo] = categoriasAsignadas;
        }
      }

      setState(() {
        _categoriasPorTipo = tempMap;
        _isLoadingCategorias = false;
      });
    } catch (e) {
      setState(() {
        _errorCategorias = 'Error al cargar categorías: $e';
        _isLoadingCategorias = false;
      });
    }
  }

  // ===================== CALIFICACIONES =====================

  Future<void> _cargarCalificaciones() async {
    setState(() {
      _isLoadingCalificaciones = true;
      _errorCalificaciones = null;
    });

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = auth.token;

      if (token.isEmpty) {
        setState(() {
          _calificaciones = [];
          _isLoadingCalificaciones = false;
        });
        return;
      }

      final lista = await _calificacionDAO.obtenerCalificacionesPorEspacio(
        idEspacio: widget.espacio.idEspacio,
        authToken: token,
      );

      setState(() {
        _calificaciones = lista;
        _isLoadingCalificaciones = false;
      });
    } catch (e) {
      setState(() {
        _errorCalificaciones = 'Error al cargar calificaciones: $e';
        _isLoadingCalificaciones = false;
      });
    }
  }

  Future<void> _guardarCalificacion() async {
    final auth = Provider.of<AuthService>(context, listen: false);

    if (auth.token.isEmpty || auth.usuarioActual == null) {
      _mostrarError(
          'Debes iniciar sesión para calificar y comentar este espacio.');
      return;
    }

    if (_ratingSeleccionado <= 0) {
      _mostrarError('Selecciona una puntuación de 1 a 5 estrellas.');
      return;
    }

    setState(() => _guardandoCalificacion = true);

    try {
      await _calificacionDAO.crearCalificacion(
        idEspacio: widget.espacio.idEspacio,
        puntuacion: _ratingSeleccionado,
        comentario: _comentarioController.text.trim(),
        authToken: auth.token,
      );

      _comentarioController.clear();
      setState(() {
        _ratingSeleccionado = 0;
      });

      await _cargarCalificaciones();
      _mostrarOk('Calificación guardada correctamente.');
    } catch (e) {
      _mostrarError('No se pudo crear la calificación: $e');
    } finally {
      if (mounted) {
        setState(() => _guardandoCalificacion = false);
      }
    }
  }

  Future<void> _editarCalificacion(
      Calificacion c, double puntuacion, String comentario) async {
    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      await _calificacionDAO.actualizarCalificacion(
        idCalificacion: c.calificacionId,
        puntuacion: puntuacion,
        comentario: comentario,
        authToken: auth.token,
      );
      await _cargarCalificaciones();
      _mostrarOk('Calificación actualizada.');
    } catch (e) {
      _mostrarError('No se pudo actualizar la calificación: $e');
    }
  }

  Future<void> _borrarCalificacion(Calificacion c) async {
    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      await _calificacionDAO.eliminarCalificacion(
        idCalificacion: c.calificacionId,
        authToken: auth.token,
      );
      await _cargarCalificaciones();
      _mostrarOk('Calificación eliminada.');
    } catch (e) {
      _mostrarError('No se pudo eliminar la calificación: $e');
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarOk(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detalle del Espacio'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF97316),
        backgroundColor: Colors.white,
        onRefresh: () async {
          await _cargarCategorias();
          await _cargarCalificaciones();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildCategorias(),
              const SizedBox(height: 24),
              _buildCalificacionesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== HEADER =====================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.place,
                  color: Colors.white,
                  size: 32,
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
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.espacio.tipo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.yellow, size: 20),
              const SizedBox(width: 6),
              Text(
                widget.espacio.promedioCalificacion > 0
                    ? widget.espacio.promedioCalificacion.toStringAsFixed(1)
                    : 'Sin calificaciones',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== CATEGORÍAS =====================

  Widget _buildCategorias() {
    if (_isLoadingCategorias) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF97316)),
      );
    }

    if (_errorCategorias != null) {
      return Text(
        _errorCategorias!,
        style: const TextStyle(color: Colors.red),
      );
    }

    if (_categoriasPorTipo.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay categorías asignadas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Asigna categorías desde el panel de administración',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _categoriasPorTipo.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildSeccionCategorias(entry.key, entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildSeccionCategorias(
    TipoCategoria tipo,
    List<CategoriaEspacio> categorias,
  ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tipo.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${categorias.length}',
                    style: const TextStyle(
                      color: Color(0xFFF97316),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categorias.map((categoria) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF97316).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFFF97316),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        categoria.nombre,
                        style: const TextStyle(
                          color: Color(0xFF1A202C),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== CALIFICACIONES UI =====================

  Widget _buildCalificacionesSection() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.star_rate_rounded,
                    color: Color(0xFFF97316), size: 24),
                SizedBox(width: 8),
                Text(
                  'Calificaciones y comentarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRatingInput(),
            const SizedBox(height: 16),
            _buildListaCalificaciones(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu calificación:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isSelected = _ratingSeleccionado >= starIndex;
            return IconButton(
              onPressed: () {
                setState(() {
                  _ratingSeleccionado =
                      _ratingSeleccionado == starIndex ? 0 : starIndex.toDouble();
                });
              },
              icon: Icon(
                isSelected ? Icons.star : Icons.star_border,
                color: const Color(0xFFF97316),
              ),
            );
          }),
        ),
        TextField(
          controller: _comentarioController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Comentario (opcional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _guardandoCalificacion ? null : _guardarCalificacion,
            icon: _guardandoCalificacion
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, size: 18),
            label: const Text('Enviar'),
          ),
        ),
      ],
    );
  }

  Widget _buildListaCalificaciones() {
    if (_isLoadingCalificaciones) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(color: Color(0xFFF97316)),
        ),
      );
    }

    if (_errorCalificaciones != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          _errorCalificaciones!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_calificaciones.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'Aún no hay comentarios. ¡Sé el primero en calificar este espacio!',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    final miId = auth.usuarioActual?.idUsuario;

    return ListView.separated(
      itemCount: _calificaciones.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final c = _calificaciones[index];
        final esMio = c.idUsuario == miId;

        return _buildCalificacionTile(c, esMio);
      },
    );
  }

  Widget _buildCalificacionTile(Calificacion c, bool esMio) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person, size: 32, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return Icon(
                        c.puntuacion >= starIndex
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: const Color(0xFFF97316),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    c.puntuacion.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${c.fecha.day.toString().padLeft(2, '0')}/${c.fecha.month.toString().padLeft(2, '0')}/${c.fecha.year}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              if ((c.comentario ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  c.comentario!,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              if (esMio) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _mostrarDialogoEditar(c),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text(
                        'Editar',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmarEliminar(c),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text(
                        'Eliminar',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoEditar(Calificacion c) async {
    double ratingTemp = c.puntuacion;
    final TextEditingController comentarioTemp =
        TextEditingController(text: c.comentario ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar calificación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isSelected = ratingTemp >= starIndex;
                return IconButton(
                  onPressed: () {
                    setState(() {});
                    ratingTemp = starIndex.toDouble();
                    // Forzar rebuild del dialog
                    (context as Element).markNeedsBuild();
                  },
                  icon: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: const Color(0xFFF97316),
                  ),
                );
              }),
            ),
            TextField(
              controller: comentarioTemp,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentario',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _editarCalificacion(
                c,
                ratingTemp,
                comentarioTemp.text.trim(),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Calificacion c) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar calificación'),
        content: const Text(
            '¿Seguro que deseas eliminar esta calificación y comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _borrarCalificacion(c);
    }
  }
}
