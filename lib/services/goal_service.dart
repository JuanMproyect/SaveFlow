import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class ServicioMetas {
  final FirebaseFirestore _baseDatos = FirebaseFirestore.instance;

  // Crea una nueva meta de ahorro
  Future<void> crearMeta(MetaModelo meta) async {
    await _baseDatos.collection('savingGoals').add(meta.aMapa());
  }

  // Trae todas las metas del usuario (activas, completadas y canceladas)
  // Ordenadas en el cliente para evitar índice compuesto, igual que en transacciones
  Stream<List<MetaModelo>> obtenerMetas(String idUsuario) {
    return _baseDatos
        .collection('savingGoals')
        .where('userId', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) {
          final lista = snapshot.docs
              .map((doc) => MetaModelo.desdeMapa(doc.id, doc.data()))
              .toList();
          lista.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
          return lista;
        });
  }

  // Actualiza el monto acumulado de una meta (abonar dinero a la meta)
  // Si el nuevo monto alcanza o supera el objetivo, marca la meta como completada
  Future<void> actualizarProgreso(MetaModelo meta, double montoAbonado) async {
    final nuevoMonto = meta.montoActual + montoAbonado;
    final seCompleto = nuevoMonto >= meta.montoObjetivo;

    await _baseDatos.collection('savingGoals').doc(meta.idMeta).update({
      'currentAmount': nuevoMonto,
      'status': seCompleto ? 'completed' : 'active',
      if (seCompleto) 'completedAt': DateTime.now(),
    });
  }

  // Cancela una meta
  Future<void> cancelarMeta(String idMeta) async {
    await _baseDatos.collection('savingGoals').doc(idMeta).update({
      'status': 'cancelled',
    });
  }

  // Elimina una meta por completo
  Future<void> eliminarMeta(String idMeta) async {
    await _baseDatos.collection('savingGoals').doc(idMeta).delete();
  }
}