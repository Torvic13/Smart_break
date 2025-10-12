import 'package:flutter/material.dart';
import '../models/categoria_espacio.dart';

class FilterScreen extends StatefulWidget {
  final List<CategoriaEspacio> categorias;
  final Function(List<String>) onApplyFilters;

  const FilterScreen({
    Key? key,
    required this.categorias,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final Set<String> _selectedCategories = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar Lugares'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onApplyFilters(_selectedCategories.toList());
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        children: widget.categorias.map((categoria) {
          return CheckboxListTile(
            title: Text(categoria.nombre),
            value: _selectedCategories.contains(categoria.idCategoria),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedCategories.add(categoria.idCategoria);
                } else {
                  _selectedCategories.remove(categoria.idCategoria);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}