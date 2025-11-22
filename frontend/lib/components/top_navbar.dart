import 'package:flutter/material.dart';
import '../screens/lista_espacios_screen.dart';
import '../screens/filter_screen.dart';
import '../models/categoria_espacio.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;
  final List<CategoriaEspacio>? categorias;
  final Function(List<String>)? onApplyFilters;

  const TopNavBar({
    super.key,
    this.title = 'Smart Break',
    this.backgroundColor = const Color(0xFFF97316),
    this.foregroundColor = Colors.white,
    this.categorias,
    this.onApplyFilters,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: true,
      elevation: 0,
      actions: [
        if (categorias != null && onApplyFilters != null)
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar espacios',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilterScreen(
                    categorias: categorias!,
                    onApplyFilters: onApplyFilters!,
                  ),
                ),
              );
            },
          ),

        // CORREGIDO: Quitamos el 'const' del constructor y corregimos la sintaxis
        IconButton(
          icon: const Icon(Icons.list),
          tooltip: 'Lista de Espacios',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListaEspaciosScreen(), // SIN 'const'
              ),
            );
          },
        ),
      ],
    );
  }
}