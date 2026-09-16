import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';

class PantallaCategorias extends StatelessWidget {
  const PantallaCategorias({super.key});

  @override
  Widget build(BuildContext contexto) {
    final servicioCategorias = ServicioCategorias();
    final idUsuario = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: StreamBuilder<List<CategoriaModelo>>(
        stream: servicioCategorias.obtenerCategorias(idUsuario),
        builder: (contexto, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay categorías disponibles'));
          }

          final categorias = snapshot.data!;
          final gastos = categorias.where((c) => c.tipo == 'expense').toList();
          final ingresos = categorias.where((c) => c.tipo == 'income').toList();

          return ListView(
            children: [
              _construirEncabezado('Gastos'),
              ...gastos.map(
                (c) =>
                    _construirTarjetaCategoria(contexto, c, servicioCategorias),
              ),
              _construirEncabezado('Ingresos'),
              ...ingresos.map(
                (c) =>
                    _construirTarjetaCategoria(contexto, c, servicioCategorias),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _construirEncabezado(String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _construirTarjetaCategoria(
    BuildContext contexto,
    CategoriaModelo categoria,
    ServicioCategorias servicioCategorias,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: categoria.obtenerColor(),
        child: Icon(categoria.obtenerIcono(), color: Colors.white, size: 20),
      ),
      title: Text(categoria.nombre),
      trailing: IconButton(
        icon: const Icon(Icons.edit, size: 20),
        onPressed: () =>
            _mostrarDialogoRenombrar(contexto, categoria, servicioCategorias),
      ),
    );
  }

  void _mostrarDialogoRenombrar(
    BuildContext contexto,
    CategoriaModelo categoria,
    ServicioCategorias servicioCategorias,
  ) {
    final controlador = TextEditingController(text: categoria.nombre);

    showDialog(
      context: contexto,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Renombrar categoría'),
        content: TextField(
          controller: controlador,
          decoration: const InputDecoration(labelText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controlador.text.trim().isNotEmpty) {
                await servicioCategorias.renombrarCategoria(
                  categoria.idCategoria,
                  controlador.text.trim(),
                );
              }
              if (contextoDialogo.mounted) Navigator.pop(contextoDialogo);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
