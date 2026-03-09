import 'package:flutter/material.dart';
import 'package:safemenu/view/history_view.dart';
import 'package:safemenu/view/settings_view.dart';
import 'home_view.dart';
// Importa tus otras vistas (History, Settings) cuando las tengamos

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Lista de las páginas principales
  final List<Widget> _pages = [
    const HomeView(), // Índice 0: Inicio
    const HistoryView(), // Índice 1: Historial
    const SettingsView(), // Índice 2: Ajustes (Perfil)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
