class MetaModelo {
  final String idMeta;
  final String idUsuario;
  final String nombre;
  final double montoObjetivo;
  final double montoActual;
  final String moneda;
  final DateTime? fechaLimite; // opcional
  final String estado; // "active", "completed" o "cancelled"
  final DateTime fechaCreacion;
  final DateTime? fechaCompletado; // opcional

  MetaModelo({
    required this.idMeta,
    required this.idUsuario,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoActual,
    required this.moneda,
    this.fechaLimite,
    required this.estado,
    required this.fechaCreacion,
    this.fechaCompletado,
  });

  // Porcentaje de progreso, siempre entre 0.0 y 1.0
  double get porcentajeProgreso {
    if (montoObjetivo <= 0) return 0;
    final porcentaje = montoActual / montoObjetivo;
    return porcentaje > 1 ? 1 : porcentaje;
  }

  factory MetaModelo.desdeMapa(String id, Map<String, dynamic> datos) {
    return MetaModelo(
      idMeta: id,
      idUsuario: datos['userId'] ?? '',
      nombre: datos['name'] ?? '',
      montoObjetivo: (datos['targetAmount'] ?? 0).toDouble(),
      montoActual: (datos['currentAmount'] ?? 0).toDouble(),
      moneda: datos['currency'] ?? 'HNL',
      fechaLimite: datos['deadline']?.toDate(),
      estado: datos['status'] ?? 'active',
      fechaCreacion: datos['createdAt']?.toDate() ?? DateTime.now(),
      fechaCompletado: datos['completedAt']?.toDate(),
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'userId': idUsuario,
      'name': nombre,
      'targetAmount': montoObjetivo,
      'currentAmount': montoActual,
      'currency': moneda,
      'deadline': fechaLimite,
      'status': estado,
      'createdAt': fechaCreacion,
      'completedAt': fechaCompletado,
    };
  }

  // Necesario para que el widget reconozca correctamente los cambios
  // (mismo motivo que en CategoriaModelo)
  @override
  bool operator ==(Object otro) =>
      identical(this, otro) || (otro is MetaModelo && idMeta == otro.idMeta);

  @override
  int get hashCode => idMeta.hashCode;
}