import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class ServicioTransacciones {
  final FirebaseFirestore _baseDatos = FirebaseFirestore.instance;

  // Guarda una nueva transacción en Firestore
  Future<void> guardarTransaccion(TransaccionModelo transaccion) async {
    await _baseDatos.collection('transactions').add(transaccion.aMapa());
  }

  // Trae todas las transacciones del usuario, ordenadas por fecha descendente
  Stream<List<TransaccionModelo>> obtenerTransacciones(String idUsuario) {
    return _baseDatos
        .collection('transactions')
        .where('userId', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) {
          final lista = snapshot.docs
              .map((doc) => TransaccionModelo.desdeMapa(doc.id, doc.data()))
              .toList();
          lista.sort(
            (a, b) => b.fecha.compareTo(a.fecha),
          ); // más reciente primero
          return lista;
        });
  }

  // Trae transacciones filtradas por tipo (income/expense) y/o categoría
  Stream<List<TransaccionModelo>> obtenerTransaccionesFiltradas({
    required String idUsuario,
    String? tipo,
    String? idCategoria,
  }) {
    Query consulta = _baseDatos
        .collection('transactions')
        .where('userId', isEqualTo: idUsuario);

    if (tipo != null) {
      consulta = consulta.where('type', isEqualTo: tipo);
    }
    if (idCategoria != null) {
      consulta = consulta.where('categoryId', isEqualTo: idCategoria);
    }

    return consulta
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TransaccionModelo.desdeMapa(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Elimina una transacción
  Future<void> eliminarTransaccion(String idTransaccion) async {
    await _baseDatos.collection('transactions').doc(idTransaccion).delete();
  }
}
