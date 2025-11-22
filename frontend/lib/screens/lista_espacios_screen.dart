import 'package:flutter/material.dart';
import '../models/espacio.dart';
import '../dao/dao_factory.dart';
import '../dao/espacio_dao.dart';
import 'package:provider/provider.dart';

class ListaEspaciosScreen extends StatefulWidget {
  @override
  _ListaEspaciosScreenState createState() => _ListaEspaciosScreenState();
}

class _ListaEspaciosScreenState extends State<ListaEspaciosScreen> {
  late EspacioDAO _espacioDao;
  List<Espacio> _espacios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final daoFactory = Provider.of<DAOFactory>(context, listen: false);
    _espacioDao = daoFactory.createEspacioDAO();
    _loadEspacios();
  }

  Future<void> _loadEspacios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final espacios = await _espacioDao.obtenerTodos();
      setState(() {
        _espacios = espacios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espacios Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEspacios,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar espacios',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadEspacios,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_espacios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay espacios disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Todos los espacios están ocupados o no hay datos',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadEspacios,
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _espacios.length,
      itemBuilder: (context, index) {
        final espacio = _espacios[index];
        return _buildSpaceCard(espacio);
      },
    );
  }

  Widget _buildSpaceCard(Espacio espacio) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildOccupationIcon(espacio.nivelOcupacion),
        title: Text(
          espacio.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(espacio.tipo),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${espacio.ubicacion.edificio ?? 'Edificio'} - Piso ${espacio.ubicacion.piso ?? 'N/A'}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildOccupationIndicator(espacio.nivelOcupacion),
                const SizedBox(width: 8),
                if (espacio.promedioCalificacion > 0) ...[
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text('${espacio.promedioCalificacion.toStringAsFixed(1)}'),
                  const SizedBox(width: 16),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _navigateToSpaceDetail(espacio);
        },
      ),
    );
  }

  Widget _buildOccupationIcon(String nivelOcupacion) {
    Color color;
    IconData icon;
    
    switch (nivelOcupacion) {
      case 'vacio':
        color = Colors.green;
        icon = Icons.people_outline;
        break;
      case 'bajo':
        color = Colors.blue;
        icon = Icons.people_outline;
        break;
      case 'medio':
        color = Colors.orange;
        icon = Icons.people;
        break;
      case 'alto':
        color = Colors.red;
        icon = Icons.people;
        break;
      case 'lleno':
        color = Colors.red;
        icon = Icons.people_alt;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }
    
    return Icon(icon, color: color);
  }

  Widget _buildOccupationIndicator(String nivelOcupacion) {
    Color color;
    String text;
    
    switch (nivelOcupacion) {
      case 'vacio':
        color = Colors.green;
        text = 'Vacío';
        break;
      case 'bajo':
        color = Colors.blue;
        text = 'Baja ocupación';
        break;
      case 'medio':
        color = Colors.orange;
        text = 'Ocupación media';
        break;
      case 'alto':
        color = Colors.red;
        text = 'Alta ocupación';
        break;
      case 'lleno':
        color = Colors.red;
        text = 'Lleno';
        break;
      default:
        color = Colors.grey;
        text = 'Desconocido';
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  void _navigateToSpaceDetail(Espacio espacio) {
    Navigator.pushNamed(
      context,
      '/detalle-espacio',
      arguments: espacio,
    );
  }
}