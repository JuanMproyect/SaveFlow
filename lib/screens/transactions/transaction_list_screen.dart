import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../services/category_service.dart';
import '../../services/transaction_service.dart';
import 'add_transaction_screen.dart';
import '../../core/formatters.dart';

class PantallaListaTransacciones extends StatelessWidget {
  const PantallaListaTransacciones({super.key});

  @override
  Widget build(BuildContext contexto) {
    final servicioTransacciones = ServicioTransacciones();
    final servicioCategorias = ServicioCategorias();
    final idUsuario = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Transacciones')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          contexto,
          MaterialPageRoute(
            builder: (contexto) => const PantallaAgregarTransaccion(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<CategoriaModelo>>(
        stream: servicioCategorias.obtenerCategorias(idUsuario),
        builder: (contexto, snapshotCategorias) {
          if (!snapshotCategorias.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mapa rápido: idCategoria -> CategoriaModelo, para no buscar en lista cada vez
          final mapaCategorias = {
            for (var categoria in snapshotCategorias.data!)
              categoria.idCategoria: categoria,
          };

          return StreamBuilder<List<TransaccionModelo>>(
            stream: servicioTransacciones.obtenerTransacciones(idUsuario),
            builder: (contexto, snapshotTransacciones) {
              if (snapshotTransacciones.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final transacciones = snapshotTransacciones.data ?? [];

              if (transacciones.isEmpty) {
                return const Center(
                  child: Text('Aún no tienes transacciones registradas'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: transacciones.length,
                itemBuilder: (contexto, indice) {
                  final transaccion = transacciones[indice];
                  final categoria = mapaCategorias[transaccion.idCategoria];
                  final esGasto = transaccion.tipo == 'expense';

                  return Dismissible(
                    key: Key(transaccion.idTransaccion),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => servicioTransacciones
                        .eliminarTransaccion(transaccion.idTransaccion),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            categoria?.obtenerColor() ?? Colors.grey,
                        child: Icon(
                          categoria?.obtenerIcono() ?? Icons.category,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(categoria?.nombre ?? 'Sin categoría'),
                      subtitle: Text(
                        transaccion.descripcion.isNotEmpty
                            ? transaccion.descripcion
                            : '${transaccion.fecha.day}/${transaccion.fecha.month}/${transaccion.fecha.year}',
                      ),
                      trailing: Text(
                        '${esGasto ? '-' : '+'} ${formatearMonto(transaccion.montoConvertido)}',
                        style: TextStyle(
                          color: esGasto ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
