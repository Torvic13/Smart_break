import 'dart:ui';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
            child: Container(
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // transparencia estilo glass
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, -2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconSize: 30,
                currentIndex: currentIndex,
                selectedItemColor: const Color(0xFFF97316),
                unselectedItemColor: Colors.grey[700],
                showUnselectedLabels: true,
                selectedFontSize: 13,
                unselectedFontSize: 12,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                onTap: (index) {
                  // 👇 Muestra SnackBar si presionan "Amigos" o "Eventos"
                  if (index == 1 || index == 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          index == 1
                              ? '👥 Funcionalidad de Amigos próximamente'
                              : '📅 Funcionalidad de Eventos próximamente',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    return; // no ejecuta cambio de pantalla
                  }
                  onTap(index); // ejecuta acción normal en los demás
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_rounded),
                    label: 'Mapa',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group_rounded),
                    label: 'Amigos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_rounded),
                    label: 'Eventos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
