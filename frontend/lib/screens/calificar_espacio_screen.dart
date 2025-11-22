import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/espacio.dart';
import '../dao/auth_service.dart';
import '../dao/dao_factory.dart';

class CalificarEspacioScreen extends StatefulWidget {
  final Espacio espacio;

  const CalificarEspacioScreen({super.key, required this.espacio});

  @override
  State<CalificarEspacioScreen> createState() => _CalificarEspacioScreenState();
}

class _CalificarEspacioScreenState extends State<CalificarEspacioScreen> {
  double _puntuacion = 0.0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _isLoading = false;

  void _calificarEspacio() async {
    if (_puntuacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una puntuación')),
      );
      return;
    }

    // 👇 VERIFICAR QUE EL ESPACIO TENGA ID
    if (widget.espacio.idEspacio == null || widget.espacio.idEspacio!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: El espacio no tiene ID válido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      final calificacionDAO = daoFactory.createCalificacionDAO();

      // 👇 VERIFICAR QUE HAY TOKEN ANTES DE ENVIAR
      if (authService.token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No estás autenticado. Token requerido')),
        );
        return;
      }

      await calificacionDAO.crearCalificacion(
        idEspacio: widget.espacio.idEspacio!,
        puntuacion: _puntuacion,
        comentario: _comentarioController.text.trim(),
        authToken: authService.token, // 👈 AQUÍ SE PASA EL TOKEN
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Calificación enviada exitosamente')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al calificar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calificar ${widget.espacio.nombre}'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del espacio
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.espacio.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Tipo: ${widget.espacio.tipo}'),
                    Text('Ocupación: ${widget.espacio.nivelOcupacion}'),
                    Text(
                      'Calificación actual: ${widget.espacio.promedioCalificacion}/5',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Selección de estrellas
            const Text(
              '¿Cómo calificarías este espacio?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Center(
              child: StarRating(
                rating: _puntuacion,
                onRatingChanged: (rating) {
                  setState(() => _puntuacion = rating);
                },
              ),
            ),

            const SizedBox(height: 32),

            // Comentario
            const Text(
              'Comentario (opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe tu experiencia en este espacio...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _calificarEspacio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar Calificación',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de estrellas personalizado
class StarRating extends StatefulWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  double _currentRating = 0.0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() => _currentRating = starNumber.toDouble());
            widget.onRatingChanged(_currentRating);
          },
          child: Icon(
            starNumber <= _currentRating ? Icons.star : Icons.star_border,
            color: const Color(0xFFF97316),
            size: 40,
          ),
        );
      }),
    );
  }
}