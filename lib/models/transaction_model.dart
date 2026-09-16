class TransaccionModelo {
  final String idTransaccion;
  final String idUsuario;
  final String idCategoria;
  final String tipo; // "income" o "expense"
  final double monto;
  final String monedaOriginal;
  final double montoConvertido;
  final double tipoCambioUsado;
  final String descripcion;
  final DateTime fecha;
  final DateTime fechaCreacion;

  TransaccionModelo({
    required this.idTransaccion,
    required this.idUsuario,
    required this.idCategoria,
    required this.tipo,
    required this.monto,
    required this.monedaOriginal,
    required this.montoConvertido,
    required this.tipoCambioUsado,
    required this.descripcion,
    required this.fecha,
    required this.fechaCreacion,
  });

  factory TransaccionModelo.desdeMapa(String id, Map<String, dynamic> datos) {
    return TransaccionModelo(
      idTransaccion: id,
      idUsuario: datos['userId'] ?? '',
      idCategoria: datos['categoryId'] ?? '',
      tipo: datos['type'] ?? 'expense',
      monto: (datos['amount'] ?? 0).toDouble(),
      monedaOriginal: datos['originalCurrency'] ?? 'HNL',
      montoConvertido: (datos['convertedAmount'] ?? 0).toDouble(),
      tipoCambioUsado: (datos['exchangeRateUsed'] ?? 1).toDouble(),
      descripcion: datos['description'] ?? '',
      fecha: datos['date']?.toDate() ?? DateTime.now(),
      fechaCreacion: datos['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'userId': idUsuario,
      'categoryId': idCategoria,
      'type': tipo,
      'amount': monto,
      'originalCurrency': monedaOriginal,
      'convertedAmount': montoConvertido,
      'exchangeRateUsed': tipoCambioUsado,
      'description': descripcion,
      'date': fecha,
      'createdAt': fechaCreacion,
    };
  }
}