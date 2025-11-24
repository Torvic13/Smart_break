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
      minimum: const EdgeInsets.only(bottom: 10), // 👈 sube un poco la barra
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
            child: Container(
              height: 68, // 👈 altura más controlada para evitar overflow
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // 👈 más transparente
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconSize: 28,
                currentIndex: currentIndex,
                selectedItemColor: const Color(0xFFF97316),
                unselectedItemColor: Colors.grey[700],
                showUnselectedLabels: true,
                selectedFontSize: 13,
                unselectedFontSize: 12,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                onTap: (index) {
                  // 👇 Mensaje temporal para eventos (aún no implementado)
                  if (index == 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📅 Funcionalidad de Eventos próximamente'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(16),
                      ),
                    );
                    return;
                  }
                  onTap(index);
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
