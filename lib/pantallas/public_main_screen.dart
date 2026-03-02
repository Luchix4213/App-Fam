import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';
import 'package:fam_intento1/pantallas/info_screen.dart';
import 'package:fam_intento1/pantallas/contacto_screen.dart';

class PublicMainScreen extends StatefulWidget {
  const PublicMainScreen({super.key});

  @override
  State<PublicMainScreen> createState() => _PublicMainScreenState();
}

class _PublicMainScreenState extends State<PublicMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PantallaInicio(), // Tab 0: Inicio
    const InfoScreen(),     // Tab 1: Info (Placeholder)
    const ContactoScreen(), // Tab 2: Contacto (Placeholder)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: appColores.primaryGreen,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'Info',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_outlined),
              activeIcon: Icon(Icons.phone),
              label: 'Contacto',
            ),
          ],
        ),
      ),
    );
  }
}
