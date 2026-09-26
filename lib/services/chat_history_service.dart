import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ServicioHistorialChat {
  final FirebaseFirestore _baseDatos = FirebaseFirestore.instance;

  // Guarda un mensaje individual (del usuario o del bot) en Firestore
  Future<void> guardarMensaje(MensajeChatModelo mensaje) async {
    await _baseDatos.collection('chatMessages').add(mensaje.aMapa());
  }

  // Trae el historial completo del usuario, ordenado por fecha (ascendente,
  // orden de conversación). Ordenamos en Dart para evitar índice compuesto.
  Stream<List<MensajeChatModelo>> obtenerHistorial(String idUsuario) {
    return _baseDatos
        .collection('chatMessages')
        .where('userId', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) {
          final lista = snapshot.docs
              .map((doc) => MensajeChatModelo.desdeMapa(doc.id, doc.data()))
              .toList();
          lista.sort(
            (a, b) => a.fecha.compareTo(b.fecha),
          ); // más antiguo primero
          return lista;
        });
  }

  // Borra todo el historial del usuario (útil si agregas un botón "Limpiar chat")
  Future<void> borrarHistorial(String idUsuario) async {
    final snapshot = await _baseDatos
        .collection('chatMessages')
        .where('userId', isEqualTo: idUsuario)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
