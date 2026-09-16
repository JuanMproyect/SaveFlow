class ContextoFinancieroModelo {
  final double totalIngresosRecientes;
  final double totalGastosRecientes;
  final Map<String, double> gastosPorCategoria; // nombre categoría -> monto
  final List<Map<String, dynamic>> metasActivas;

  ContextoFinancieroModelo({
    required this.totalIngresosRecientes,
    required this.totalGastosRecientes,
    required this.gastosPorCategoria,
    required this.metasActivas,
  });

  // Convierte todo el contexto en un texto plano y claro
  // que se le envía a Gemini como parte del prompt
  String aTextoPlano(String monedaBase) {
    final buffer = StringBuffer();

    buffer.writeln('Resumen financiero de los últimos 3 meses del usuario:');
    buffer.writeln('- Ingresos totales: $totalIngresosRecientes $monedaBase');
    buffer.writeln('- Gastos totales: $totalGastosRecientes $monedaBase');
    buffer.writeln('- Balance: ${totalIngresosRecientes - totalGastosRecientes} $monedaBase');

    buffer.writeln('\nGastos por categoría:');
    if (gastosPorCategoria.isEmpty) {
      buffer.writeln('- Sin gastos registrados');
    } else {
      gastosPorCategoria.forEach((categoria, monto) {
        buffer.writeln('- $categoria: $monto $monedaBase');
      });
    }

    buffer.writeln('\nMetas de ahorro activas:');
    if (metasActivas.isEmpty) {
      buffer.writeln('- El usuario no tiene metas activas');
    } else {
      for (var meta in metasActivas) {
        buffer.writeln(
          '- ${meta['nombre']}: ${meta['montoActual']} de ${meta['montoObjetivo']} $monedaBase (${meta['porcentaje']}% completado)',
        );
      }
    }

    return buffer.toString();
  }
}