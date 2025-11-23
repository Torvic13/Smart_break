import 'package:flutter/material.dart';
import '../screens/lista_espacios_screen.dart';
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
    this.backgroundColor = const Color(0xFFF97316), // 👈 color naranja principal
    this.foregroundColor = Colors.white,
    this.categorias,
    this.onApplyFilters,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 👈 quita la flecha de retroceso
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: true,
      elevation: 0,
      actions: [
        // 🔸 Botón para la lista de espacios
        IconButton(
          icon: const Icon(Icons.list),
          tooltip: 'Lista de Espacios',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListaEspaciosScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
