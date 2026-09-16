import 'package:flutter/material.dart';

class BarraNavegacionInferior extends StatelessWidget {
  final int indiceSeleccionado;
  final Function(int) alCambiarIndice;

  const BarraNavegacionInferior({
    super.key,
    required this.indiceSeleccionado,
    required this.alCambiarIndice,
  });

  @override
  Widget build(BuildContext contexto) {
    return BottomNavigationBar(
      currentIndex: indiceSeleccionado,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(contexto).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: 'Transacciones',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Chatbot'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
      onTap: alCambiarIndice,
    );
  }
}
