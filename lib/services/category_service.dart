import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class ServicioCategorias {
  final FirebaseFirestore _baseDatos = FirebaseFirestore.instance;

  // Trae las categorías predefinidas del sistema (userId == null)
  // más las categorías personalizadas del usuario actual
  Stream<List<CategoriaModelo>> obtenerCategorias(String idUsuario) {
    return _baseDatos
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoriaModelo.desdeMapa(doc.id, doc.data()))
            .where((categoria) =>
                categoria.esPredefinida || categoria.idUsuario == idUsuario)
            .toList());
  }

  // Renombra una categoría (predefinida o personalizada)
  Future<void> renombrarCategoria(String idCategoria, String nuevoNombre) async {
    await _baseDatos.collection('categories').doc(idCategoria).update({
      'name': nuevoNombre,
    });
  }
}