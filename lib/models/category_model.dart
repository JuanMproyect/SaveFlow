import 'package:flutter/material.dart';

class CategoriaModelo {
  final String idCategoria;
  final String? idUsuario; // null si es categoría global del sistema
  final String nombre;
  final String tipo; // "income" o "expense"
  final String icono;
  final String color;
  final bool esPredefinida;

  CategoriaModelo({
    required this.idCategoria,
    required this.idUsuario,
    required this.nombre,
    required this.tipo,
    required this.icono,
    required this.color,
    required this.esPredefinida,
  });

  factory CategoriaModelo.desdeMapa(String id, Map<String, dynamic> datos) {
    return CategoriaModelo(
      idCategoria: id,
      idUsuario: datos['userId'],
      nombre: datos['name'] ?? '',
      tipo: datos['type'] ?? 'expense',
      icono: datos['icon'] ?? 'category',
      color: datos['color'] ?? '#78909C',
      esPredefinida: datos['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'userId': idUsuario,
      'name': nombre,
      'type': tipo,
      'icon': icono,
      'color': color,
      'isDefault': esPredefinida,
    };
  }

  // Convierte el string de color HEX guardado en Firestore a un Color de Flutter
  Color obtenerColor() {
    final hex = color.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  // Convierte el nombre del ícono guardado en Firestore a un IconData real
  IconData obtenerIcono() {
    const mapaIconos = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'home': Icons.home,
      'checkroom': Icons.checkroom,
      'category': Icons.category,
      'payments': Icons.payments,
      'attach_money': Icons.attach_money,
    };
    return mapaIconos[icono] ?? Icons.category;
  }

  @override
  bool operator ==(Object otro) =>
      identical(this, otro) ||
      (otro is CategoriaModelo && idCategoria == otro.idCategoria);

  @override
  int get hashCode => idCategoria.hashCode;
}
