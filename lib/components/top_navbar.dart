import 'package:flutter/material.dart';
import '../screens/lista_espacios_screen.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;

  const TopNavBar({
    super.key,
    this.title = 'Smart Break',
    this.backgroundColor = const Color(0xFFF97316),
    this.foregroundColor = Colors.white,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.list),
          tooltip: 'Lista de Espacios',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListaEspaciosScreen()),
            );
          },
        ),
      ],
    );
  }
}
