import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/goal_model.dart';
import '../../services/goal_service.dart';
import 'add_goal_screen.dart';
import '../../core/formatters.dart';

class PantallaMetas extends StatelessWidget {
  const PantallaMetas({super.key});

  @override
  Widget build(BuildContext contexto) {
    final servicioMetas = ServicioMetas();
    final idUsuario = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Metas de ahorro')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          contexto,
          MaterialPageRoute(builder: (contexto) => const PantallaAgregarMeta()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<MetaModelo>>(
        stream: servicioMetas.obtenerMetas(idUsuario),
        builder: (contexto, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final metas = snapshot.data ?? [];

          if (metas.isEmpty) {
            return const Center(child: Text('Aún no tienes metas de ahorro'));
          }

          // Solo mostramos activas y completadas; las canceladas quedan ocultas
          final metasVisibles = metas
              .where((meta) => meta.estado != 'cancelled')
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: metasVisibles.length,
            itemBuilder: (contexto, indice) {
              final meta = metasVisibles[indice];
              return _TarjetaMeta(meta: meta, servicioMetas: servicioMetas);
            },
          );
        },
      ),
    );
  }
}

class _TarjetaMeta extends StatelessWidget {
  final MetaModelo meta;
  final ServicioMetas servicioMetas;

  const _TarjetaMeta({required this.meta, required this.servicioMetas});

  @override
  Widget build(BuildContext contexto) {
    final estaCompletada = meta.estado == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meta.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (estaCompletada)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                PopupMenuButton<String>(
                  onSelected: (opcion) {
                    if (opcion == 'abonar') {
                      _mostrarDialogoAbonar(contexto);
                    } else if (opcion == 'cancelar') {
                      servicioMetas.cancelarMeta(meta.idMeta);
                    } else if (opcion == 'eliminar') {
                      servicioMetas.eliminarMeta(meta.idMeta);
                    }
                  },
                  itemBuilder: (contexto) => [
                    if (!estaCompletada)
                      const PopupMenuItem(
                        value: 'abonar',
                        child: Text('Abonar dinero'),
                      ),
                    if (!estaCompletada)
                      const PopupMenuItem(
                        value: 'cancelar',
                        child: Text('Cancelar meta'),
                      ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: meta.porcentajeProgreso,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: estaCompletada
                    ? Colors.green
                    : Theme.of(contexto).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatearMonto(meta.montoActual)} / ${formatearMonto(meta.montoObjetivo)} ${meta.moneda}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  '${(meta.porcentajeProgreso * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (meta.fechaLimite != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Fecha límite: ${meta.fechaLimite!.day}/${meta.fechaLimite!.month}/${meta.fechaLimite!.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAbonar(BuildContext contexto) {
    final controlador = TextEditingController();

    showDialog(
      context: contexto,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Abonar a la meta'),
        content: TextField(
          controller: controlador,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Monto a abonar'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final monto = double.tryParse(controlador.text.trim());
              if (monto != null && monto > 0) {
                servicioMetas.actualizarProgreso(meta, monto);
              }
              Navigator.pop(contextoDialogo);
            },
            child: const Text('Abonar'),
          ),
        ],
      ),
    );
  }
}
