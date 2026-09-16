import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/context_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/goal_model.dart';

class ServicioGemini {
  static const String _apiKey =
      'AQ.Ab8RN6IKty0eaYooOX1Jf5fEq9GLc4J5i_EMVOo5L__FVAjNXw';

  static const List<String> _modelosDisponibles = [
    'gemini-3.8-flash',
    'gemini-3.7-flash',
    'gemini-3.6-flash',
    'gemini-3.5-flash-lite',
  ];

  final FirebaseFirestore _baseDatos = FirebaseFirestore.instance;

  // ── PASO 1: Construir el contexto financiero desde Firestore ──────────
  Future<ContextoFinancieroModelo> construirContexto(String idUsuario) async {
    final fechaLimite = DateTime.now().subtract(const Duration(days: 90));

    // Traer transacciones del usuario (últimos 3 meses, filtrado en el cliente
    // para evitar el problema de índice compuesto que ya conocemos)
    final snapshotTransacciones = await _baseDatos
        .collection('transactions')
        .where('userId', isEqualTo: idUsuario)
        .get();

    final transacciones = snapshotTransacciones.docs
        .map((doc) => TransaccionModelo.desdeMapa(doc.id, doc.data()))
        .where((t) => t.fecha.isAfter(fechaLimite))
        .toList();

    // Traer categorías para poder mostrar nombres, no IDs
    final snapshotCategorias = await _baseDatos.collection('categories').get();
    final categorias = snapshotCategorias.docs
        .map((doc) => CategoriaModelo.desdeMapa(doc.id, doc.data()))
        .toList();
    final mapaCategorias = {for (var c in categorias) c.idCategoria: c};

    // Calcular totales y gastos por categoría (con nombre, no ID)
    double totalIngresos = 0;
    double totalGastos = 0;
    final Map<String, double> gastosPorCategoria = {};

    for (var transaccion in transacciones) {
      if (transaccion.tipo == 'income') {
        totalIngresos += transaccion.montoConvertido;
      } else {
        totalGastos += transaccion.montoConvertido;
        final nombreCategoria =
            mapaCategorias[transaccion.idCategoria]?.nombre ?? 'Otros';
        gastosPorCategoria.update(
          nombreCategoria,
          (monto) => monto + transaccion.montoConvertido,
          ifAbsent: () => transaccion.montoConvertido,
        );
      }
    }

    // Traer metas activas del usuario
    final snapshotMetas = await _baseDatos
        .collection('savingGoals')
        .where('userId', isEqualTo: idUsuario)
        .get();

    final metasActivas = snapshotMetas.docs
        .map((doc) => MetaModelo.desdeMapa(doc.id, doc.data()))
        .where((meta) => meta.estado == 'active')
        .map(
          (meta) => {
            'nombre': meta.nombre,
            'montoActual': meta.montoActual,
            'montoObjetivo': meta.montoObjetivo,
            'porcentaje': (meta.porcentajeProgreso * 100).toStringAsFixed(0),
          },
        )
        .toList();

    return ContextoFinancieroModelo(
      totalIngresosRecientes: totalIngresos,
      totalGastosRecientes: totalGastos,
      gastosPorCategoria: gastosPorCategoria,
      metasActivas: metasActivas,
    );
  }

  // ── PASO 2: Enviar el contexto + pregunta del usuario a Gemini ────────
  Future<String> enviarConsulta({
    required String pregunta,
    required ContextoFinancieroModelo contexto,
    required String monedaBase,
  }) async {
    final promptCompleto =
        '''
Eres el asistente financiero de la app SaveFlow. Responde de forma breve, clara y amigable en español, basándote ÚNICAMENTE en los datos financieros reales del usuario
que te doy a continuación. No inventes cifras que no estén en el contexto.

${contexto.aTextoPlano(monedaBase)}

Pregunta del usuario: $pregunta
''';

    // Intenta cada modelo en orden hasta que uno responda con éxito
    for (var modelo in _modelosDisponibles) {
      final resultado = await _intentarConModelo(modelo, promptCompleto);
      if (resultado != null) {
        return resultado; // éxito, no seguimos probando los demás
      }
      // Si resultado es null, el modelo falló: probamos el siguiente
    }

    // Si los 4 modelos fallaron
    return 'El asistente no está disponible en este momento. Intenta más tarde.';
  }

  // Intenta la llamada con un modelo específico.
  // Retorna el texto de respuesta si funciona, o null si falla.
  Future<String?> _intentarConModelo(String modelo, String prompt) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$modelo:generateContent';

    try {
      final respuesta = await http
          .post(
            Uri.parse('$url?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        final texto =
            datos['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (texto != null && texto.toString().trim().isNotEmpty) {
          return texto;
        }
      }

      // Cualquier código distinto a 200, o respuesta vacía, cuenta como fallo
      return null;
    } catch (error) {
      // Error de red, timeout, o modelo no disponible: fallo silencioso,
      // el for loop de arriba pasará automáticamente al siguiente modelo
      return null;
    }
  }
}
